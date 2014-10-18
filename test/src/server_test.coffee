Server = W3gram._.Server

describe 'W3gram._.Server', ->
  beforeEach ->
    W3gram._.jsonRequest('POST', "#{testXhrServer}/reset").then (json) =>
      @serverUrl = json.url
      @serverMak = json.mak
      @client = new Server @serverUrl

  describe '#getMak', ->
    it 'resolves to the server MAK', ->
      @client.getMak().then (mak) =>
        expect(mak).to.equal @serverMak

  describe '#createApp', ->
    it 'resolves to an App', ->
      appOptions = name: 'CreateApp Test', origin: 'http://test.app.com'
      @client.createApp(@serverMak, appOptions).then (app) ->
        expect(app).to.be.instanceOf W3gram._.App
        expect(app.name).to.equal 'CreateApp Test'
        expect(app.origin).to.equal 'http://test.app.com'
        expect(app.apiKey).to.be.a 'string'
        expect(app.apiKey.length).to.be.at.least 12
        expect(app.secret).to.be.a 'string'
        expect(app.secret.length).to.be.at.least 32

    it 'rejects gracefully if the MAK is wrong', ->
      appOptions = name: 'CreateApp Test', origin: 'http://test.app.com'
      @client.createApp('wrong-mak', appOptions)
        .then (app) ->
          expect('Should not resolve').to.equal false
        .catch (error) ->
          expect(error).to.be.ok
          expect(error.name).to.equal 'SecurityError'
          expect(error.httpCode).to.equal 403

  describe '#constructor', ->
    it 'strips the / at the end of serverUrl', ->
      server = new Server 'https://w3gram-test.herokuapp.com/'
      expect(server.serverUrl).to.equal 'https://w3gram-test.herokuapp.com'
      server = new Server 'https://w3gram-test.herokuapp.com'
      expect(server.serverUrl).to.equal 'https://w3gram-test.herokuapp.com'

