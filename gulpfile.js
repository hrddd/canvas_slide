var gulp = require('gulp');
var compass = require('gulp-compass');
var coffee = require('gulp-coffee');
var gutil = require('gulp-util');
 
// compass
gulp.task('compass', function() {
    gulp.src('./resource/scss/**/*.scss').pipe(compass({
        config_file: './config.rb',
        comments: false,
        css: './public/css/',
        sass: './resource/scss/'
    }));
});

gulp.task('coffee', function() {
  gulp.src('./resource/coffee/**/*.coffee')
    .pipe(coffee({bare: true}).on('error', gutil.log))
    .pipe(gulp.dest('./public/js/'))
});

// watch
gulp.task('watch-sass', ['compass'], function() {
    var watcher = gulp.watch('./resource/scss/**/*.scss', ['compass']);
    watcher.on('change', function(event) {
      console.log('File ' + event.path + ' was ' + event.type + ', running tasks...');
    });
});

gulp.task('watch-coffee', ['coffee'], function() {
    var watcher = gulp.watch('./resource/coffee/**/*.coffee', ['coffee']);
    watcher.on('change', function(event) {
      console.log('File ' + event.path + ' was ' + event.type + ', running tasks...');
    });
});

//default
gulp.task('default', ['watch-sass', 'watch-coffee']);