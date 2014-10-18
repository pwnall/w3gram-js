describe 'W3gram._.hmac', ->
  it 'works for an empty message with an empty key', ->
    W3gram._.hmac('', '').then (hmac) ->
      expect(hmac).to.equal 'thNnmggU2ex3L5XXeMNfxf8Wl8STcVZTxscSFEKSxa0'

  it 'URL-safe encodes + to - correctly', ->
    W3gram._.hmac('hello', 'world-world-world').then (hmac) ->
      expect(hmac).to.equal 'PJA-GwWi9eiuACG2Cjwb6fsbunRUJnVdpT9Wnk2FpRs'

  it 'URL-safe encodes / to = correctly', ->
    W3gram._.hmac('hello', 'world').then (hmac) ->
      expect(hmac).to.equal '8ayXAutfryPKKRpNxG3t3u4qeMza8KQSvtdxTP_7HMQ'

  it 'works on the RFC 4231 test case 2', ->
    W3gram._.hmac('Jefe', 'what do ya want for nothing?').then (hmac) ->
      expect(hmac).to.equal 'W9zBRr9gdU5qBCQmCJV1x1oAPwidJzmDnexYuWTsOEM'

