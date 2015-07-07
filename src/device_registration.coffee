# Wraps a registration.
class W3gram._.DeviceRegistration
  # Creates a registration from a JSON representation.
  #
  # @param {Object} json the JSON representation returned by the W3gram
  #   server's POST /register endpoint, augmented with data from the POST call
  constructor: (json) ->
    @pushUrl = json.push
    @routeUrl = json.route
    return

  # Pushes a notification to the device.
  #
  # @param {Object} message the message to be pushed
  # @return {Promise<Boolean>} a promise that will resolve to true when the
  #   message is accepted by the push server
  push: (message) ->
    W3gram._.jsonRequest('POST', @pushUrl, message: message).then ->
      true

  # Obtains the device's listen WebSocket URL.
  #
  # @return {Promise<String>} a promise that will resolve to the WebSocket URL
  #   that the client should connect to
  route: ->
    W3gram._.jsonRequest('POST', @routeUrl, {}).then (json) ->
      json.listen

  # @return {Object} JSON representation
  toJSON: ->
    {
      push: @pushUrl, route: @routeUrl,
    }
