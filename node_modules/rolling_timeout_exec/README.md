rolling_timeout_exec
====================

Wrapper around `child_process.exec` that provides a rolling timeout based on stdout/stderr activity.

### Goal

The goal of this package is to provide a practical way to tell the difference between a slow child process and a hung child process.


### Changes

This package adds a new `rollingTimeout` option to `exec`.

`rollingTimeout` expects a numeric value representing the number of milliseconds to wait for activity from child processes before killing the child.

Activity means any output to `stdout` or `stderr`.

If a rollingTimeout is triggered, the child process is killed in the same way that `timeout` does, using `options.killSignal` and defaulting to `SIGTERM`.  A `rolling-timeout` event is also emitted on the child process.


### Usage

```sh
$ npm install rolling_timeout_exec
```

```js
var exec = require('rolling_timeout_exec').exec,
    child,
    command,
    options,
    timeout = false;

command = 'git clone --progress http://some-slow-server.example.com/repo';
options = { rollingTimeout: 5000 };

child = exec(command, options, function (err, stdout, stderr) {
  if (err) {
    if (timeout) {
      console.error('timed out');
    }
    console.error(err.message, err.code);
    console.error(stdout);
    console.error(stderr);
  } else {
    console.log('git clone completed!');
  }
});

child.on('rolling-timeout', function () {
  timeout = true;
})
```

### Test

Steps to run test suite:

```sh
$ cd ~/tmp
$ git clone https://github.com/alanning/rolling_timeout_exec.git
$ cd rolling_timeout_exec
$ npm install
$ npm test
```
