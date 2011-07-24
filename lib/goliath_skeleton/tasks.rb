%w[yard rspec].each do |rake_file|
  load File.join(File.dirname(__FILE__), 'tasks', "#{rake_file}.rake")
end
