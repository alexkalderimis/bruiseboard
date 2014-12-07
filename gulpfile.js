'use strict';

var gulp = require('gulp');
var del = require('del');
var _ = require('lodash');

var path = require('path');

// Load plugins
var $ = require('gulp-load-plugins')();
var browserify = require('browserify');
var wiredep = require('wiredep').stream;
var source = require('vinyl-source-stream');

var bowerFiles = require('main-bower-files');

var less = require('gulp-less');
var path = require('path');

var EXPRESS_PORT = 9000;
var EXPRESS_ROOT = __dirname + '/dist';
var LIVERELOAD_PORT = 35729;
var HACKS = ['/semantic-ui/dist/**/*.woff', '/semantic-ui/dist/**/*.ttf'];

// The reloader.
var reloader;

gulp.task('less', ['clean'], function () {
  gulp.src('./app/styles/**/*.less')
    .pipe(less({
      paths: [ path.join(__dirname, 'less', 'includes') ]
    }))
    .pipe(gulp.dest('./dist/styles'));
});

// CoffeeScript
gulp.task('coffee', ['coffee:client', 'coffee:server']);

gulp.task('coffee:client', ['clean'], function () {
  var patterns = ['app/scripts/**/*.coffee', '!app/scripts/**/*.js'];
  var compiler = $.coffee({ bare: true }).on('error', $.util.log);
  var outputDir = gulp.dest('build/scripts');
  return gulp.src(patterns, {base: 'app/scripts'})
             .pipe(compiler)
             .pipe(outputDir);
});

gulp.task('coffee:server', function () {
  var patterns = ['app/server/**/*.coffee', '!app/server/**/*.js'];
  var compiler = $.coffee({ bare: false }).on('error', $.util.log);
  var outputDir = gulp.dest('build/server');
  return gulp.src(patterns, {base: 'app/server'})
             .pipe(compiler)
             .pipe(outputDir);
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

// Bower helper - connect all 
gulp.task('html', ['bower'], function() {
  return gulp.src('./app/*.html')
      .pipe(wiredep())
      .pipe(gulp.dest('./dist'));
});

gulp.task('bower', ['clean'], function () {
  var bc = 'app/bower_components';
  var base = {base: bc};
  var hack = HACKS.map(function (h) { return bc + h; });
  var dest = gulp.dest('./dist/bower_components');
  var deps = require('wiredep')();
  var srcs = _.flatten([deps.js, deps.css]).concat(hack);
  return gulp.src(srcs, base).pipe(dest);
});

gulp.task('jest', function () {
  var nodeModules = path.resolve('./node_modules');
  var jestOpts = {
    scriptPreprocessor: nodeModules + '/gulp-jest/preprocessor.js',
    unmockedModulePathPatterns: [nodeModules + '/react']
  };
  return gulp.src('app/scripts/**/__tests__').pipe($.jest(jestOpts));
});

// Clean
gulp.task('clean', function (cb) {
    del(['build/**/*', 'dist/**/*'], cb);
});

// Build
gulp.task('build', ['scripts', 'less', 'html'], function () {
  notifyLivereload();
});

// Default task
gulp.task('default', ['build', 'jest' ]);

function startLiveReloadServer() {
  if (reloader) {
    reloader.close();
  }
  reloader = require('tiny-lr')();
  reloader.listen(LIVERELOAD_PORT);
  $.util.log("Started live reload server on ", LIVERELOAD_PORT);
}

// Notifies livereload of changes to the app.
function notifyLivereload(event) {
  if (!reloader) return;
  // Since we do a total rebuild each time, say that everything changed.
  reloader.changed({
    body: {
      files: ['index.html', 'scripts/app.js', 'styles/main.css']
    }
  });
}

var server, db;

process.on('SIGINT', function () {
  $.util.log('Cleaning up');
  if (server) {
    server.close();
  }
  if (db) {
    db.close();
  }
  process.exit(128 + 9);
});

gulp.task('db:connect', function connectToDB (cb) {
  if (db) {
    db.close();
  }
  var MongoClient = require('mongodb').MongoClient;
  var port = (process.env.MONGO_PORT || 27017);
  var host = (process.env.MONGO_HOST || 'localhost');
  var name = (process.env.MONGO_NAME || 'bruiseboard');
  var uri = 'mongodb://' + host + ':' + port + '/' + name;

  MongoClient.connect(uri, function (err, conn) {
    if (err) {
      $.util.log('Could not connect to db: ' + err);
    } 
    db = conn;
    cb(err);
  });
});

// Webserver
gulp.task('serve', ['coffee:server', 'db:connect'], function () {
  if (server) {
    server.close();
  }
  var prod = (!!process.env.DYNO || (process.env.ENV === 'PROD'));
  var port = (process.env.PORT || EXPRESS_PORT);
  var host = process.env.HOST || (prod ? '0.0.0.0' : 'localhost' );

  var express = require('express');
  var morgan = require('morgan');
  var app = express();
  if (!prod) {
    app.use(require('connect-livereload')());
  }
  app.use(express.static(EXPRESS_ROOT));
  app.use(morgan(prod ? 'common' : 'dev'));
  app.use(require('./build/server/routes')(__dirname, db));
  server = require('http').createServer(app);
  server.listen(port);
  $.util.log('Server started on port', port);
  if (!prod) {
    startLiveReloadServer();
  }
});

// Watch
gulp.task('watch', ['build', 'serve'], function () {

    gulp.watch('bower.json', ['html']);

    // Watch .json files
    gulp.watch('app/scripts/**/*.json', ['build']);

    // Watch .html files
    gulp.watch('app/*.html', ['build']);

    // Watch .coffeescript files
    gulp.watch('app/scripts/**/*.coffee', ['build', 'jest' ]);
    
    // Watch .coffeescript files
    gulp.watch('app/server/**/*.coffee', ['serve']);

    // Watch .js files
    gulp.watch('app/scripts/**/*.js', ['build', 'jest' ]);

    // Watch .js files
    gulp.watch('app/styles/**/*.less', ['build']);

});
