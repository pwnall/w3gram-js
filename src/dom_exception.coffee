# Mock DOMException.
#
# The real DOMException class does not have a constructor, so we must use this
# mock to issue errors that mostly match the spec.
class W3gram._.DOMException
  # Creates a DOMException.
  #
  # @param {String} name the exception's name
  # @param {String} message the user-defined message
  constructor: (name, message) ->
    @name = name
    @message = message

  # @property {String} the exception's name
  @name: null

  # The object can not be found here.
  @NotFoundError = 'NotFoundError'

  # The object is in an invalid state.
  @InvalidStateError = 'InvalidStateError'

  # The string did not match the expected pattern.
  @SyntaxError = 'SyntaxError'

  # The object can not be found here.
  @NotFoundError = 'NotFoundError'

  # A security error occurred.
  @SecurityError = 'SecurityError'

  # A network error occurred.
  @NetworkError = 'NetworkError'

  # The operation was aborted.
  @AbortError = 'AbortError'
  @ABORT_ERR = 20


