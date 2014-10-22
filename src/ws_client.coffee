# WebSocket client specialized for reciving W3gram push notifications.
#
# A client uses the WebSocket URL given in the constructor. However, the W3gram
# protocol requires a routing HTTP request before each WebSocket connection.
# Therefore, once disconnected, this client cannot be reconnected.
class W3gram._.WsClient
  # Creates a WebSocket client that can connect to a WebSocket URL once.
  #
  # @param {String} wsUrl the WebSocket URL
  # @param {Object} options timing parameters
  # @option options {Number} silenceTimeoutMs the amount of time that the
  #   connection can be silent until a Ping request is sent
  # @option options {Number} rttMs the initial round-trip time (RTT) estimate
  #   for the connection
  # @option options {Number} pingSlackMs the Ping timeout slack; this is added
  #   to the estimated connection RTT to compute the Ping timeout
  constructor: (wsUrl, options) ->
    @_wsUrl = wsUrl
    @_ws = null
    @_pingPong = new W3gram._.PingPong options
    @_pingPong.onPing = (data) =>
      @sendPing data
    @_pingPong.onPingTimeout = =>
      @close 4000, 'Ping timeout'

    @_resolveClosed = null
    @_resolveConnected = null
    @connected = null
    @closed = new W3gram._.Promise (resolve) =>
      @_resolveClosed = resolve
      @connected = new W3gram._.Promise (resolve) =>
        @_resolveConnected = resolve
        @_connect()
        return
      return
    return

  # Disconnect the underlying WebSocket connection.
  #
  # @param {Number} code the WebSocket close code
  # @param {String} message the WebSocket close reason
  # @return undefined
  close: (code, message) ->
    return if @_ws is null

    @_ws.onclose = null
    @_ws.onerror = null
    @_ws.onmessage = null
    @_ws.onopen = null

    code or= 1000
    if code > 1000 and code < 3000
      # NOTE: when the server closes the WebSocket first, we try to close it
      #       with the same code; this causes a security error in the browser
      #       if the server uses 1xxx codes
      code = 1000
    @_ws.close code, message
    @_ws = null

    @_pingPong.disconnected()
    @_resolveClosed code: code, reason: message
    return

  # Sends a Ping request to the W3gram server.
  #
  # This API is for the socket's associated {W3gram._.PingPong} keep-alive
  # implementation.
  #
  # @param {Object} message JSON-compatible Ping data
  # @return undefined
  sendPing: (data) ->
    return unless @_ws
    @_ws.send JSON.stringify(type: 'ping', data: data)
    return

  # @property {Promise<Object>} promise that is resolved when the WebSocket is
  #   connected to the server
  connected: null

  # @property {Promise<Object>} promise that is resolved when the connection is
  #   closed
  closed: null

  # Called when a Push Notification is received.
  #
  # @param {Object} notification the contents of the notification
  # @return ignored
  onNotification: (notification) ->
    return

  # Initiates the WebSocket connection.
  _connect: ->
    return if @_ws isnt null

    @_ws = new W3gram._.WebSocket @_wsUrl
    @_ws.onclose = @_onSocketClose.bind @
    @_ws.onerror = @_onSocketError.bind @
    @_ws.onmessage = @_onSocketMessage.bind @
    @_ws.onopen = @_onSocketOpen.bind @
    @_pingPong.startedConnecting()
    return

  # Called when a message is received from the W3gram server.
  #
  # @param {Object} message the decoded JSON message
  # @return undefined
  _onMessage: (message) ->
    type = message.type
    if type is 'pong'
      @_pingPong.receivedPong message.data
      return
    @_pingPong.receivedMessage()
    if type is 'note'
      @onNotification message.data
      return
    if type is 'hi'
      @_resolveConnected true
      return
    @_close 4400, "Invalid message type: #{type}"
    return

  # Called when the WebSocket is closed.
  _onSocketClose: (closeEvent) ->
    if @_ws isnt null
      # The code / reason will be ignored by the close call, but they will be
      # relayed to the onDisconnect listener.
      @close closeEvent.code, closeEvent.reason
    return

  # Called when an internal error occurs in the WebSocket code.
  _onSocketError: (error) ->
    if @_ws isnt null
      @close 4000, event.message
    return

  # Called when a WebSocket frame is received.
  _onSocketMessage: (event) ->
    return unless @_ws
    messageText = event.data
    message = null
    try
      message = JSON.parse messageText
    catch jsonError
      @close 4400, 'Invalid JSON message'

    @_onMessage message
    return

  # Called when the WebSocket becomes open.
  _onSocketOpen: ->
    # This doesn't work cross-browser, so we wait for the server to send a 'hi'
    # request.
    return
