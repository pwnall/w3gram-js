# Wraps a registration.
class W3gram._.DeviceRegistration
  # Creates a registration from a JSON representation.
  #
  # @param {Object} json the JSON representation returned by the W3gram
  #   server's POST /register endpoint, augmented with data from the POST call
  # @option json {String} server the W3gram server's URL
  # @option json {String} app the application's API key
  # @option json {String} device the device's ID
  # @option json {String} token the token for the device's ID
  constructor: (json) ->
    @pushUrl = json.push
    @receiverId = json.receiver

    @apiKey = json.app
    @deviceId = json.device
    @token = json.token

    serverUrl = json.server
    if serverUrl.substring(serverUrl.length - 1) is '/'
      serverUrl = serverUrl.substring 0, serverUrl.length - 1
    @serverUrl = serverUrl
    @_routeUrl = "#{serverUrl}/route"
    return

  # Pushes a notification to the device.
  #
  # @param {Object} message the message to be pushed
  # @return {Promise<Boolean>} a promise that will resolve to true when the
  #   message is accepted by the push server
  push: (message) ->
    pushOptions = { receiver: @receiverId, message: message }
    W3gram._.jsonRequest('POST', @pushUrl, pushOptions).then ->
      true

  # Obtains the device's listen WebSocket URL.
  #
  # @return {Promise<String>} a promise that will resolve to the WebSocket URL
  #   that the client should connect to
  route: ->
    routeOptions =
        app: @apiKey, device: @deviceId, receiver: @receiverId, token: @token
    W3gram._.jsonRequest('POST', @_routeUrl, routeOptions).then (json) ->
      json.listen

  # @return {Object} JSON representation
  toJSON: ->
    {
      push: @pushUrl, receiver: @receiverId,
      server: @serverUrl, app: @apiKey, device: @deviceId, token: @token
    }
