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

  def update_version &blk
    git = VersionsGit.new
    fail("Oops! Can't bump a version with a dirty repo!") unless git.clean?
    version = update_package_json(&blk)
    tag_project(git,version)
  end

  def tag_project(git, version)
    git.tag(version)
    git.push
  end

  def update_package_json
    require 'json'
    require 'semver'

    package = JSON.parse(File.read("package.json"))
    version = SemVer.new(*package["version"].split(".").map(&:to_i))
    yield(version)
    package["version"] = version.format('%M.%m.%p%s')
    File.open('package.json', 'w') do |f|
      f.puts JSON.pretty_generate(package)
    end
    package["version"]
  end

  class VersionsGit
    def initialize
      require 'git'
      @g = Git.open(Dir.pwd)
    end

    def tag(version)
      @g.add('package.json')
      @g.commit("Bumping version to #{version}")
      @g.add_tag(version)
    end

    def push
      @g.push("origin",@g.current_branch,true)
    end

    def clean?
      [@g.status.deleted,@g.status.added,@g.status.changed].all? { |o| o.size == 0 }
    end
  end


end


task :default => ['jasmine:headless', 'compile']

