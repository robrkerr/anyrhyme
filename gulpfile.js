var gulp = require('gulp');
var gutil = require('gulp-util');
var sass = require('gulp-ruby-sass');
// var uglify = require('gulp-uglify');
var watch = require('gulp-watch');
var concat = require('gulp-concat');
var coffee = require('gulp-coffee');

gulp.task('sass', function () {
  gulp.src('./css/**/*.scss')
	  .pipe(sass({ 
      noCache: true,
      style: "expanded",
      lineNumbers: true,
      loadPath: './css/*'
    }))
    .pipe(gulp.dest('./css'));
});

gulp.task('js', function() {
  gulp.src('./js/app.coffee')
    .pipe(coffee({bare: true}).on('error', gutil.log))
	  .pipe(concat("app.js"))
    .pipe(gulp.dest('./js'));
});

gulp.task('watch', function() {
  gulp.watch('./css/*.scss', function() {
    gulp.run('sass');
  });
  gulp.watch('./js/**/*.coffee', function() {
    gulp.run('js');
  });
});

gulp.task('default', ['sass', 'js', 'watch']);
