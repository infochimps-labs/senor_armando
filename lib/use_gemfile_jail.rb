def ENV.root_path(*args)
  File.expand_path(File.join(File.dirname(__FILE__), '..', *args))
end

if defined? RACK_ENV
  true #pass
elsif (idx = (ARGV.index('-e') || ARGV.index('--environment')))
  RACK_ENV = { 'prod' => 'production', 'dev' => 'development', 'stag' => 'staging'}[ARGV[idx+1]] || ARGV[idx+1]
else
  RACK_ENV = ENV["RACK_ENV"] || "development"
end
ENV["RACK_ENV"] = RACK_ENV

is_production = (!!ENV['GEM_STRICT']) || (RACK_ENV == 'production') || (RACK_ENV == 'staging')

def try_or_exec_bootstrap try_bootstrap=true, &block
  if try_bootstrap && (not block.call)
    cmd = ENV.root_path("bin/update_gemfile_jail.rb")
    warn "WARN The gem environment is out-of-date or has yet to be bootstrapped."
    warn "     Runnning '#{cmd} --local' to remedy this situation. "
    warn "     if you get an error about 'rake' or somesuch not installed, "
    warn "     run #{cmd} explicitly (without the --local flag)."
    system cmd, "--local"
  end
  if not block.call
    warn "FAIL The gem environment is out-of-date. Run 'bundle install' explicitly and then retry"
    fail "gem environment not configured"
  end
end

if is_production
  # Verify the environment has been bootstrapped by checking that the .bundle/loadpath file exists.
  try_or_exec_bootstrap(false) do
    File.exist?(ENV.root_path(".bundle/loadpath"))
  end
else
  # Run a more exhaustive bootstrap check in non-production environments by making
  # sure the Gemfile matches the .bundle/loadpath file checksum.

  # Verify the environment has been bootstrapped by checking that the .bundle/loadpath file exists.
  try_or_exec_bootstrap do
    File.exist?(ENV.root_path(".bundle/loadpath"))
  end
  try_or_exec_bootstrap do
    checksum = File.read(ENV.root_path(".bundle/checksum")).to_i rescue nil
    `cksum <'#{ENV.root_path}/Gemfile'`.to_i == checksum
  end
end

# Disallow use of system gems by default in staging and production environments
# or when the GEM_STRICT environment variable is set. This ensures the gem
# environment is totally isolated to only stuff specified in the Gemfile.
if is_production
  ENV['GEM_PATH'] = ENV.root_path("vendor/gems")
  ENV['GEM_HOME'] = ENV.root_path("vendor/gems")
elsif !ENV['GEM_PATH'].to_s.include?(ENV.root_path("vendor/gems"))
  ENV['GEM_PATH'] =
    [ENV.root_path("vendor/gems"), ENV['GEM_PATH']].compact.join(':')
end

# Setup bundled gem load path.
paths = File.read(ENV.root_path(".bundle/loadpath")).split("\n")
paths.each do |path|
  next if path =~ /^[ \t]*(?:#|$)/
  path = ENV.root_path(path)
  $: << path if !$:.include?(path)
end

# Child processes inherit our load path.
ENV['RUBYLIB'] = $:.compact.join(':')
