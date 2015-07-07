# Implements the PushRegistration interface.
#
# @see http://w3c.github.io/push-api/#idl-def-PushRegistration
class W3gram.PushRegistration
  # Creates a PushRegistration that uses a W3gram notification server.
  #
  # @param {W3gram._.DeviceRegistration} deviceRegistration this device's
  #   registration data
  # @param {Object} options timing parameters
  # @option options {Number} firstReconnectMs the amount of time to wait until
  #   re-connecting when a connection drops; this amount of time is doubled on
  #   repeated failures, and is reset when a successful connection is
  #   established
  # @option options {Number} maxReconnectMs the maximum amount of time to wait
  #   until re-connecting when a connection drops; this is a cap on the
  #   doubling process documented above
  constructor: (deviceRegistration, options) ->
    @_deviceRegistration = deviceRegistration
    unless @_deviceRegistration instanceof W3gram._.DeviceRegistration
      throw new Error 'Illegal constructor'
    @endpoint = deviceRegistration.pushUrl

    @_options = options
    @_wsClient = null
    @_canceled = false
    @_initialBackoff = options.firstReconnectMs || 1000
    @_maxBackoff = options.maxReconnectMs || 30000
    @_nextBackoff = @_initialBackoff
    @_resolveConnected = null
    @_connected = new W3gram._.Promise (resolve) =>
      @_resolveConnected = resolve

    @_boundOnNotification = @_onNotification.bind @
    @_boundOnWsClosed = @_onWsClosed.bind @
    @_connect()

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
      return W3gram._.Promise.resolve true
    if @_canceled
      return W3gram._.Promise.reject new Error('Unregistered')
    @_connectOnce()

  # Attempts to connect to the W3gram server.
  #
  # @return {Promise<Boolean>} a promise that resolves to true when the
  #   connection succeeds
  _connectOnce: ->
    @_deviceRegistration.route()
      .then (wsUrl) =>
        @_wsClient = new W3gram._.WsClient wsUrl, @_options
        @_wsClient.onNotification = @_boundOnNotification
        @_wsClient.closed.then @_boundOnWsClosed
        @_wsClient.connected
      .then =>
        @_nextBackoff = @_initialBackoff
        @_resolveConnected true
        true
      .catch (error) =>
        @_wsClient.close 4000, 'Network error' if @_wsClient
        timeoutMs = @_nextBackoff
        @_nextBackoff *= 2
        if @_nextBackoff > @_maxBackoff
          @_nextBackoff = @_maxBackoff
        new W3gram._.Promise (resolve) =>
          timeoutHandler = => resolve @_connect()
          setTimeout timeoutHandler, timeoutMs
      return
    return

  # Called when a W3gram notification is received.
  _onNotification: (notification) ->
    return if @_canceled
    if @onpush
      @onpush W3gram._.createPushEvent(@, JSON.stringify(notification))
    return

  # Called when the W3gram connection is closed.
  _onWsClosed: (closeInfo) ->
    if closeInfo.client isnt @_wsClient
      return
    @_wsClient = null
    @_connect()
    return
