# The ServiceWorkerRegistration partial interface.
#
# @see http://w3c.github.io/push-api/#idl-def-ServiceWorkerRegistration
class ServiceWorkerRegistration
  constructor: ->
    return

  # Feeds the W3gram API credentials into the Push Notification implementation.
  #
  # @param {Object} options the W3gram API credentials for this receiver
  # @option options {String} key the Web application's W3gram API key
  # @option options {String} deviceId this receiver's device ID
  # @option options {String} token the server-issued token for this receiver's
  #   device ID
  setupPushManager: (options) ->
    @pushRegistrationManager = new W3gram.PushRegistrationManager options

  # @property {W3gram.PushRegistrationManager}
  pushRegistrationManager: null
