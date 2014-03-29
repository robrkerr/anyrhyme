source 'http://rubygems.org'
# source 'http://rubygems.railscamp.org'

gem 'rails', '3.1.0'

# Bundle edge Rails instead:
# gem 'rails',     :git => 'git://github.com/rails/rails.git'

gem 'pg'
gem 'activerecord-import'
# gem 'activerecord-postgres-array'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', "  ~> 3.1.0"
  gem 'coffee-rails', "~> 3.1.0"
  gem 'dynamic_form'
  gem 'uglifier'
end

gem 'jquery-rails'
# gem 'jquery-ui-rails'
# gem 'jquery-ui-themes'

# gem 'mime-types', :require => 'mime/types'

# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

# group :development do 
  # gem 'meta_request'
# end

group :test, :development do
  gem 'rspec-rails', '~> 2.5'
end

group :test do
  gem 'cucumber-rails', :require => false
  gem 'gherkin', '<= 2.11.6'
  gem 'capybara'
  gem 'database_cleaner'
  gem "factory_girl_rails", "~> 4.0"
  gem "factory_girl", "~> 4.0"
end

gem 'rename'