if global? and require? and module? and (not cordova?)
  # node.js
  # require('source-map-support').install()

  exports = global

  exports.W3gram = require '../../../lib/w3gram'
  exports.chai = require 'chai'
  exports.sinon = require 'sinon'
  exports.sinonChai = require 'sinon-chai'

  TestServers = require './test_servers.js'
  testServers = new TestServers()
  exports.testXhrServer = null
  exports.testServers =
    up: (done) ->
      testServers.listen ->
        exports.testXhrServer = testServers.testOrigin()
        done()
    down: (done) ->
      testServers.close ->
        done()

else
  if typeof window is 'undefined' and typeof self isnt 'undefined'
    # Web Worker.
    exports = self

    # NOTE: workers set testXhrServer in the "go" postMessage
    exports.testXhrServer = false
  else
    exports = window

    # TODO(pwnall): not all browsers suppot location.origin
    exports.testXhrServer = exports.location.origin

  exports.testServers =
    up: (done) -> done()
    down: (done) -> done()

# Shared setup.
exports.assert = exports.chai.assert
exports.expect = exports.chai.expect
