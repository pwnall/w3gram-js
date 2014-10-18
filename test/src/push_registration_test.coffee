describe 'W3gram.PushRegistration', ->
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
