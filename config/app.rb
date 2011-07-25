Settings.define :app_name, :default => File.basename($0, '.rb'), :description => 'Name to key on for tracer stats, statsd metrics, etc.'
Settings.read(Goliath.root_path('config/app.yaml'))
Settings.resolve!

