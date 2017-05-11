def source_paths
  [File.expand_path(File.dirname(__FILE__))]
end

def add_gems
  gem 'devise', github: 'plataformatec/devise' #, '~> 4.2.1'
  gem 'jquery-rails', '~> 4.3.1'
  gem 'bootstrap', '~> 4.0.0.alpha6'
  gem 'webpacker', '~> 1.1'
  gem 'sidekiq', '~> 5.0'
  gem 'foreman', '~> 0.84.0'
end

def add_users
  # Install Devise
  rails_command "generate devise:install"

  # Configure Devise
  environment "config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }",
              env: 'development'
  route "root to: 'home#index'"

  # Devise notices are installed via Bootstrap
  rails_command "generate devise:views User"

  # Create Devise User
  generate :devise, "User",
           "first_name",
           "last_name",
           "announcements_last_read_at:datetime",
           "admin:boolean"

  # Set admin default to false
  in_root do
    migration = Dir.glob("db/migrate/*").max_by{ |f| File.mtime(f) }
    gsub_file migration, /:admin/, ":admin, default: false"
  end
end

def add_bootstrap
  # Remove Application CSS
  run "rm app/assets/stylesheets/application.css"

  # Add Bootstrap JS
  insert_into_file(
    "app/assets/javascripts/application.js",
    "\n//= require jquery\n//= require bootstrap",
    after: "//= require rails-ujs"
  )
end

def copy_templates
  directory "app", force: true
end

def add_webpack
  rails_command 'webpacker:install'
end

def add_sidekiq
  environment "config.active_job.queue_adapter = :sidekiq"

  insert_into_file "config/routes.rb",
    "require 'sidekiq/web'\n\n",
    before: "Rails.application.routes.draw do"

  insert_into_file "config/routes.rb",
    "  authenticate :user, lambda { |u| u.admin? } do\n    mount Sidekiq::Web => '/sidekiq'\n  end\n\n",
    after: "Rails.application.routes.draw do\n"
end

def add_foreman
  copy_file "Procfile"
end

# Main setup
add_gems
add_users
add_bootstrap
copy_templates
add_sidekiq
add_foreman
add_webpack

# Migrate
rails_command "db:create"
rails_command "db:migrate"

after_bundle do
  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit' }
end
