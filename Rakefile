require File.join(File.dirname(__FILE__), 'lib/use_gemfile_jail')
$LOAD_PATH.unshift(ENV.root_path("lib")) unless $LOAD_PATH.include?(ENV.root_path("lib"))
require 'rake'
require 'senor_armando/tasks'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name                  = "senor_armando"
  gem.homepage              = "http://github.com/infochimps-labs/senor_armando"
  gem.license               = "MIT"
  gem.summary               = %Q{Helper middlewares for a Goliath (http://goliath.io/) app as used in Infochimps Planet of the APIs}
  gem.description           = %Q{Helper middlewares for a Goliath (http://goliath.io/) app as used in Infochimps Planet of the APIs}
  gem.email                 = "coders@infochimps.org"
  gem.authors               = ["Infochimps team"]

  gem.required_ruby_version = '>=1.9.2'

  gem.executables = []

  gem.add_dependency 'yajl-ruby',                "~> 0.8.2"
  gem.add_dependency 'gorillib',                 "~> 0.1.1"
  gem.add_dependency 'configliere',              "~> 0.4.7"

  gem.add_dependency 'goliath',                  "~> 0.9.2"
  gem.add_dependency 'eventmachine',             "~> 1.0.0.beta.3"
  gem.add_dependency 'em-synchrony',             ">= 0.3.0.beta.1"
  gem.add_dependency 'em-http-request',          ">= 1.0.0.beta.4"

  gem.add_dependency 'rack',                     ">=1.2.2"
  gem.add_dependency 'rack-contrib'
  gem.add_dependency 'rack-respond_to',          "~> 0.9.8"
  gem.add_dependency 'rack-abstract-format',     "~> 0.9.9"
  gem.add_dependency 'async-rack'
  gem.add_dependency 'multi_json'

  gem.add_development_dependency 'postrank-uri', "~> 1.0.9"
  gem.add_development_dependency 'bundler',      "~> 1.0.12"
  gem.add_development_dependency 'yard',         "~> 0.6.7"
  gem.add_development_dependency 'jeweler',      "~> 1.5.2"
  gem.add_development_dependency 'rspec',        "~> 2.5.0"
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'spork',        "~> 0.9.0.rc5"
  gem.add_development_dependency 'watchr'

  ignores = File.readlines(".gitignore").grep(/^[^#]\S+/).map{|s| s.chomp }
  dotfiles = [".gemtest", ".gitignore", ".rspec", ".yardopts", ".bundle", ".vendor"]
  gem.files = dotfiles + Dir["**/*"].
    reject{|f| f =~ /^\.vendor\// }.
    reject{|f| File.directory?(f) }.
    reject{|f| ignores.any?{|i| File.fnmatch(i, f) || File.fnmatch(i+'/**/*', f) || File.fnmatch(i+'/*', f) } }
  gem.test_files = gem.files.grep(/^spec\//)
  gem.require_paths = ['lib']
end
Jeweler::RubygemsDotOrgTasks.new

# App-specific tasks
Dir[File.dirname(__FILE__)+'/lib/tasks/**/*.rake'].sort.each{|f| load f }

task :default => :spec

