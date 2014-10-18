# Performs a JSON HTTP request.
#
# This is used to talk to the Push Notification Server.
#
# @param {String} method the HTTP method
# @param {String} URL the URL that receives the request
# @param {Object} body object to be JSON-encoded as the request's body
# @return {Promise<Object>} a promise that will be resolved with the
#   JSON-decoded HTTP response
W3gram._.jsonRequest = (method, url, body) ->
  new W3gram._.Promise (resolve, reject) ->
    xhr = new W3gram._.XMLHttpRequest()
    xhr.open method, url, true
    xhr.onreadystatechange = ->
      return true if xhr.readyState isnt 4  # XMLHttpRequest.DONE is 4

      contentType = xhr.getResponseHeader 'Content-Type'
      if contentType
        offset = contentType.indexOf ';'
        contentType = contentType.substring(0, offset) if offset isnt -1

      json = null
      jsonError = null
      if contentType is 'application/json'
        try
          json = JSON.parse(xhr.responseText || xhr.response)
        catch jsonError
          # JSON parsing errored out.

      statusCode = xhr.status
      if statusCode >= 200 and statusCode < 300
        # HTTP success code.
        if jsonError
          reject jsonError
          return
        resolve(json or {})
        return

      if statusCode is 0
        # Network error.
        errorName = W3gram._.DOMException.NetworkError
        errorMessage = 'Could not reach Push Notification Server'
      else
        # HTTP error response.
        errorName = W3gram._.DOMException.SecurityError
        if json and json.error
          errorMessage = "Push Notification Server error: #{json.error}"
        else
          errorMessage = "Push Notification Server error: HTTP #{statusCode}"

      error = new W3gram._.DOMException errorName, errorMessage
      if statusCode isnt 0
        error.httpCode = statusCode

      reject error
      return

    if body
      xhr.setRequestHeader 'Content-Type', 'application/json; charset=utf-8'
      xhr.send JSON.stringify(body)
    else
      xhr.send()
    return
