# Timeout setup per Heroku recommendation with Puma webserver using Rack Timeout Gem.
# https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server
Rack::Timeout.timeout = 20  # seconds
