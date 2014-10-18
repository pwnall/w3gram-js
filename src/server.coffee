# Wraps information about a W3gram server.
class W3gram._.Server
  # @param {String} serverUrl the root server URL, e.g.
  #   "https://w3gram-test.herokuapp.com/"
  constructor: (serverUrl) ->
    if serverUrl.substring(serverUrl.length - 1) is '/'
      serverUrl = serverUrl.substring 0, serverUrl.length - 1
    @serverUrl = serverUrl
    @_makUrl = "#{serverUrl}/mak"
    @_appsUrl = "#{serverUrl}/apps"
    return

  # Fetches the Master Authorization Key from the server.
  #
  # @return {Promise<String>} a promise that resolves to the server's MAK
  getMak: ->
    W3gram._.jsonRequest('GET', "#{@serverUrl}/mak").then (json) -> json.mak

  # Creates an application.
  #
  # @param {String} mak the server's MAK
  # @param {Object} options application properties
  # @option options {String} name the application's name
  # @option options {String} origin the (only) allowed Origin header value; the
  #   default is '*' which allows all Origin values
  # @return {Promise<W3gram._.App>} a promise that will resolve to the newly
  #   created application
  createApp: (mak, options) ->
    app =
      name: options.name
      origin: options.origin || '*'
    W3gram._.jsonRequest('POST', @_appsUrl, mak: mak, app: app).then (json) =>
      json.server = @serverUrl
      new W3gram._.App json

