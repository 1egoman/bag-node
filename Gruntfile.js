'use strict';

module.exports = function (grunt) {
  // load all grunt tasks
  require('matchdep').filterDev('grunt-*').forEach(function(contrib) {
    grunt.log.ok([contrib + " is loaded"]);
    grunt.loadNpmTasks(contrib);
  });

  var config = {
    dist: 'dist',
    src: 'src',
    distTest: 'test/dist',
    srcTest: 'test/src'
  };

  // Project configuration.
  grunt.initConfig({
    config: config,
    clean: {
      dist: {
        files: [
          {
            dot: true,
            src: [
              '<%= config.dist %>/*',
              '<%= config.distTest %>/*',
              '!<%= config.dist %>/.git*'
            ]
          }
        ]
      },
    },
    coffee: {
      dist: {
        files: [{
          expand: true,
          cwd: '<%= config.src %>',
          src: '{,*/}*.coffee',
          dest: '<%= config.dist %>',
          ext: '.js'
        }]
      },
      frontend: {
        files: [{
          expand: true,
          cwd: 'public',
          src: '*.coffee',
          dest: 'public/dist',
          ext: '.js'
        }]
      },
      test: {
        files: [{
          expand: true,
          cwd: '<%= config.srcTest %>',
          src: '{,*/}*.coffee',
          dest: '<%= config.distTest %>',
          ext: '.spec.js'
        }]
      }
    },
    jshint: {
      options: {
        jshintrc: '.jshintrc'
      },
      gruntfile: {
        src: 'Gruntfile.js'
      },
    },
    watch: {
      gruntfile: {
        files: '<%= jshint.gruntfile.src %>',
        tasks: ['jshint:gruntfile']
      },
      dist: {
        files: '<%= config.src %>/*',
        tasks: ['coffee:dist', 'simplemocha:backend']
      },
      test: {
        files: '<%= config.srcTest %>/specs/*',
        tasks: ['coffee:test', 'simplemocha:backend']
      },
      frontend: {
        files: "public/*.coffee",
        tasks: ['coffee:frontend']
      }
    },
    simplemocha: {
      options: {
        globals: [
        'sinon',
        'chai',
        'should',
        'expect',
        'assert',
        'AssertionError',
        'Promise',
        'projection'
        ],
        timeout: 3000,
        ignoreLeaks: false,
        // grep: '*.spec',
        ui: 'bdd',
        reporter: 'spec'
      },
      backend: {
        src: [
          // add chai and sinon globally
          'test/support/globals.js',

          // tests
          'test/dist/**/*.spec.js',
          'test/dist/**/spec_helper.js',
        ],
      },
      payments: {
        src: [
          // add chai and sinon globally
          'test/support/globals.js',

          // tests
          'test/dist/**/payments.spec.js',
          'test/dist/**/spec_helper.js',
        ],
      },
      bag: {
        src: [
          // add chai and sinon globally
          'test/support/globals.js',

          // tests
          'test/dist/**/bag.spec.js',
          'test/dist/**/spec_helper.js',
        ],
      },
    },
    // coverage: {
    //   default: {
    //     options: {
    //       thresholds: {
    //         statements: 90,
    //         branches: 90,
    //         lines: 90,
    //         functions: 90
    //       },
    //       dir: 'coverage',
    //       root: 'test'
    //     }
    //   }
    // }
    mocha_istanbul: {
      coverage: {
        src: './test/dist/specs/**', // a folder works nicely
        options: {
          mask: '*.spec.js'
        }
      }
    }
  });

  grunt.event.on('coverage', function(lcovFileContents, done){
    // send coverage info
    done();
  });

  grunt.registerTask('coverageBackend', 'Test backend files as well as code coverage.', function () {
    var done = this.async();

    var path = 'support/runner.js';

    var options = {
      cmd: 'istanbul',
      grunt: false,
      args: [
        'cover',
        // '--default-excludes',
        // '-x', 'app#<{(|*',
        // '--report', 'lcov',
        // '--dir', './coverage/backend',
        path
      ],
      opts: {
        // preserve colors for stdout in terminal
        stdio: 'inherit',
      },
    };

    function doneFunction(error, result) {
      if (result && result.stderr) {
        process.stderr.write(result.stderr);
      }

      if (result && result.stdout) {
        grunt.log.writeln(result.stdout);
      }

      // abort tasks in queue if there's an error
      done(error);
    }

    grunt.util.spawn(options, doneFunction);
  });


  // Default task.
  grunt.registerTask('default', ['coffee', 'jshint']);

  grunt.registerTask('test', [
    'clean',
    'coffee',
    'simplemocha:backend',
  ]);

  // register test groups
  Object.keys(grunt.config.get("simplemocha")).forEach(function(k) {
    if (k === "options") return
    grunt.registerTask('test:'+k, [
      'clean',
      'coffee',
      'simplemocha:'+k,
    ]);
  })


  grunt.registerTask('coverage', [
    'clean',
    'coffee',
    'coverageBackend'
  ]);

  grunt.registerTask('heroku', [
    'clean',
    'coffee'
  ]);
};
