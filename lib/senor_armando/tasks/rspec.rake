require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

desc "Run Watchr"
task :watchr do
  sh %{bundle exec watchr .watchr}
end

desc "Run Spork"
task :spork do
  sh %{bundle exec spork rspec}
end
