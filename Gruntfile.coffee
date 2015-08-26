module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON('package.json'),

    sass:
      dist:
        files:
          "css/index.css": "sass/index.scss"

    connect:
      server:
        options:
          cors: true
          port: process.env.PORT or 8000
          nevercache: true
          logRequests: true

    watch:
      css:
        files: "**/*.scss"
        tasks: ["sass"]


  grunt.loadNpmTasks 'grunt-sass'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.registerTask('default', ['connect', 'watch'])
