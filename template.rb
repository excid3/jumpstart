# Add Devise to Gemfile
gem "devise", "~> 4.2.1"

# Install Devise
rails_command "generate devise:install"

# Configure Devise
environment "config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }",
            env: 'development'
route "root to: 'home#index'"
# TODO: Install notices
rails_command "generate devise:views"

# Create Devise User
generate :devise, "User",
         "first_name",
         "last_name",
         "announcements_last_read_at:datetime"

# Migrate
rails_command "db:migrate"

after_bundle do
  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit' }
end
