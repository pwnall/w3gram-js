# Implements the PushRegistration interface.
#
# @see http://w3c.github.io/push-api/#idl-def-PushRegistration
class W3gram.PushRegistration
  # Creates a PushRegistration that uses a W3gram notification server.
  #
  # @param {W3gram._.DeviceRegistration} deviceRegistration this device's
  #   registration data
  constructor: (deviceRegistration) ->
    @_deviceRegistration = deviceRegistration
    unless @_deviceRegistration instanceof W3gram._.DeviceRegistration
      throw new Error 'Illegal constructor'
    @registrationId = deviceRegistration.receiverId
    @endpoint = deviceRegistration.pushUrl

    @_wsClient = null
    @_canceled = false
    @_initialBackoff = 1000
    @_nextBackoff = null
    @_resolveConnected = null
    @_connected = new W3gram._.Promise (resolve) =>
      @_resolveConnected = resolve
    @_connect()

  # @property {String} the ID used to push notifications to the device
  registrationId: null

  # @property {String} the push notification server URL
  endpoint: null

  # Event triggerred when a push notification is received.
  #
  # @param {PushEvent} the push event
  onpush: null

  # Event triggerred when this push registration is lost.
  onpushregistrationlost: null

  # Stops this registration from being active.
  #
  # @return undefined
  _cancel: ->
    @_canceled = true
    if @_wsClient
      @_wsClient.close 1000, 'Receiver unregistered'
    return

  # Attempts to connect to the W3gram server.
  _connect: ->
    if @_wsClient
      new W3gram._.Promise.resolve true
    if @_canceled
      new W3gram._.Promise.reject new Error('Unregistered')

    @_nextBackoff = @_initialBackoff
    @_connectOnce()

  # Attempts to connect to the W3gram server.
  #
  # @return {Promise<Boolean>} a promise that resolves to true when the
  #   connection succeeds
  _connectOnce: ->
    @_deviceRegistration.route()
      .then (wsUrl) =>
        @_wsClient = new W3gram._.WsClient wsUrl
        @_wsClient.onNotification = @_onNotification.bind @
        @_wsClient.closed.then @_onWsClosed.bind(@)
        @_wsClient.connected
      .then =>
        @_nextBackoff = @_initialBackoff
        @_resolveConnected true
        true
      .catch (error) =>
        @_wsClient.close 4000, 'Network error'
        timeoutMs = @_nextBackoff
        @_nextBackoff *= 2
        new W3gram._.Promise (resolve) =>
          timeoutHandler = => resolve @_connect()
          setTimeout timeoutHandler, timeoutMs
        return
      return
    return

  # Called when a W3gram notification is received.
  _onNotification: (notification) ->
    return if @_canceled
    if @onpush
      @onpush W3gram._.createPushEvent(@, JSON.stringify(notification))
    return

  # Called when the W3gram connection is closed.
  _onWsClosed: ->
    @_wsClient = null
    @_connect()
    return
