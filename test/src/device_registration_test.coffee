DeviceRegistration = W3gram._.DeviceRegistration

describe 'W3gram._.DeviceRegistration', ->
  beforeEach ->
    @fakeRegistration = new DeviceRegistration(
      push: 'https://w3gram-test.herokuapp.com/push/1.device.receiver-id'
      route: 'https://w3gram-test.herokuapp.com/route/1.device.listener-id'
    )

  describe '#constructor', ->
    it 'parses pushUrl', ->
      expect(@fakeRegistration.pushUrl).to.equal(
        'https://w3gram-test.herokuapp.com/push/1.device.receiver-id')

    it 'parses routeUrl', ->
      expect(@fakeRegistration.routeUrl).to.equal(
        'https://w3gram-test.herokuapp.com/route/1.device.listener-id')

  describe '#toJSON', ->
    it 'returns the correct object', ->
      expect(@fakeRegistration.toJSON()).to.deep.equal(
        push: 'https://w3gram-test.herokuapp.com/push/1.device.receiver-id'
        route: 'https://w3gram-test.herokuapp.com/route/1.device.listener-id'
      )

    it 'round-trips through the constructor', ->
      registration = new DeviceRegistration @fakeRegistration.toJSON()
      expect(registration).to.deep.equal @fakeRegistration

  beforeEach ->
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

  describe '#push', ->
    it 'resolves to true', ->
      @registration.push(answer: 42).then (result) =>
        expect(result).to.equal true

    it 'rejects gracefully if the push URL is wrong', ->
      @registration.pushUrl += '-but-wrong'
      @registration.push(answer: 42)
        .then (result) ->
          expect('Should not resolve').to.equal false
        .catch (error) ->
          expect(error).to.be.ok
          expect(error.name).to.equal 'SecurityError'
          expect(error.httpCode).to.equal 400
          expect(error.message).to.equal(
            'Push Notification Server error: Invalid receiver ID')

  describe '#route', ->
    it 'resolves to a WebSocket URL', ->
      @registration.route().then (wsUrl) =>
        expect(wsUrl).to.be.a 'string'
        expect(wsUrl).to.match /^ws\:/

    it 'rejects gracefully if the route URL is wrong', ->
      @registration.routeUrl += '-but-wrong'
      @registration.route()
        .then (wsUrl) ->
          expect('Should not resolve').to.equal false
        .catch (error) ->
          expect(error).to.be.ok
          expect(error.name).to.equal 'SecurityError'
          expect(error.httpCode).to.equal 400
          expect(error.message).to.equal(
            'Push Notification Server error: Invalid listener ID')

    it 'returns a WebSocket URL that responds to #push', ->
      @registration.route().then (wsUrl) =>
        expect(wsUrl).to.be.a 'string'
        @wsClient = new W3gram._.WsClient wsUrl
        gotNotification = false
        @wsClient.onNotification = (notification) =>
          expect(gotNotification).to.equal false
          gotNotification = true
          expect(notification).to.be.an 'object'
          expect(notification.answer).to.equal 42
          @wsClient.close()
        @wsClient.connected.then =>
          @registration.push(answer: 42)
          @wsClient.closed.then ->
            expect(gotNotification).to.equal true
