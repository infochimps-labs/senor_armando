%w[yard rspec].each do |rake_file|
  require File.join('senor_armando/tasks', "#{rake_file}.rake")
end
