# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{senor_armando}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = [%q{Infochimps team}]
  s.date = %q{2011-07-25}
  s.description = %q{Helper middlewares for a Goliath (http://goliath.io/) app as used in Infochimps Planet of the APIs}
  s.email = %q{coders@infochimps.org}
  s.executables = [%q{armando_echo.rb}, %q{armando_elsewhere.rb}, %q{armando_proxy.rb}, %q{create_gemfile_jail.rb}]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    ".gitignore",
    ".rspec",
    "FEATURES.txt",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.md",
    "Rakefile",
    "VERSION",
    "bin/armando_echo.rb",
    "bin/armando_elsewhere.rb",
    "bin/armando_proxy.rb",
    "bin/create_gemfile_jail.rb",
    "config/app.example.yaml",
    "config/app.rb",
    "config/app.yaml",
    "lib/boot.rb",
    "lib/senor_armando.rb",
    "lib/senor_armando/endpoint/echo.rb",
    "lib/senor_armando/endpoint/proxy.rb",
    "lib/senor_armando/error.rb",
    "lib/senor_armando/plugins/statsd_plugin.rb",
    "lib/senor_armando/rack/exception_handler.rb",
    "lib/senor_armando/rack/statsd_logger.rb",
    "lib/senor_armando/rack/tracer.rb",
    "lib/senor_armando/spec/he_help_me_test.rb",
    "lib/senor_armando/tasks.rb",
    "lib/senor_armando/tasks/rspec.rake",
    "lib/senor_armando/tasks/yard.rake",
    "lib/senor_armando/use_gemfile_jail.rb",
    "senor_armando.gemspec",
    "senor_armando.jpeg",
    "spec/armando_proxy_spec.rb",
    "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/infochimps-labs/senor_armando}
  s.licenses = [%q{MIT}]
  s.require_paths = [%q{lib}]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.2")
  s.rubygems_version = %q{1.8.5}
  s.summary = %q{Helper middlewares for a Goliath (http://goliath.io/) app as used in Infochimps Planet of the APIs}
  s.test_files = [
    "spec/armando_proxy_spec.rb",
    "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<gorillib>, ["~> 0.1.0"])
      s.add_runtime_dependency(%q<yajl-ruby>, ["~> 0.8.2"])
      s.add_runtime_dependency(%q<configliere>, ["~> 0.4.7"])
      s.add_runtime_dependency(%q<postrank-uri>, ["~> 1.0.9"])
      s.add_runtime_dependency(%q<goliath>, [">= 0"])
      s.add_runtime_dependency(%q<eventmachine>, [">= 0"])
      s.add_runtime_dependency(%q<em-synchrony>, [">= 0"])
      s.add_runtime_dependency(%q<em-http-request>, [">= 0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.12"])
      s.add_development_dependency(%q<yard>, ["~> 0.6.7"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.5.2"])
      s.add_development_dependency(%q<rspec>, ["~> 2.5.0"])
      s.add_development_dependency(%q<rcov>, [">= 0.9.9"])
      s.add_runtime_dependency(%q<goliath>, [">= 0.9.1"])
      s.add_runtime_dependency(%q<eventmachine>, [">= 1.0.0.beta.3"])
      s.add_runtime_dependency(%q<em-synchrony>, [">= 0.3.0.beta.1"])
      s.add_runtime_dependency(%q<em-http-request>, [">= 1.0.0.beta.3"])
      s.add_runtime_dependency(%q<yajl-ruby>, ["~> 0.8.2"])
      s.add_runtime_dependency(%q<gorillib>, ["~> 0.1.1"])
      s.add_runtime_dependency(%q<addressable>, ["~> 2.2.5"])
      s.add_runtime_dependency(%q<rack>, [">= 1.2.2"])
      s.add_runtime_dependency(%q<rack-contrib>, [">= 0"])
      s.add_runtime_dependency(%q<rack-respond_to>, ["~> 0.9.8"])
      s.add_runtime_dependency(%q<rack-abstract-format>, ["~> 0.9.9"])
      s.add_runtime_dependency(%q<async-rack>, [">= 0"])
      s.add_runtime_dependency(%q<multi_json>, [">= 0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.12"])
      s.add_development_dependency(%q<yard>, ["~> 0.6.7"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.5.2"])
      s.add_development_dependency(%q<rspec>, ["~> 2.5.0"])
      s.add_development_dependency(%q<rcov>, [">= 0.9.9"])
      s.add_development_dependency(%q<spork>, ["~> 0.9.0.rc5"])
      s.add_development_dependency(%q<watchr>, [">= 0"])
    else
      s.add_dependency(%q<gorillib>, ["~> 0.1.0"])
      s.add_dependency(%q<yajl-ruby>, ["~> 0.8.2"])
      s.add_dependency(%q<configliere>, ["~> 0.4.7"])
      s.add_dependency(%q<postrank-uri>, ["~> 1.0.9"])
      s.add_dependency(%q<goliath>, [">= 0"])
      s.add_dependency(%q<eventmachine>, [">= 0"])
      s.add_dependency(%q<em-synchrony>, [">= 0"])
      s.add_dependency(%q<em-http-request>, [">= 0"])
      s.add_dependency(%q<bundler>, ["~> 1.0.12"])
      s.add_dependency(%q<yard>, ["~> 0.6.7"])
      s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
      s.add_dependency(%q<rspec>, ["~> 2.5.0"])
      s.add_dependency(%q<rcov>, [">= 0.9.9"])
      s.add_dependency(%q<goliath>, [">= 0.9.1"])
      s.add_dependency(%q<eventmachine>, [">= 1.0.0.beta.3"])
      s.add_dependency(%q<em-synchrony>, [">= 0.3.0.beta.1"])
      s.add_dependency(%q<em-http-request>, [">= 1.0.0.beta.3"])
      s.add_dependency(%q<yajl-ruby>, ["~> 0.8.2"])
      s.add_dependency(%q<gorillib>, ["~> 0.1.1"])
      s.add_dependency(%q<addressable>, ["~> 2.2.5"])
      s.add_dependency(%q<rack>, [">= 1.2.2"])
      s.add_dependency(%q<rack-contrib>, [">= 0"])
      s.add_dependency(%q<rack-respond_to>, ["~> 0.9.8"])
      s.add_dependency(%q<rack-abstract-format>, ["~> 0.9.9"])
      s.add_dependency(%q<async-rack>, [">= 0"])
      s.add_dependency(%q<multi_json>, [">= 0"])
      s.add_dependency(%q<bundler>, ["~> 1.0.12"])
      s.add_dependency(%q<yard>, ["~> 0.6.7"])
      s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
      s.add_dependency(%q<rspec>, ["~> 2.5.0"])
      s.add_dependency(%q<rcov>, [">= 0.9.9"])
      s.add_dependency(%q<spork>, ["~> 0.9.0.rc5"])
      s.add_dependency(%q<watchr>, [">= 0"])
    end
  else
    s.add_dependency(%q<gorillib>, ["~> 0.1.0"])
    s.add_dependency(%q<yajl-ruby>, ["~> 0.8.2"])
    s.add_dependency(%q<configliere>, ["~> 0.4.7"])
    s.add_dependency(%q<postrank-uri>, ["~> 1.0.9"])
    s.add_dependency(%q<goliath>, [">= 0"])
    s.add_dependency(%q<eventmachine>, [">= 0"])
    s.add_dependency(%q<em-synchrony>, [">= 0"])
    s.add_dependency(%q<em-http-request>, [">= 0"])
    s.add_dependency(%q<bundler>, ["~> 1.0.12"])
    s.add_dependency(%q<yard>, ["~> 0.6.7"])
    s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
    s.add_dependency(%q<rspec>, ["~> 2.5.0"])
    s.add_dependency(%q<rcov>, [">= 0.9.9"])
    s.add_dependency(%q<goliath>, [">= 0.9.1"])
    s.add_dependency(%q<eventmachine>, [">= 1.0.0.beta.3"])
    s.add_dependency(%q<em-synchrony>, [">= 0.3.0.beta.1"])
    s.add_dependency(%q<em-http-request>, [">= 1.0.0.beta.3"])
    s.add_dependency(%q<yajl-ruby>, ["~> 0.8.2"])
    s.add_dependency(%q<gorillib>, ["~> 0.1.1"])
    s.add_dependency(%q<addressable>, ["~> 2.2.5"])
    s.add_dependency(%q<rack>, [">= 1.2.2"])
    s.add_dependency(%q<rack-contrib>, [">= 0"])
    s.add_dependency(%q<rack-respond_to>, ["~> 0.9.8"])
    s.add_dependency(%q<rack-abstract-format>, ["~> 0.9.9"])
    s.add_dependency(%q<async-rack>, [">= 0"])
    s.add_dependency(%q<multi_json>, [">= 0"])
    s.add_dependency(%q<bundler>, ["~> 1.0.12"])
    s.add_dependency(%q<yard>, ["~> 0.6.7"])
    s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
    s.add_dependency(%q<rspec>, ["~> 2.5.0"])
    s.add_dependency(%q<rcov>, [">= 0.9.9"])
    s.add_dependency(%q<spork>, ["~> 0.9.0.rc5"])
    s.add_dependency(%q<watchr>, [">= 0"])
  end
end
