require 'rubygems'
Gem::manage_gems
require 'rake/gempackagetask'
require 'rake/testtask'
require 'rake/packagetask'
require 'rake/rdoctask'

spec = Gem::Specification.new do |s|
    s.name     = "mupnp"
    s.version  = "0.1.2"
    s.author   = "Dario Meloni"
    s.email    = "mellon85@gmail.com"
    s.homepage = "http://rubyforge.org/projects/mupnp/"
    s.rubyforge_project = "mupnp"
    s.summary  = "UPnP Implementation using the Miniupnpc library"
    s.files    = FileList['lib/**/*.rb', 'test/**/*.rb', 'Rakefile',
                           'ext/*.[chi]'].to_a
    s.extra_rdoc_files = FileList['README','ext/README','ext/LICENSE','ext/Changelog.txt'].to_a
    s.require_path = ["lib", "ext"]
    s.test_files = Dir.glob('test/**/tc_*.rb')
    s.has_rdoc  = true
    s.extensions << "ext/extconf.rb"
    s.require_path = 'lib'

    if RUBY_PLATFORM =~ /mswin/
      s.files += ["ext/miniupnp.so"]
      s.extensions.clear
      s.platform = Gem::Platform::WIN32
    end
end

Rake::GemPackageTask.new(spec) do |p|
    p.gem_spec = spec
    unless RUBY_PLATFORM =~ /mswin/
        p.need_tar = true
        p.need_zip = true
    end
end

Rake::RDocTask.new do |rd|
    rd.rdoc_dir = "rdoc"
    rd.rdoc_files.include("./lib/**/*.rb")
    rd.rdoc_files.include("README")
    rd.options = %w(-ap)
end

task :distclean => [:clobber_package, :clobber_rdoc]
task :dist      => [:repackage, :gem, :rdoc]
task :clean     => [:distclean, :extclean]
task :default   => [:test, :dist ]

desc "Build the extension"
task :ext => ["ext/Makefile"] do
    cd "ext"
    if (/mswin/ =~ RUBY_PLATFORM) and ENV['make'].nil?
        begin
            sh "nmake"
        rescue Exception => e
            puts "Windows builds is absolutely experimental... all on your back"
            raise e
        end
    else
        sh "make"
    end
    cd ".."
end

desc "Build makefile"
file "ext/Makefile" do
  cd "ext"
  `ruby extconf.rb`
  cd ".."
end

desc "Clean extension"
task :extclean do
    cd 'ext'
    rm_f FileList["*.o","*.so","*.bundle","*.dll","Makefile"]
    cd '..'
end
