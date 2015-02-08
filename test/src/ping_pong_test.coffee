PingPong = W3gram._.PingPong

describe 'W3gram._.PingPong', ->
  beforeEach ->
    @pingPong = new PingPong(
        silenceTimeoutMs: 10, pingSlackMs: 20, rttMs: 20)

  describe 'when pings are returned immediately', ->
    beforeEach ->
      @pingCount = 0
      @pingPong.onPing = (data) =>
        @pingCount += 1
        setImmediate =>
          @pingPong.receivedPong data

    it 'issues 8-10 ping requests in 100ms', (done) ->
      @pingPong.onPingTimeout = ->
        @pingPong.disconnected()
        expect('Should not timeout').to.equal false
        done()
      onTimeout = =>
        @pingPong.disconnected()
        expect(@pingCount).to.be.at.least 8
        expect(@pingCount).to.be.at.most 10
        done()
      @pingPong.startedConnecting()
      setTimeout onTimeout, 100
      null

  describe 'when pings are not returned', ->
    beforeEach ->
      @pingCount = 0
      @pingPong.onPing = (data) =>
        @pingCount += 1

    it 'issues 1 ping and disconnects ', (done) ->
      @pingPong.onPingTimeout = =>
        expect(@pingCount).to.equal 1
        done()
      @pingPong.startedConnecting()
      null
