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
    },

    coverage: {
      coverage: {},
          files: [
              {
                  src: '**/*.js',
                  expand: true,
                  cwd: 'dest',
                  dest: 'test/src'
              }
          ],
      instrument: {
          ignore: [],
          files: [
              {
                  src: '**/*.js',
                  expand: true,
                  cwd: 'dest',
                  dest: 'test/src'
              }
          ]
      },
      report: {
          reports: ['html', 'text-summary'],    /* [5] */
          dest: 'coverage'                      /* [6] */
      }
    }
  });

  grunt.event.on('coverage', function(coverage, done){
    // send coverage info
    grunt.config('coverage.coverage', coverage);
    done();
  });

// Here we define the coverage task, it will have two targets: instrument and report
grunt.registerMultiTask('coverage', 'Generates coverage reports for JS using Istanbul', function () {
    switch(this.target) {
    case 'instrument':
        // In the target configuration it is possible to exclude certain files like
        // third party libraries
        var ignore = this.data.ignore || [];

        // Create a new instrumenter
        var istanbul = require("istanbul")
        var instrumenter = new istanbul.Instrumenter();

        // In the target configuration you need to specify the files to cover, here
        // we will loop over all the files
        grunt.file.expand({}, "dist/**/*.js").forEach(function (file) {

            // 1: Get the filename for the current file
            // 2: Read the file from disk, even if it might be a file we instructed
            //    Istanbul to ignore. It will still get written to the output folder
              var filename = file
              var instrumented = grunt.file.read(filename);   /* [2] */
              // Only instrument this file if it is not in ignored list
              if (!grunt.file.isMatch(ignore, filename)) {
                  // Instruct the instrumenter to work its magic on the file
                  instrumented = instrumenter.instrumentSync(instrumented, filename);
              }
              // Write the file to its destination
              grunt.file.write(file.replace("dist", "test/cover_dist"), instrumented);
          });
          break;
      case 'report':
          // We need config property coverage.coverage to be present, if it is not
          // present this will fail the task
          this.requiresConfig('coverage.coverage');

          // 1: In the target configuration you can set the reporters to use when
          //    generating the report.
          // 2: In the target configuration you can set the folder in which the
          //    report(s) will be stored.
          var istanbul = require("istanbul")
          var Report = istanbul.Report,
              Collector = istanbul.Collector,
              reporters = this.data.reports,    /* [1] */
              dest = this.data.dest,            /* [2] */
              collector = new Collector();

          // Fetch the coverage object we saved earlier
          collector.add(grunt.config('coverage.coverage'));

          // Iterate over all reporters
          reporters.forEach(function (reporter) {
              // Create a report at the specified location for the current reports
              Report.create(reporter, {
                  dir: dest + '/' + reporter
              }).writeReport(collector, true);
          });
          break;
      default:
          // The target is neither instrument nor report, display a friendly warning message
          grunt.warn('The target "' + this.target + '" is an invalid target. Valid targets are "instrument" and "report"');
          break;
      }
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

  grunt.registerTask('cover', [
    'clean',
    'coffee',
    'coverage:instrument',
    'test',
    'coverage:report'
  ]);

  grunt.registerTask('heroku', [
    'clean',
    'coffee'
  ]);
};
