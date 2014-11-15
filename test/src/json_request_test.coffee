describe 'W3gram._.jsonRequest', ->
  beforeEach ->
    @echoUrl = "#{testXhrServer}/echo"
  describe 'with a GET request', ->
    it 'resolves a 200', ->
      W3gram._.jsonRequest('GET', @echoUrl).then (result) ->
        expect(result).to.be.an 'object'
        expect(result.method).to.equal 'GET'

  describe 'with a POST request', ->
    it 'resolves a 200', ->
      W3gram._.jsonRequest('POST', @echoUrl, answer: 42)
        .then (result) ->
          expect(result).to.be.an 'object'
          expect(result.method).to.equal 'POST'
          expect(result.body).to.deep.equal answer: 42

    it 'rejects a 400', ->
      W3gram._.jsonRequest('POST', @echoUrl, _status: 400)
        .then (result) ->
          expect('Should reject promise').to.equal false
        .catch (error) ->
          expect(error).to.be.ok
          expect(error.name).to.equal 'SecurityError'
          expect(error.message).to.equal(
              'Push Notification Server error: HTTP 400')
          expect(error.httpCode).to.equal 400

    it 'rejects a 500 and parses the JSON error', ->
      W3gram._.jsonRequest('POST', @echoUrl, _status: 500, _error: 'The error')
        .then (result) ->
          expect('Should reject promise').to.equal false
        .catch (error) ->
          expect(error).to.be.ok
          expect(error.name).to.equal 'SecurityError'
          expect(error.message).to.equal(
              'Push Notification Server error: The error')
          expect(error.httpCode).to.equal 500

  describe 'with an invalid URL', ->
    it 'rejects on invalid IP', ->
      W3gram._.jsonRequest('GET', 'http://0.0.0.0/fail')
        .then (result) ->
          expect('Should reject promise').to.equal false
        .catch (error) ->
          expect(error).to.be.ok
          expect(error.name).to.equal 'NetworkError'
          expect(error.message).to.equal(
              'Could not reach Push Notification Server')
          expect(error.httpCode).to.be.undefined

    it 'rejects on invalid DNS', ->
      W3gram._.jsonRequest('GET',
                           'https://invalid.domain.no-such-domain.com/fail')
        .then (result) ->
          expect('Should reject promise').to.equal false
        .catch (error) ->
          expect(error).to.be.ok
          expect(error.name).to.equal 'NetworkError'
          expect(error.message).to.equal(
              'Could not reach Push Notification Server')
          expect(error.httpCode).to.be.undefined


