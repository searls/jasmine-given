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

libConfig = require('./lib')

module.exports = (lineman) ->
  grunt = lineman.grunt
  _ = grunt.util._
  app = lineman.config.application

  app.appendTasks.dist.push("writeBowerJson") if libConfig.generateBowerJson

  app.uglify.js.files = _({}).tap (config) ->
    config["dist/#{grunt.file.readJSON('package.json').name}.min.js"] = "<%= files.js.uncompressedDist %>"

  loadNpmTasks: ["grunt-jasmine-bundle", "grunt-write-bower-json", "grunt-contrib-concat"]

  meta:
    banner: """
            /* <%= pkg.name %> - <%= pkg.version %>
             * <%= pkg.description || pkg.description %>
             * <%= pkg.homepage %>
             */

            """

  hooks:
    loadNpmTasks:
      afterLoad:
        "grunt-jasmine-bundle": ->
          grunt.renameTask("spec", "nodeSpec")

  removeTasks:
    common: ["less", "handlebars", "jst", "concat_sourcemap", "images:dev", "webfonts:dev", "pages:dev"]
    dev: ["server"]
    dist: ["cssmin", "images:dist", "webfonts:dist", "pages:dist"]

  appendTasks:
    common: ["concat"]

  nodeSpec:
    e2e:
      options:
        minijasminenode:
          showColors: true
        helpers: "spec-e2e/helpers/**/*.{js,coffee}"
        specs: ["spec-e2e/**/*.{js,coffee}", "!spec-e2e/tmp/**"]

  concat:
    uncompressedDist:
      options:
        banner: "<%= meta.banner %>"
      src: _([
        ("<%= files.js.vendor %>" if libConfig.includeVendorInDistribution),
        "<%= files.coffee.generated %>",
        "<%= files.js.app %>"
      ]).compact()
      dest: "<%= files.js.uncompressedDist %>"


