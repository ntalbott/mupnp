require "bundler"
Bundler.setup

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.libs << "test" << "lib" << "ext"
  t.test_files = FileList['test/test_*.rb']
  t.verbose = true
end

task default: :test

gemspec = eval(File.read("mupnp.gemspec"))

task :build => "#{gemspec.full_name}.gem"

file "#{gemspec.full_name}.gem" => gemspec.files + ["mupnp.gemspec"] do
  system "gem build mupnp.gemspec"
  system "gem install mupnp-#{UPnP::VERSION}.gem"
end

require "rbconfig"
EXT = RbConfig::CONFIG["DLEXT"]
NAME = "MiniUPnP"

file "ext/#{NAME}.#{EXT}" => Dir.glob("ext/*{.c,.h}") do
  Dir.chdir("ext") do
    ruby "extconf.rb"
    sh "make"
  end
end

# make the :test task depend on the shared
# object, so it will be built automatically
# before running the tests
task :test => "ext/#{NAME}.#{EXT}"

require "rake/clean"
CLEAN.include('ext/*{.o,.log,.so,.bundle}')
CLEAN.include('ext/Makefile')
