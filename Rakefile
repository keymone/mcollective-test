require 'rubygems'
require 'rubygems/package_task'
require 'rspec/core/rake_task'

spec = instance_eval(File.read('mcollective-test.gemspec'))

Gem::PackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end

task :default => :repackage
