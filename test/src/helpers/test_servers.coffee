bodyParser = require 'body-parser'
cors = require 'cors'
express = require 'express'
fs = require 'fs'
http = require 'http'
W3gramServer = require 'w3gram-server'

# Sets up the test backends.
class TestServers
  constructor: ->
    @_w3gramConfig = new W3gramServer.Config(
        pg_database: 'postgres://localhost/w3gram_test')
    @_w3gramServer = @_w3gramConfig.server()

    @createApp()
    @_http = http.createServer @_app
    @_address = null

  # The root URL for XHR tests.
  testOrigin: ->
    return null unless @_address
    "http://localhost:#{@_address.port}"

  # The URL that should be used to start the tests.
  testUrl: ->
    return null unless @_address
    "http://localhost:#{@_address.port}/test/html/browser_test.html"

  # Starts listening to the test servers' sockets.
  #
  # @param {function()} callback called when the servers are ready to accept
  #   incoming connections
  # @return undefined
  listen: (callback) ->
    if @_address
      throw new Error 'Already listening'
    @_http.listen @_port, =>
      @_address = @_http.address()
      @_w3gramServer.listen callback

  # Stops listening to the test servers' sockets.
  #
  # @param {function()} callback called after the servers close their listen
  #   sockets
  # @return undefined
  close: (callback) ->
    unless @_address
      throw new Error 'Not listening'
    @_address = null
    @_http.close =>
      @_w3gramServer.close callback

  # The server code.
  createApp: ->
    @_app = express()
    @_app.use cors methods: ['POST'], maxAge: 31536000
    @_app.use bodyParser.json(
        strict: true, type: 'application/json', limit: 65536)

    ## Middleware.

    # Disable HTTP caching, for IE.
    @_app.use (request, response, next) ->
      response.header 'Cache-Control', 'no-cache'
      # For IE. Invalid dates should be parsed as "already expired".
      response.header 'Expires', '-1'
      next()

    @_app.use express.static(fs.realpathSync(__dirname + '/../../../'),
                            { dotfiles: 'allow' })

    ## Routes

    # Ends the tests.
    @_app.get '/diediedie', (request, response) =>
      if 'failed' of request.query
        failed = parseInt request.query['failed']
      else
        failed = 1
      total = parseInt request.query['total'] || 0
      passed = total - failed
      exitCode = if failed == 0 then 0 else 1
      console.info "#{passed} passed, #{failed} failed"

      response.header 'Content-Type', 'image/png'
      response.header 'Content-Length', '0'
      response.end ''
      unless 'NO_EXIT' of process.env
        @close ->
          process.exit exitCode

    # Helper for jsonRequest tests.
    @_app.all '/echo', (request, response) ->
      statusCode = request.body?._status or 200
      jsonBody =
        method: request.method
        url: request.url
        headers: request.headers
        body: request.body
      if request.body?._error
        jsonBody.error = request.body._error
      response.status(statusCode).json jsonBody

    # Resets the W3gram server's database.
    @_app.post '/reset', (request, response) =>
      @_w3gramConfig.appList().teardown (error) =>
        if error
          response.status(500).json error: 'W3gramServer.AppList#teardown'
          return
        @_w3gramConfig.appCache().reset()
        @_w3gramConfig.appList().setup (error) =>
          if error
            response.status(500).json error: 'W3gramServer.AppList#setup'
            return
          @_w3gramConfig.appCache().getMak (error, mak) =>
            if error
              response.status(500).json error: 'W3gramServer.AppCache#getMak'
              return
            response.status(200).json(url: @_w3gramServer.httpUrl(), mak: mak)

module.exports = TestServers
