WsClient = W3gram._.WsClient

describe 'W3gram._.WsClient', ->
  beforeEach ->
    @sandbox = sinon.sandbox.create()
    W3gram._.jsonRequest('POST', "#{testXhrServer}/reset")
      .then (json) =>
        @serverUrl = json.url
        @serverMak = json.mak
        appOptions = name: 'App#register Test', origin: '*'
        @server = new W3gram._.Server @serverUrl
        @server.createApp @serverMak, appOptions
      .then (app) =>
        @app = app
        @deviceId = 'tablet-device-id'
        @app.token @deviceId
      .then (token) =>
        @token = token
        @app.secret = null
        @app.register @deviceId, @token
      .then (registration) =>
        @registration = registration
        @registration.route()
      .then (wsUrl) =>
        @wsUrl = wsUrl

  afterEach ->
    @sandbox.restore()


  describe 'with hyper-ping settings', ->
    beforeEach ->
      @wsClient = new WsClient @wsUrl,
          silenceTimeoutMs: 10, pingSlackMs: 20, rttMs: 20

    it 'sends 8-10 pings in 100ms', (done) ->
      @wsClient.connected.then =>
        pingSpy = @sandbox.spy @wsClient, 'sendPing'
        closeSpy = @sandbox.spy @wsClient, 'close'
        onTimeout = =>
          expect(closeSpy.callCount).to.equal 0
          expect(pingSpy.callCount).to.be.at.least 8
          expect(pingSpy.callCount).to.be.at.most 10
          done()
        setTimeout onTimeout, 100
      null
