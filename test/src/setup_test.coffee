# Under node.js, this brings up the test servers.

before (callback) ->
  testServers.up callback

after (callback) ->
  testServers.down callback
