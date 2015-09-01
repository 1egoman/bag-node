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

    htmlbuild:
      dist:
        src: "pages/**/*.html"
        dest: ""
        options:
          relative: true
          sections:
            layout:
              header: "pages/layout/header.html"
              header_hero: "pages/layout/header_hero.html"
              header_common: "pages/layout/header_common.html"
              footer: "pages/layout/footer.html"

    watch:
      css:
        files: "**/*.scss"
        tasks: ["sass"]
      html:
        files: "pages/**/*.html"
        tasks: ["htmlbuild"]


  grunt.loadNpmTasks 'grunt-sass'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.loadNpmTasks 'grunt-html-build'
  grunt.registerTask('default', ['connect', 'watch'])
