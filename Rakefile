require 'rake/clean'
require 'jasmine-headless-webkit'
require 'jasmine/headless/task'

include Rake::DSL if defined?(Rake::DSL)

CLEAN << "dist"

Jasmine::Headless::Task.new

task "compile" do
  `coffee --compile --output dist/ src/`
end

task :default => ['jasmine:headless', 'compile']

