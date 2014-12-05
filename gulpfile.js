'use strict';

var gulp = require('gulp');
var del = require('del');


var path = require('path');


// Load plugins
var $ = require('gulp-load-plugins')();
var browserify = require('browserify');
var wiredep = require('wiredep').stream;
var source = require('vinyl-source-stream');

var bowerFiles = require('main-bower-files');

var less = require('gulp-less');
var path = require('path');

gulp.task('less', ['clean'], function () {
  gulp.src('./app/styles/**/*.less')
    .pipe(less({
      paths: [ path.join(__dirname, 'less', 'includes') ]
    }))
    .pipe(gulp.dest('./dist/styles'));
});

// CoffeeScript
gulp.task('coffee', ['clean'], function () {
    return gulp.src(
            ['app/scripts/**/*.coffee', '!app/scripts/**/*.js'],
            {base: 'app/scripts'}
        )
        .pipe(
            $.coffee({ bare: true }).on('error', $.util.log)
        )
        .pipe(gulp.dest('build/scripts'));
});

gulp.task('js', ['clean'], function () {
  return gulp.src(['app/scripts/**/*.js'], {base: 'app/scripts'})
             .pipe(gulp.dest('build/scripts'));
});

gulp.task('json', ['clean'], function() {
    gulp.src('app/scripts/json/**/*.json', {base: 'app/scripts'})
        .pipe(gulp.dest('build/scripts/'));
});

// Scripts
gulp.task('scripts', ['coffee', 'js', 'json'], function () {
    return browserify('./build/scripts/app.js')
            .bundle()
            .pipe(source('app.js'))
            .pipe(gulp.dest('dist/scripts'))
});

gulp.task('jade', ['clean'], function () {
    return gulp.src('app/template/*.jade')
        .pipe($.jade({ pretty: true }))
        .pipe(gulp.dest('dist'));
})

// Bower helper
gulp.task('html', ['bower'], function() {
  return gulp.src('./app/index.html')
      .pipe(wiredep())
      .pipe(gulp.dest('./dist'));
});

gulp.task('bower', ['clean'], function () {
  var base = {base: 'app/bower_components'};
  var hack = ['app/bower_components/semantic-ui/dist/**/*.woff', 'app/bower_components/semantic-ui/dist/**/*.ttf'];
  return gulp.src(hack.concat(bowerFiles()), base)
             .pipe(gulp.dest('./dist/bower_components'));
});

gulp.task('jest', function () {
    var nodeModules = path.resolve('./node_modules');
    return gulp.src('app/scripts/**/__tests__')
        .pipe($.jest({
            scriptPreprocessor: nodeModules + '/gulp-jest/preprocessor.js',
            unmockedModulePathPatterns: [nodeModules + '/react']
        }));
});



// Clean
gulp.task('clean', function (cb) {
    del(['build/**/*', 'dist/**/*'], cb);
});

// Build
gulp.task('build', ['scripts', 'less', 'html']);

// Default task
gulp.task('default', ['build', 'jest' ]);

// Webserver
gulp.task('serve', ['build'], function () {
  var port = (process.env.PORT || 9000);
  var inDevelopment = (process.env.ENV !== 'PROD');
  var webserver = $.webserver({livereload: inDevelopment, port: port});
  gulp.src('dist').pipe(webserver);
});

// Watch
gulp.task('watch', ['serve'], function () {

    gulp.watch('bower.json', ['html']);

    // Watch .json files
    gulp.watch('app/scripts/**/*.json', ['build']);

    // Watch .html files
    gulp.watch('app/*.html', ['build']);

    // Watch .jade files
    gulp.watch('app/template/**/*.jade', ['build']);

    // Watch .coffeescript files
    gulp.watch('app/scripts/**/*.coffee', ['build', 'jest' ]);

    // Watch .js files
    gulp.watch('app/scripts/**/*.js', ['build', 'jest' ]);

    // Watch .js files
    gulp.watch('app/styles/**/*.less', ['build']);

});
