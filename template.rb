def source_paths
  [File.expand_path(File.dirname(__FILE__))]
end

def add_users
  # Gemfile
  gem 'devise', '~> 4.2.1'

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
           "announcements_last_read_at:datetime"
end

def add_bootstrap
  gem 'bootstrap-sass', '~> 3.3.6'

  # Replace Application SCSS
  run "rm app/assets/stylesheets/application.css"
end

def copy_templates
  directory "app", force: true
end

def add_webpack
  gem 'webpacker', '~> 1.1'
  rails_command 'webpacker:install'
end

def add_sidekiq
  gem 'sidekiq', '~> 5.0'
  environment "config.active_job.queue_adapter = :sidekiq"
end

def add_foreman
  gem 'foreman', '~> 0.84.0'
  copy_file "Procfile"
end

# Main setup
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
