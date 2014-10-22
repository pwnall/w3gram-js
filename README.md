# W3gram Client JavaScript Library

[![Build Status](https://travis-ci.org/pwnall/w3gram-js.svg)](https://travis-ci.org/pwnall/w3gram-js)
[![API Documentation](http://img.shields.io/badge/API-Documentation-ff69b4.svg)](http://coffeedoc.info/github/pwnall/w3gram-js)
[![NPM Version](http://img.shields.io/npm/v/w3gram.svg)](https://www.npmjs.org/package/w3gram)

This is a [W3C Push API](http://w3c.github.io/push-api/) polyfill that uses the
[W3gram push notification server](https://github.com/pwnall/w3gram-server). The
library works in modern browsers and in [node.js](http://nodejs.org/).


## Prerequisites

Building the library requries [node.js](http://nodejs.org/) 0.10 or above.

The [W3C Push API](http://w3c.github.io/push-api/) requires
[ES6 Promises](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise).
Fortunately, many polyfills are available. This library has been tested with
[es6-promise-polyfill](https://github.com/lahmatiy/es6-promise-polyfill) in
conjunction with the
[setImmediate polyfill](https://github.com/YuzuJS/setImmediate) that it
recommends.

The code has been tested on the following platforms:

* [node.js](http://nodejs.org/) 0.10, 0.11
* [Chrome](https://www.google.com/chrome/) 38
* [Firefox](https://www.mozilla.org/firefox) 32
* [Safari](https://www.apple.com/safari/) 8

The library should work on any browser that supports
[the WebSocket API](http://dev.w3.org/html5/websockets/) and
[Cross-Origin Resource Sharing](http://www.w3.org/TR/cors/). The list above
states the platforms that the code is actively tested against.


## Setup

On the server side, you must obtain a W3gram API key, generate a device ID for
each user session, and compute the token (signature) for the device ID.

An easy way to get an API key is to set up your own W3gram server via the
one-click _Deploy to Heroku_ button on the
[W3gram Server repository README](https://github.com/pwnall/w3gram-server), and
follow the instructions there to set up your application.


### Browser Setup

Check out the library and build it.

```bash
git clone https://github.com/pwnall/w3gram-js.git w3gram.js
cd w3gram.js
npm install
npm package
```

The build output is `lib/w3gram.js`, minified as `lib/w3gram.min.js`, with the
source map `lib/w3gram.min.map`.

Once your server-side code embeds the API key, device ID and token into Web
pages, use the following snippet to initialize the W3gram client library.

```javascript
W3gram.setupPushManager({
  "server": "https://your-w3gram-server.herokuapp.com",
  "app": "your-api-key",
  "device": "the-device-id",
  "token": "token-for-the-device-id"
});
```

After the `setupPushManager` call, the `W3gram` singleton implements the
[`ServiceWorkerRegistration` extensions in the W3C Push API](http://www.w3.org/TR/push-api/#extensions-to-the-serviceworkerregistration-interface).

```javascript
W3gram.pushRegistrationManager.register().then(function (registration) {
  registration.onpush = function (event) {
    console.log("Got push notification: " + event.data);
  };
}, function (error) {
  console.log(error);
});
```

## node.js Setup

This library does not yet have a properly designed API for node.js. Instead, it
implements the [W3C Push API](http://w3c.github.io/push-api/), just like in the
browser.

Add the dependency to your `package.json`.

```javascript
"dependencies": {
  "w3gram": "0.2.1"
}
```

Require the library and use the Push API.

```javascript
W3gram = require('w3gram');
```


## Development Setup

Install all dependencies and create the PostgreSQL database used by the W3gram
server in the test suite.

```bash
npm install
createdb w3gram_test
```

Run tests.

```bash
cake test
cake webtest
BROWSER=firefox cake webtest
BROWSER=safari cake webtest

```


## License

This project is Copyright (c) 2014 Victor Costan, and distributed under the MIT
License.
