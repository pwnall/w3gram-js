# Wraps an application.
class W3gram._.App
  # Creates an app from a JSON representation.
  #
  # @param {Object} json the JSON representation returned by the W3gram
  #   server's POST /apps endpoint, augmented with the server's URL
  # @option json {Object} server the URL of the application's W3gram server
  constructor: (json) ->
    unless @apiKey = json.key
      throw new Error 'The key option must be a W3gram API key'
    @secret = json.secret or null
    @name = json.name or null
    @origin = json.origin or null

    unless serverUrl = json.server
      throw new Error 'The server option must be a W3gram server URL'
    if serverUrl.substring(serverUrl.length - 1) is '/'
      serverUrl = serverUrl.substring 0, serverUrl.length - 1
    @serverUrl = serverUrl
    @_registerUrl = "#{serverUrl}/register"
    return

  # @return {Object} JSON representation.
  toJSON: ->
    {
      name: @name, origin: @origin, key: @apiKey, secret: @secret,
      server: @serverUrl
    }

  # Registers a device for push notifications.
  #
  # @param {String} deviceId the device's ID
  # @param {String} token the device's token
  # @return {Promise<W3gram._.DeviceRegistration>} a promise that resolves to the
  #   registration data
  register: (deviceId, token) ->
    registration = { app: @apiKey, device: deviceId, token: token }
    W3gram._.jsonRequest('POST', @_registerUrl, registration).then (json) =>
      json.server = @serverUrl
      json.app = @apiKey
      json.device = deviceId
      json.token = token
      new W3gram._.DeviceRegistration json

  # Computes the token for a device ID.
  #
  # @param {String} deviceId the ID of the device whose token will be computed
  # @return {Promise<string>} a promise that resolves to the token for the
  #   device ID
  token: (deviceId) ->
    W3gram._.App.checkDeviceId(deviceId).then =>
      @checkCanCreateTokens().then =>
        W3gram._.hmac @secret, "device-id|#{deviceId}"

  # Checks if a device ID is valid.
  #
  # @param {String} deviceId the device ID to be checked
  # @return {Promise<Boolean>} a promise that resolves to true if the device ID
  #   is valid
  @checkDeviceId: (deviceId) ->
    if W3gram._.App.isValidDeviceId deviceId
      W3gram._.Promise.resolve true
    else
      W3gram._.Promise.reject new W3gram._.DOMException(
          W3gram._.DOMException.SyntaxError, 'Invalid device ID')

  # Checks if a device ID is valid.
  #
  # @param {String} deviceId the device ID to be checked
  # @return {Boolean} true if the device ID is valid, false otherwise
  @isValidDeviceId: (deviceId) ->
    return false unless deviceId.length <= 64
    /^[A-Za-z0-9_\-]+$/.test deviceId

  # Checks if this App instance has enough information to create device tokens.
  #
  # @return {Promise<Boolean>} a promise that resolves to true if the App can
  #   create tokens
  checkCanCreateTokens: ->
    if @secret
      W3gram._.Promise.resolve true
    else
      W3gram._.Promise.reject new W3gram._.DOMException(
          W3gram._.DOMException.InvalidStateError,
          'Cannot generate tokens without the app secret')
