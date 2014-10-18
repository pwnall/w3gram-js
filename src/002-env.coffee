# Helpers for interacting with the JavaScript environment we run in.

if typeof global isnt 'undefined' and typeof module isnt 'undefined' and
    'exports' of module
  # Running inside node.js.
  W3gramGlobal = global
  W3gramRequire = module.require.bind module
  module.exports = W3gram

else if typeof window isnt 'undefined' and typeof navigator isnt 'undefined'
  # Running inside a browser.
  W3gramGlobal = window
  W3gramRequire = null
  window.W3gram = W3gram

else if typeof self isnt 'undefined' and typeof navigator isnt 'undefined'
  # Running inside a Web worker.
  W3gramEnvGlobal = self
  # NOTE: browsers that implement Web Workers also implement the ES5 bind.
  W3gramEnvRequire = self.importScripts.bind self
  self.W3gram = W3gram

else
  throw new Error 'w3gram.js loaded in an unsupported JavaScript environment.'

# The global environment object.
W3gram._.global = W3gramGlobal

# Loads a module into the JavaScript environment.
#
# This is null in the browser. It is aliased to require in node.js and to
# importScripts in Web Workers.
W3gram._.require = W3gramRequire
