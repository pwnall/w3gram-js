# W3gram Client JavaScript Library

[![Build Status](https://travis-ci.org/pwnall/w3gram-js.svg)](https://travis-ci.org/pwnall/w3gram-js)
[![API Documentation](http://img.shields.io/badge/API-Documentation-ff69b4.svg)](http://coffeedoc.info/github/pwnall/w3gram-js)
[![NPM Version](http://img.shields.io/npm/v/w3gram-js.svg)](https://www.npmjs.org/package/w3gram-js)

This is a [W3c Push API](http://w3c.github.io/push-api/) polyfill that uses the
[W3gram push notification server](https://github.com/pwnall/w3gram-server). The
library works in modern browsers and in [node.js](http://nodejs.org/).


## Setup

```javascript
W3gram.setupPushManager({
  "server": "https://your-w3gram-server.herokuapp.com",
  "app": "your-api-key",
  "device": "the-device-id",
  "token": "token-for-the-device-id"
});

// pushRegistrationManager returns a PushRegistrationManager that can be used
// according to the Push API spec.
W3gram.pushRegistrationManager.register();
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
```


## License

This project is Copyright (c) 2014 Victor Costan, and distributed under the MIT
License.
