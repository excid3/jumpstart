require "fileutils"
require "shellwords"

# Copied from: https://github.com/mattbrictson/rails-template
# Add this template directory to source_paths so that Thor actions like
# copy_file and template resolve against our source files. If this file was
# invoked remotely via HTTP, that means the files are not present locally.
# In that case, use `git clone` to download them to a local temporary dir.
def add_template_repository_to_source_path
  if __FILE__ =~ %r{\Ahttps?://}
    require "tmpdir"
    source_paths.unshift(tempdir = Dir.mktmpdir("jumpstart-"))
    at_exit { FileUtils.remove_entry(tempdir) }
    git clone: [
      "--quiet",
      "https://github.com/excid3/jumpstart.git",
      tempdir
    ].map(&:shellescape).join(" ")

    if (branch = __FILE__[%r{jumpstart/(.+)/template.rb}, 1])
      Dir.chdir(tempdir) { git checkout: branch }
    end
  else
    source_paths.unshift(File.dirname(__FILE__))
  end
end

def rails_version
  @rails_version ||= Gem::Version.new(Rails::VERSION::STRING)
end

def rails_6_or_newer?
  Gem::Requirement.new(">= 6.0.0.alpha").satisfied_by? rails_version
end

def add_gems
  add_gem 'cssbundling-rails'
  add_gem 'devise', '~> 4.8', '>= 4.8.0'
  add_gem 'friendly_id', '~> 5.4'
  add_gem 'jsbundling-rails'
  add_gem 'madmin'
  add_gem 'name_of_person', '~> 1.1'
  add_gem 'noticed', '~> 1.4'
  add_gem 'omniauth-facebook', '~> 8.0'
  add_gem 'omniauth-github', '~> 2.0'
  add_gem 'omniauth-twitter', '~> 1.4'
  add_gem 'pretender', '~> 0.3.4'
  add_gem 'pundit', '~> 2.1'
  add_gem 'sidekiq', '~> 6.2'
  add_gem 'sitemap_generator', '~> 6.1'
  add_gem 'whenever', require: false
  add_gem 'responders', github: 'heartcombo/responders', branch: 'main'
end

def set_application_name
  # Add Application Name to Config
  environment "config.application_name = Rails.application.class.module_parent_name"

  # Announce the user where they can change the application name in the future.
  puts "You can change application name inside: ./config/application.rb"
end

def add_users
  route "root to: 'home#index'"
  generate "devise:install"

  # Configure Devise to handle TURBO_STREAM requests like HTML requests
  inject_into_file "config/initializers/devise.rb", "  config.navigational_formats = ['/', :html, :turbo_stream]", after: "Devise.setup do |config|\n"

  inject_into_file 'config/initializers/devise.rb', after: "# frozen_string_literal: true\n" do <<~EOF
    class TurboFailureApp < Devise::FailureApp
      def respond
        if request_format == :turbo_stream
          redirect
        else
          super
        end
      end

      def skip_format?
        %w(html turbo_stream */*).include? request_format.to_s
      end
    end
  EOF
  end

  inject_into_file 'config/initializers/devise.rb', after: "# ==> Warden configuration\n" do <<-EOF
  config.warden do |manager|
    manager.failure_app = TurboFailureApp
  end
  EOF
  end

  environment "config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }", env: 'development'
  generate :devise, "User", "first_name", "last_name", "announcements_last_read_at:datetime", "admin:boolean"

  # Set admin default to false
  in_root do
    migration = Dir.glob("db/migrate/*").max_by{ |f| File.mtime(f) }
    gsub_file migration, /:admin/, ":admin, default: false"
  end

  if Gem::Requirement.new("> 5.2").satisfied_by? rails_version
    gsub_file "config/initializers/devise.rb", /  # config.secret_key = .+/, "  config.secret_key = Rails.application.credentials.secret_key_base"
  end

  inject_into_file("app/models/user.rb", "omniauthable, :", after: "devise :")
end

def add_authorization
  generate 'pundit:install'
end

def default_to_esbuild
  return if options[:javascript] == "esbuild"
  unless options[:skip_javascript]
    @options = options.merge(javascript: "esbuild")
  end
end

def add_javascript
  run "yarn add local-time esbuild-rails trix @hotwired/stimulus @hotwired/turbo-rails @rails/activestorage @rails/ujs @rails/request.js"
end

def copy_templates
  remove_file "app/assets/stylesheets/application.css"
  remove_file "app/javascript/application.js"
  remove_file "app/javascript/controllers/index.js"
  remove_file "Procfile.dev"

  copy_file "Procfile"
  copy_file "Procfile.dev"
  copy_file ".foreman"
  copy_file "esbuild.config.js"
  copy_file "app/javascript/application.js"
  copy_file "app/javascript/controllers/index.js"

  directory "app", force: true
  directory "config", force: true
  directory "lib", force: true

  route "get '/terms', to: 'home#terms'"
  route "get '/privacy', to: 'home#privacy'"
end

def add_sidekiq
  environment "config.active_job.queue_adapter = :sidekiq"

  insert_into_file "config/routes.rb",
    "require 'sidekiq/web'\n\n",
    before: "Rails.application.routes.draw do"

  content = <<~RUBY
                authenticate :user, lambda { |u| u.admin? } do
                  mount Sidekiq::Web => '/sidekiq'

                  namespace :madmin do
                    resources :impersonates do
                      post :impersonate, on: :member
                      post :stop_impersonating, on: :collection
                    end
                  end
                end
            RUBY
  insert_into_file "config/routes.rb", "#{content}\n", after: "Rails.application.routes.draw do\n"
end

def add_announcements
  generate "model Announcement published_at:datetime announcement_type name description:text"
  route "resources :announcements, only: [:index]"
end

def add_notifications
  route "resources :notifications, only: [:index]"
end

def add_multiple_authentication
  insert_into_file "config/routes.rb", ', controllers: { omniauth_callbacks: "users/omniauth_callbacks" }', after: "  devise_for :users"

  generate "model Service user:references provider uid access_token access_token_secret refresh_token expires_at:datetime auth:text"

  template = """
  env_creds = Rails.application.credentials[Rails.env.to_sym] || {}
  %i{ facebook twitter github }.each do |provider|
    if options = env_creds[provider]
      config.omniauth provider, options[:app_id], options[:app_secret], options.fetch(:options, {})
    end
  end
  """.strip

  insert_into_file "config/initializers/devise.rb", "  " + template + "\n\n", before: "  # ==> Warden configuration"
end

def add_whenever
  run "wheneverize ."
end

def add_friendly_id
  generate "friendly_id"
  insert_into_file( Dir["db/migrate/**/*friendly_id_slugs.rb"].first, "[5.2]", after: "ActiveRecord::Migration")
end

def add_sitemap
  rails_command "sitemap:install"
end

def add_bootstrap
  rails_command "css:install:bootstrap"
end

def add_announcements_css
  insert_into_file 'app/assets/stylesheets/application.bootstrap.scss', '@import "jumpstart/announcements";'
end

def add_esbuild_script
  build_script = "node esbuild.config.js"

  if (`npx -v`.to_f < 7.1 rescue "Missing")
    say %(Add "scripts": { "build": "#{build_script}" } to your package.json), :green
  else
    run %(npm set-script build "#{build_script}")
  end
end

def add_gem(name, *options)
  gem(name, *options) unless gem_exists?(name)
end

def gem_exists?(name)
  IO.read("Gemfile") =~ /^\s*gem ['"]#{name}['"]/
end

unless rails_6_or_newer?
  puts "Please use Rails 6.0 or newer to create a Jumpstart application"
end

# Main setup
add_template_repository_to_source_path
default_to_esbuild
add_gems

after_bundle do
  set_application_name
  add_users
  add_authorization
  add_javascript
  add_announcements
  add_notifications
  add_multiple_authentication
  add_sidekiq
  add_friendly_id
  add_bootstrap
  add_whenever
  add_sitemap
  add_announcements_css
  add_esbuild_script
  rails_command "active_storage:install"

  # Make sure Linux is in the Gemfile.lock for deploying
  run "bundle lock --add-platform x86_64-linux"

  copy_templates

  # Commit everything to git
  unless ENV["SKIP_GIT"]
    git :init
    git add: "."
    # git commit will fail if user.email is not configured
    begin
      git commit: %( -m 'Initial commit' )
    rescue StandardError => e
      puts e.message
    end
  end

  say
  say "Jumpstart app successfully created!", :blue
  say
  say "To get started with your new app:", :green
  say "  cd #{original_app_name}"
  say
  say "  # Update config/database.yml with your database credentials"
  say
  say "  rails db:create db:migrate"
  say "  rails g noticed:model"
  say "  rails g madmin:install # Generate admin dashboards"
  say "  gem install foreman"
  say "  bin/dev"
end
