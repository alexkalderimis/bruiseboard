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

var HACKS = ['/**/modernizr.js', '/semantic-ui/dist/**/*.woff', '/semantic-ui/dist/**/*.ttf'];

gulp.task('bower', ['clean'], function () {
  var bc = 'app/bower_components';
  var base = {base: bc};
  var hack = HACKS.map(function (h) { return bc + h; });
  var dest = gulp.dest('./dist/bower_components');
  return gulp.src(hack.concat(bowerFiles()), base).pipe(dest);
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
gulp.task('serve', [], function () {
  var prod = (!!process.env.DYNO || (process.env.ENV === 'PROD'));
  var port = (process.env.PORT || 9000);
  var host = process.env.HOST || (prod ? '0.0.0.0' : 'localhost' );
  var webserver = $.webserver({
    livereload: !prod,
    port: port,
    host: host
  });
  gulp.src('dist').pipe(webserver);
});

// Watch
gulp.task('watch', ['build', 'serve'], function () {

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
