# This runs tests inside a Web Worker.

importScripts '../../../node_modules/setimmediate/setImmediate.js'
importScripts '../../../node_modules/es6-promise-polyfill/promise.js'

importScripts '../../../lib/w3gram.js'

# HACK(pwnall): workaround for https://github.com/cjohansen/Sinon.JS/pull/491
self.global = self

importScripts '../../../test/vendor/sinon.js'

# HACK(pwnall): workaround for https://github.com/cjohansen/Sinon.JS/pull/491
delete self['global']

importScripts '../../../test/vendor/chai.js'
importScripts '../../../node_modules/sinon-chai/lib/sinon-chai.js'
importScripts '../../../node_modules/mocha/mocha.js'
importScripts '../../../test/js/helpers/browser_mocha_setup.js'

importScripts '../../../test/js/helpers/setup.js'

importScripts '../../../test/js/app_test.js'
importScripts '../../../test/js/device_registration_test.js'
importScripts '../../../test/js/hmac_test.js'
importScripts '../../../test/js/json_request_test.js'
importScripts '../../../test/js/setup_test.js'
importScripts '../../../test/js/server_test.js'
importScripts '../../../test/js/setup_test.js'
# NOTE: not loading web_worker_test.js, to allow Worker debugging with it.only

# NOTE: not loading helpers/browser_mocha_runner, using the code below instead.

# Fire the tests when we get the "go" message.
self.onmessage = (event) ->
  message = event.data
  switch message.type
    when 'go'
      self.testXhrServer = message.testXhrServer
      mocha.run()
