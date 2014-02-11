express = require 'express'
stylus = require 'stylus'
coffeescript = require 'coffee-middleware'
routes = require './routes'
api = require './routes/api'

app = module.exports = express()

app.configure 'development', ->
  app.use express.errorHandler(dumpExceptions: true, showStack: true)

app.configure 'production', ->
  app.use express.errorHandler()

app.configure ->
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use stylus.middleware src: __dirname + '/public'
  app.use coffeescript src: __dirname + '/public'
  app.use express.static(__dirname + '/public')
  app.use express.static(__dirname + '/bower_components')
  app.use app.router

app.get '/', routes.index
app.get '/show/*', routes.show
app.get '/partials/:name', routes.partials

app.get '/api/name', api.name

app.get '*', routes.index

app.listen 3000, ->
  console.log "Express server listening on port %d in %s mode", this.address().port, app.settings.env
