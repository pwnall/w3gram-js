App = W3gram._.App

describe 'W3gram._.App', ->
  beforeEach ->
    @app = new App(
      name: 'Example App', origin: 'https://example.app.com'
      key: 'news-app-key', secret: 'secret-token',
      server: 'https://w3gram-test.herokuapp.com/')

  describe '.isValidDeviceId', ->
    it 'rejects long device IDs', ->
      deviceId = (new Array(66)).join 'a'
      expect(deviceId.length).to.equal 65
      expect(App.isValidDeviceId(deviceId)).to.equal false

    it 'rejects empty device IDs', ->
      expect(App.isValidDeviceId('')).to.equal false

    it 'rejects device IDs with invalid characters', ->
      expect(App.isValidDeviceId('invalid deviceid')).to.equal false
      expect(App.isValidDeviceId('invalid@deviceid')).to.equal false
      expect(App.isValidDeviceId('invalid.deviceid')).to.equal false
      expect(App.isValidDeviceId('invalid+deviceid')).to.equal false

    it 'accepts 64-byte IDs', ->
      deviceId = (new Array(65)).join 'a'
      expect(deviceId.length).to.equal 64
      expect(App.isValidDeviceId(deviceId)).to.equal true

    it 'accepts IDs with digits, letters, and - _', ->
      expect(App.isValidDeviceId('0129abczABCZ-_')).to.equal true

  describe '.checkDeviceId', ->
    it 'rejects an invalid ID', ->
      App.checkDeviceId('invalid device')
        .then (deviceId) ->
          expect('Should not resolve').to.equal false
        .catch (error) ->
          expect(error).to.be.ok
          expect(error.name).to.equal 'SyntaxError'
          expect(error.message).to.equal 'Invalid device ID'

    it 'works on the server README example', ->
      App.checkDeviceId('tablet-device-id').then (result) ->
          expect(result).to.equal true

  describe '.checkCanCreateTokens', ->
    it 'rejects an app without a secret', ->
      @app.secret = null
      @app.checkCanCreateTokens()
        .then (result) ->
          expect('Should not resolve').to.equal false
        .catch (error) ->
          expect(error).to.be.ok
          expect(error.name).to.equal 'InvalidStateError'
          expect(error.message).to.equal(
              'Cannot generate tokens without the app secret')

    it 'accepts an app with a secret', ->
      @app.checkCanCreateTokens().then (result) ->
          expect(result).to.equal true

  describe '#token', ->
    it 'rejects an invalid ID', ->
      @app.token('invalid device')
        .then (token) ->
          expect('Should not resolve').to.equal false
        .catch (error) ->
          expect(error).to.be.ok
          expect(error.name).to.equal 'SyntaxError'
          expect(error.message).to.equal 'Invalid device ID'

    it 'works on the server README example', ->
      @app.token('tablet-device-id').then (token) ->
          expect(token).to.equal 'DtzV3N04Ao7eJb-H09CAk0GxgREOlOvAEAbBc4H4HAQ'

    it 'is rejected when the App misses the secret', ->
      @app.secret = null
      @app.token('tablet-device-id')
        .then (token) ->
          expect('Should not resolve').to.equal false
        .catch (error) ->
          expect(error).to.be.ok
          expect(error.name).to.equal 'InvalidStateError'
          expect(error.message).to.equal(
              'Cannot generate tokens without the app secret')

  describe '#constructor', ->
    it 'strips the trailing / from the server URL', ->
      expect(@app.serverUrl).to.equal 'https://w3gram-test.herokuapp.com'

  describe '#toJSON', ->
    it 'returns the correct object', ->
      expect(@app.toJSON()).to.deep.equal(
        name: 'Example App', origin: 'https://example.app.com'
        key: 'news-app-key', secret: 'secret-token',
        server: 'https://w3gram-test.herokuapp.com')

    it 'round-trips through the constructor', ->
      app = new App @app.toJSON()
      expect(app).to.deep.equal @app

  describe '#register', ->
    beforeEach ->
      W3gram._.jsonRequest('POST', "#{testXhrServer}/reset")
        .then (json) =>
          @serverUrl = json.url
          @serverMak = json.mak
          appOptions = name: 'App#register Test', origin: '*'
          server = new W3gram._.Server @serverUrl
          server.createApp @serverMak, appOptions
        .then (app) =>
          @app = app
          @deviceId = 'tablet-device-id'
          @app.token @deviceId
        .then (token) =>
          @token = token
          @app.secret = null

    it 'resolves to a DeviceRegistration', ->
      @app.register(@deviceId, @token).then (registration) =>
        expect(registration).to.be.instanceOf W3gram._.DeviceRegistration
        expect(registration.receiverId).to.be.a 'string'
        expect(registration.pushUrl).to.equal "#{@serverUrl}/push"
        expect(registration.serverUrl).to.equal @serverUrl
        expect(registration.apiKey).to.equal @app.apiKey
        expect(registration.deviceId).to.equal @deviceId
        expect(registration.token).to.equal @token

    it 'rejects gracefully if the token is wrong', ->
      @app.register(@deviceId, @token + '-but-wrong')
        .then (app) ->
          expect('Should not resolve').to.equal false
        .catch (error) ->
          expect(error).to.be.ok
          expect(error.name).to.equal 'SecurityError'
          expect(error.httpCode).to.equal 400
          expect(error.message).to.equal(
            'Push Notification Server error: Invalid token')
