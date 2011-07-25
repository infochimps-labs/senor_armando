%w[yard rspec].each do |rake_file|
  load File.join('senor_armando/tasks', "#{rake_file}.rake")
end
