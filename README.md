👉 We've also built [Jumpstart Pro](https://jumpstartrails.com) which is a version of Jumpstart that includes payments with Stripe & Braintree, team accounts, TailwindCSS, and much more.

# Jumpstart Rails Template

All your Rails apps should start off with a bunch of great defaults. It's like Laravel Spark, for Rails.

**Note:** Requires Rails 5.2 or higher

Want to see how it works? Check out [the Jumpstart walkthrough video](https://www.youtube.com/watch?v=ssOZpISfIfI):

[![Jumpstart Ruby on Rails Template Walkthrough](https://i.imgur.com/pZDPbc7l.png)](https://www.youtube.com/watch?v=ssOZpISfIfI)

## Getting Started

Jumpstart is a Rails template, so you pass it in as an option when creating a new app.

#### Requirements

You'll need the following installed to run the template successfully:

* Ruby 2.5 or higher
* Redis - For ActionCable support
* bundler - `gem install bundler`
* rails - `gem install rails`
* Yarn - `brew install yarn` or [Install Yarn](https://yarnpkg.com/en/docs/install)
* Foreman (optional) - `gem install foreman` - helps run all your
  processes in development

#### Creating a new app

```bash
rails new myapp -d postgresql -m https://raw.githubusercontent.com/excid3/jumpstart/master/template.rb
```

Or if you have downloaded this repo, you can reference template.rb locally:

```bash
rails new myapp -d postgresql -m template.rb
```

To run your app, use `foreman start`.

This will run `Procfile.dev` via `foreman start -f Procfile.dev` as configured by the `.foreman` file and will launch the development processes `rails server`, `sidekiq`, and `webpack-dev-server` processes. You can also run them in separate terminals manually if you prefer.

A separate `Procfile` is generated for deploying to production.

#### Authenticate with social networks

We use the encrypted Rails Credentials for app_id and app_secrets when it comes to omniauth authentication. Edit them as so:

```
EDITOR=vim rails credentials:edit
```

Make sure your file follow this structure:

```yml
secret_key_base: [your-key]
development:
  github:
    app_id: something
    app_secret: something
    options:
      scope: 'user:email'
      whatever: true
production:
  github:
    app_id: something
    app_secret: something
    options:
      scope: 'user:email'
      whatever: true
```

With the environment, the service and the app_id/app_secret. If this is done correctly, you should see login links
for the services you have added to the encrypted credentials using `EDITOR=vim rails credentials:edit`

#### Cleaning up

```bash
rails db:drop
spring stop
cd ..
rm -rf myapp
```
