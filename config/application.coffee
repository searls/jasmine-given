# Exports a function which returns an object that overrides the default &
#   plugin grunt configuration object.
#
# You can familiarize yourself with Lineman's defaults by checking out:
#
#   - https://github.com/testdouble/lineman/blob/master/config/application.coffee
#   - https://github.com/testdouble/lineman/blob/master/config/plugins
#
# You can also ask Lineman's about config from the command line:
#
#   $ lineman config #=> to print the entire config
#   $ lineman config concat.js #=> to see the JS config for the concat task.
#
# lineman-lib-template config options can be found in "config/lib.json"

module.exports = (lineman) ->
  grunt = lineman.grunt
  _ = grunt.util._
  app = lineman.config.application

  loadNpmTasks: app.loadNpmTasks.concat("grunt-jasmine-bundle")

  hooks:
    loadNpmTasks:
      afterLoad:
        "grunt-jasmine-bundle": ->
          grunt.renameTask("spec", "nodeSpec")

  plugins:
    lib:
      includeVendorInDistribution: true

  nodeSpec:
    e2e:
      options:
        minijasminenode:
          showColors: true
        helpers: "spec-e2e/helpers/**/*.{js,coffee}"
        specs: ["spec-e2e/**/*.{js,coffee}", "!spec-e2e/tmp/**"]
