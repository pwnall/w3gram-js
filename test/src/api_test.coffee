describe 'W3gram', ->
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

  describe '.setupPushManager', ->
    beforeEach ->
      W3gram.setupPushManager @info

    it 'sets .pushRegistrationManager', ->
      expect(W3gram.pushRegistrationManager).to.be.an.instanceOf(
          W3gram.PushRegistrationManager)
