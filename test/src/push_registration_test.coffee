describe 'W3gram.PushRegistration', ->
  beforeEach ->
    @sandbox = sinon.sandbox.create()
  afterEach ->
    @sandbox.restore()

  describe 'with a good server', ->
    beforeEach ->
      W3gram._.jsonRequest('POST', "#{testXhrServer}/reset")
        .then (json) =>
          @info = { server: json.url }
          serverMak = json.mak
          appOptions = name: 'App#register Test', origin: '*'
          server = new W3gram._.Server @info.server
          server.createApp serverMak, appOptions
        .then (app) =>
          @info.key = app.apiKey
          @info.device = 'tablet-device-id'
          app.token @info.device
        .then (token) =>
          @info.token = token
          @manager = new W3gram.PushRegistrationManager @info
          @manager.register()
        .then (registration) =>
          @registration = registration
          expect(@registration).to.be.an.instanceOf W3gram.PushRegistration
          @registration._connected

    afterEach ->
      @manager.unregister()

    describe '#onpush', ->
      it 'is fired when a notification is received', (done) ->
        gotData = false
        @registration.onpush = (event) =>
          expect(gotData).to.equal false
          gotData = true
          expect(event.name).to.equal 'PushEvent'
          expect(event.target).to.equal @registration
          expect(event.data).to.be.a 'string'
          json = JSON.parse event.data
          expect(json.answer).to.equal 42
          done()
        pushData =
          receiver: @registration.registrationId,
          message: { answer: 42 }
        W3gram._.jsonRequest('POST', @registration.endpoint, pushData)
          .catch (error) ->
            expect(error).not.to.be.ok

    describe '#_connect', ->
      it 'does not reconnect when already connected', (done) ->
        routeSpy = @sandbox.spy @registration._deviceRegistration, 'route'
        @registration._connect()
        onTimeout = ->
          expect(routeSpy.callCount).to.equal 0
          done()
        setTimeout onTimeout, 100

  describe 'when the server is down', ->
    beforeEach ->
      @deviceRegistration = new W3gram._.DeviceRegistration(
          server: 'http://0.0.0.0/', push: 'http://0.0.0.0/push',
          app: 'app-key', device: 'device-id', token: 'device-token',
          receiver: 'receiver-id')

    it 'reconnects 7-10 times in 100ms w/o exponential backoff', (done) ->
      routeSpy = @sandbox.spy @deviceRegistration, 'route'
      @registration = new W3gram.PushRegistration @deviceRegistration,
          firstReconnectMs: 10, maxReconnectMs: 10
      onTimeout = =>
        expect(routeSpy.callCount).to.be.at.least 7
        expect(routeSpy.callCount).to.be.at.most 10
        @registration._cancel()
        done()
      setTimeout onTimeout, 100

    it 'reconnects 3-5 times in 100ms w/ exponential backoff', (done) ->
      routeSpy = @sandbox.spy @deviceRegistration, 'route'
      @registration = new W3gram.PushRegistration @deviceRegistration,
          firstReconnectMs: 10
      onTimeout = =>
        expect(routeSpy.callCount).to.be.at.least 3
        expect(routeSpy.callCount).to.be.at.most 5
        @registration._cancel()
        done()
      setTimeout onTimeout, 100

    it 'does not connect after the registration is canceled', (done) ->
      routeSpy = @sandbox.spy @deviceRegistration, 'route'
      @registration = new W3gram.PushRegistration @deviceRegistration,
          firstReconnectMs: 10, maxReconnectMs: 10
      @registration._cancel()
      onTimeout = =>
        expect(routeSpy.callCount).to.equal 1
        done()
      setTimeout onTimeout, 100
