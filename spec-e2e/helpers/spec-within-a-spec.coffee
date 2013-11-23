root = global

grunt = require('grunt')

specPath = "spec-e2e/tmp/example-spec.coffee"

root.createSpec = (specSource) ->
  grunt.file.write(specPath, specSource)

root.readSpec = ->
  grunt.file.read(specPath, encoding: "UTF-8")

root.runSpec = (done, callback) ->
  grunt.util.spawn
    cmd: "node_modules/.bin/testem",
    args: ["ci", "-f", "config/testem-single-spec.json"]
  , (error, stdout, code) ->
    callback.call jasmine.getEnv().currentSpec,
      error: error
      output: stdout.toString()
      code: code
    done?()

root.WhenIRunTheSpec = ->
  When (done) ->
    runSpec done, (result) ->
      @result = result
