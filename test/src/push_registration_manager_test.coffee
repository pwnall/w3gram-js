describe 'W3gram.PushRegistrationManager', ->
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

  describe '#register', ->
    it 'resolves to a PushRegistration', ->
      @manager.register().then (registration) ->
        expect(registration).to.be.an.instanceOf W3gram.PushRegistration
        expect(registration.endpoint).to.be.a 'string'
        expect(registration.endpoint).to.match(/^https?\:/)

    afterEach ->
      @manager.unregister()
