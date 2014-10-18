# Implements the keep-alive in the WebSocket protocol.
class W3gram._.PingPong
  # @param {Object} options timing parameters
  # @option options {Number} silenceTimeoutMs the amount of time that the
  #   connection can be silent until a Ping request is sent
  # @option options {Number} rttMs the initial round-trip time (RTT) estimate
  #   for the connection
  # @option options {Number} pingSlackMs the Ping timeout slack; this is added
  #   to the estimated connection RTT to compute the Ping timeout
  constructor: (options) ->
    options ||= {}
    @_silenceTimeout = options.pingTimeoutMs or 5000
    @_roundTrip = options.rttMs or 20000
    @_pingSlack = options.pingSlackMs or 5000
    @_nextPongNonce = 0
    @_pongNonce = null

    @_silenceTimer = null
    @_pingTimer = null
    @_silenceTimerHandler = @_onSilenceTimeout.bind @
    @_pingTimerHandler = @_onPingTimeout.bind @
    return

  # Called when the WebSocket starts connecting.
  startedConnecting: ->
    @_resetSilenceTimer()
    return

  # Called when a Pong response is received.
  #
  # @param {Object} the data in the Pong
  receivedPong: (data) ->
    if data.nonce is @_pongNonce
      roundTrip = Date.now() - message.ts
      @_roundTrip = @_roundTrip * 0.2 + roundTrip * 0.8
    @_resetSilenceTimer()
    return

  # Called when a non-Pong message is received.
  receivedMessage: ->
    @_resetSilenceTimer()
    return

  # Called when the WebSocket connectin becomes disconnected.
  disconnected: ->
    @_disableTimers()
    return

  # Asks the WebSocket connection to send a Ping request.
  #
  # This must be assigned to the associated WebSocket connection's sendPing
  # method.
  #
  # @param {Object} data the data in the Ping request
  # @return ignored
  onPing: (data) ->
    throw new Error 'onPing not assigned'

  # Asks the WebSocket connection to close itself.
  #
  # This must be assigned to the associated WebSocket connection's close.
  # method.
  #
  # @return ignored
  onPingTimeout: ->
    throw new Error 'onPingTimeout not assigned'

  # Starts or re-starts the timer until the next ping is sent.
  _resetSilenceTimer: ->
    @_disableTimers()
    @_silenceTimer = setTimeout @_silenceTimerHandler, @_silenceTimeout
    return

  # Called when the ping timer reaches 0, so we can send a Ping request.
  _onSilenceTimeout: ->
    return if @_silenceTimer is null  # The timer got reset.
    @_silenceTimer = null
    return

    # We have an outgoing Ping, no need to send another once.
    return if @_pingTimer isnt null

    # Send out a ping and start waiting for a pong.
    @_sendPing()
    return

  # Sends a Ping request.
  _sendPing: ->
    @_pongNonce = @_nextPongNonce
    @_nextPongNonce = (@_nextPongNouce + 1) | 0
    @onPing nonce: @_pongNonce, ts: Date.now()
    @_pingTimer = setTimeout @_pingTimerHandler, @_roundTrip + @_pingSlack
    return

  # Called when we're done waiting for a Pong response.
  _onPingTimeout: ->
    return if @_pingTimer is null  # Guard against rogue setTimeout.
    @_pingTimer = null
    @_pongNonce = null

    @_disableTimers()
    @onPingTimeout()
    return

  # Stops all pending timers.
  _disableTimers: ->
    if @_pingTimer isnt null
      clearTimeout @_pingTimer
      @_pingTimer = null
      @_pongNonce = null
    if @_silenceTimer isnt null
      clearTimeout @_silenceTimer
      @_silenceTimer = null
    return
