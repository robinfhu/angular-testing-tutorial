module.exports = (grunt)->
    grunt.initConfig
        karma:
            examples:
                options:
                    # Configures which web browser to run tests in.
                    browsers: ['Firefox']

                    # Adds the testing framework
                    frameworks: ['mocha', 'sinon-chai']

                    # Configures how the test output looks like
                    reporters: [ 'spec', 'junit', 'coverage' ]
                    junitReporter:
                        outputFile: 'karma.xml'
                    singleRun: true

                    # List out the files we want to test.
                    preprocessors:
                        'example*/**/test.coffee': ['coffee']
                    files: [
                        'example*/**/test.coffee'
                    ]

    grunt.loadNpmTasks 'grunt-karma'
    grunt.registerTask 'default', ['karma']