current_path = File.expand_path(File.dirname(__FILE__))

# Add Devise to Gemfile
gem "devise", "~> 4.2.1"
gem "bootstrap-sass", "~> 3.3.6"

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

# Rename Application SCSS
run "mv app/assets/stylesheets/application.css app/assets/stylesheets/application.scss"

# Insert Bootstrap Styling
insert_into_file(
  "app/assets/stylesheets/application.scss",
  "@import 'bootstrap-sprockets';\n@import 'bootstrap'\n",
  before: "/*"
)

# Import Templates
run "cp #{current_path}/views/layouts/application.html.erb app/views/layouts/application.html.erb"
run "cp -R #{current_path}/views/shared app/views/shared"

# Migrate
rails_command "db:migrate"

after_bundle do
  git :init
  git add: "."
  git commit: %Q{ -m 'Initial commit' }
end
