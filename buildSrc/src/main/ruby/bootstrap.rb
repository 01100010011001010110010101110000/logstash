#!/usr/bin/env ruby

require "rubygems/specification"
require "rubygems/commands/install_command"
$: << File.join(Dir.pwd, "lib")

def install_gem(name, requirement)
  installer = Gem::Commands::InstallCommand.new
  installer.options[:generate_rdoc] = false
  installer.options[:generate_ri] = false
  installer.options[:version] = requirement
  installer.options[:args] = [name]
  installer.options[:install_dir] = ENV["GEM_HOME"]
  installer.options[:document] = []

  begin
    gem name, requirement
  rescue Gem::LoadError => e
    puts "Failed to load #{name}. Will try to install"
    installer.execute
    gem name, requirement
  end
end

def bundler()
  install_gem("bundler", ">0")
  require "bootstrap/environment"
  puts("Invoking bundler install...")
  output, exception = LogStash::Bundler.invoke!(:install => true)
  puts(output)
  raise(exception) if exception
end
