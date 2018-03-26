# Rails Jumpstart

It's like Laravel Spark, for Rails. All your Rails apps should start off with a bunch of great defaults.

**Note:** Requires Rails 5.2

## Getting Started

Jumpstart is a Rails template, so you pass it in as an option when creating a new app.

#### Creating a new app

```bash
rails new myapp -d postgresql -m https://raw.githubusercontent.com/excid3/jumpstart/master/template.rb
```

Or if you have downloaded this repo, you can reference template.rb locally:

```bash
rails new myapp -d postgresql -m template.rb
```

#### Cleaning up

```bash
rails db:drop
spring stop
cd ..
rm -rf myapp
```
