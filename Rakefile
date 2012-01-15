require 'rake/clean'
require 'jasmine-headless-webkit'
require 'jasmine/headless/task'

include Rake::DSL if defined?(Rake::DSL)

CLEAN << "dist"

Jasmine::Headless::Task.new

task "compile" do
  `coffee --compile --output dist/ src/`
end

namespace "bump" do
  task "major", :compile do
    update_version { |v| v.major += 1 }
  end

  task "minor", :compile do
    update_version { |v| v.minor += 1 }
  end

  task "patch", :compile do
    update_version { |v| v.patch += 1 }
  end

  def update_version
    require 'json'
    require 'semver'

    package = JSON.parse(File.read("package.json"))
    version = SemVer.new(*package["version"].split(".").map(&:to_i))
    yield(version)
    package["version"] = version.format('%M.%m.%p%s')
    File.open('package.json', 'w') do |f|
      f.puts JSON.pretty_generate(package)
    end
  end
end


task :default => ['jasmine:headless', 'compile']

