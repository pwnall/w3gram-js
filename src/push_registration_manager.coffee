# Implements the PushRegistrationManager interface.
#
# @see http://w3c.github.io/push-api/#idl-def-PushRegistrationManager
class W3gram.PushRegistrationManager
  # Creates a PushRegistrationManager that uses a W3gram notification server.
  #
  # @param {Object} options the W3gram API credentials for this receiver
  # @option options {String} server the root URL of the W3gram server
  # @option options {String} key the Web application's W3gram API key
  # @option options {String} device this receiver's device ID
  # @option options {String} token the server-issued token for this receiver's
  #   device ID
  # @option options {Object} timing advanced timing options passed to
  #   {W3gram.PushRegistration} and to {W3gram._.WsClient}
  constructor: (options) ->
    unless options.server
      throw new Error 'The server option must be a W3gram server URL'
    unless options.key
      throw new Error 'The key option must be a W3gram API key'
    unless @_deviceId = options.device
      throw new Error 'The device option must be a device ID'
    unless @_token = options.token
      throw new Error "The token option must be the device ID's token"

    @_registration = null
    @_app = new W3gram._.App server: options.server, key: options.key
    @_timing = options.timing or {}
    return

  # Registers this device with the Push Notification server.
  #
  # @return {Promise<PushRegistration>} a promise that resolves to the existing
  #   or newly created registration
  register: ->
    unless @_registration is null
      return W3gram._.Promise.resolve @_registration

    @_app.register(@_deviceId, @_token).then (registration) =>
      unless @_registration
        @_registration = new W3gram.PushRegistration registration, @_timing
        # TODO(pwnall): store registration info
      @_registration._connected.then =>
        @_registration

  # Unregisters this device from the Push Notification server.
  #
  # @return {Promise<PushRegistration>} the details of the registration that
  #   was removed
  unregister: ->
    # TODO(pwnall): stop the WebSocket connection
    if @_registration
      registration = @_registration
      @_registration = null
      registration._cancel()
      W3gram._.Promise.resolve registration
      return

    error = new W3gram._.DOMException(W3gram._.DOMException.NotFoundError,
        'No compatible W3gram registration found on this device')
    W3gram._.Promise.reject error

  # Retrieves a previous registration for this device.
  #
  # @return {Promise<PushRegistration>} a promise that resolves to the existing
  #   registration
  getRegistration: ->
    if @_registration
      W3gram._.Promise.resolve @_registration
      return

    error = new W3gram._.DOMException(W3gram._.DOMException.NotFoundError,
        'No compatible W3gram registration found on this device')
    W3gram._.Promise.reject error

  # Tells the application that it can always use the W3gram service.
  hasPermission: ->
    W3gram._.Promise.resolve 'granted'

