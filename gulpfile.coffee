# include gulp
gulp           = require("gulp")

# include our plugins
sass           = require("gulp-sass")
shell          = require("gulp-shell")
plumber        = require("gulp-plumber")
notify         = require("gulp-notify")
minifycss      = require("gulp-minify-css")
autoprefixer   = require("gulp-autoprefixer")
concat         = require("gulp-concat")
rename         = require("gulp-rename")
uglify         = require("gulp-uglify")
assemble       = require("gulp-assemble")
coffee         = require("gulp-coffee")
clean          = require("gulp-clean")
gulpStripDebug = require("gulp-strip-debug")
browserSync    = require("browser-sync")
lr             = require("tiny-lr")
livereload     = require("gulp-livereload")
server         = lr()

# paths
src          = "src"
dest         = "dist"

#
#	 gulp tasks
#	 ==========================================================================


# clean
gulp.task "clean", ->
	gulp.src [
		dest + "/scripts/*.*"
		dest + "/styles/*.*"
		dest + "/images/*.*"
		dest + "*.html"
	]
	.pipe clean()

# copy vendor scripts
gulp.task "copy", ->
	gulp.src [
		"bower_components/jquery/dist/jquery.js"
		"bower_components/modernizr/modernizr.js"
	]
	.pipe uglify()
	.pipe gulp.dest dest + "/scripts"

# coffee
gulp.task "coffee", ->
	gulp.src src + "/scripts/**/*.coffee"
	.pipe coffee
		bare: true
	.pipe concat("scripts.js")
	.pipe gulp.dest dest + "/scripts"
	.pipe livereload(server)

# scripts
gulp.task "scripts",["coffee"], ->
	gulp.src [
		!src + "/vendor/scripts/plugins/_*.js"
		src + "/vendor/scripts/plugins/*.js"
		dest + "/scripts/scripts.js"
	]
	.pipe concat "scripts.js"
	.pipe gulp.dest dest + "/scripts"

# scripts-dist
gulp.task "scripts-dist",["coffee"], ->
	gulp.src [
		!src + "/vendor/scripts/plugins/_*.js"
		src + "/vendor/scripts/plugins/*.js"
		dest + "/scripts/scripts.js"
	]
	.pipe concat "scripts.js"
	.pipe gulpStripDebug()
	.pipe uglify()
	.pipe gulp.dest dest + "/scripts"

# styles
gulp.task "styles", ->
	gulp.src src + "/styles/styles.scss"
	.pipe plumber()
	.pipe sass
		sourceComments: "normal"
		errLogToConsole: false
		onError: (err) -> notify().write(err)
	.pipe autoprefixer("last 15 version")
	.pipe gulp.dest dest + "/styles"
	.pipe browserSync.reload({stream:true})

# styles-dist
gulp.task "styles-dist",  ->
	gulp.src src + "/styles/styles.scss"
	.pipe plumber()
	.pipe sass()
	.on "error", notify.onError()
	.on "error", (err) ->
		console.log "Error:", err
	.pipe autoprefixer("last 15 version")
	.pipe minifycss
		keepSpecialComments: 0
	.pipe gulp.dest dest + "/styles"

gulp.task "assemble", ->
	gulp.src( src + "/templates/pages/*.hbs")
	.pipe assemble
		data: src + "/data/*.json"
		partials: src + "/templates/partials/*.hbs"
		layoutdir: src + "/templates/layouts/"
	.pipe gulp.dest dest

# Proxy to existing vhost (version 0.7.0 & greater)
gulp.task "browser-sync", ->
	browserSync.init null,
		server:
			baseDir: dest
			proxy: "192.168.1.159:3002"

gulp.task 'watch', ->
	gulp.watch [src + '/scripts/**/*.coffee'], ['scripts']
	gulp.watch [src + '/styles/**/*.scss'], ['styles']
	gulp.watch [src + '/templates/**/*.hbs'], ['assemble']
	gulp.watch [src + "/vendor/scripts/plugins/*.js"], ['scripts']
	gulp.watch( src + '/templates/**/*.hbs' ).on "change", (file) ->
		livereload(server).changed file.path

#
#  main tasks
#	 ==========================================================================

# default task
gulp.task 'default', [
	"copy"
	"assemble"
	"styles"
	"scripts"
	"browser-sync"
	"watch"
]

# build task
gulp.task 'dist', [

]


