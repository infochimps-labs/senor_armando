source "http://rubygems.org"

gem   'yajl-ruby',   "~> 0.8.2"
gem   'gorillib',    "~> 0.1.1"
gem   'configliere', "~> 0.4.7"

gem   'goliath',         :git => 'https://github.com/postrank-labs/goliath.git', :branch => 'new_aroundware'
gem   'eventmachine', "~> 1.0.0.beta.3",    :git => 'https://github.com/eventmachine/eventmachine.git'
gem   'em-synchrony',    :git => 'https://github.com/igrigorik/em-synchrony.git'
gem   'em-http-request', :git => 'https://github.com/igrigorik/em-http-request.git'

# Add dependencies to develop your gem here.
# Include everything needed to run rake, tests, features, etc.
group :development do
  gem  'postrank-uri', "~> 1.0.9"

  gem 'bundler',   "~> 1.0.12"
  gem 'yard',      "~> 0.6.7"
  gem 'jeweler',   "~> 1.5.2"
  gem 'rspec',     "~> 2.5.0"
  gem 'simplecov'
end

group :test do
  gem 'spork',     "~> 0.9.0.rc5"
  gem 'watchr'
end
