# Conditionally loads polyfills in node.js.

if typeof Promise is 'undefined'
  # Try to load the polyfill.
  W3gram._.Promise = W3gramRequire('es6-promise-polyfill').Promise
else
  # Native promises are available.
  W3gram._.Promise = Promise

if typeof WebSocket is 'undefined'
  # Try to load the polyfill.
  W3gram._.WebSocket = W3gramRequire 'ws'
else
  # Native promises are available.
  W3gram._.WebSocket = WebSocket


if typeof XMLHttpRequest is 'undefined'
  # Try to load the polyfill.
  W3gram._.XMLHttpRequest = W3gramRequire 'xhr2'
else
  # Native XHR is available.
  W3gram._.XMLHttpRequest = XMLHttpRequest
