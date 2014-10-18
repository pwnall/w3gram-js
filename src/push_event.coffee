# Implements the PushEvent interface.
#
# @see http://w3c.github.io/push-api/#the-push-event
class W3gram.PushEvent
  constructor: (target, data) ->
    @name = 'PushEvent'
    @target = target
    @data = data

# Creates a PushEvent instance.
#
# @param {W3gram.PushRegistration} target the registration that received the
#   event
# @param {String} data the push data
# @return {PushEvent} the newly created PushEvent
W3gram._.createPushEvent = (target, data) ->
  # TODO(pwnall): use custom events, if available
  new W3gram.PushEvent target, data
