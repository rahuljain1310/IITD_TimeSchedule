(function () {

"use strict";

var child_process = require('child_process'),
    origExec = child_process.exec

exports.exec = function(command /*, options, callback */) {
  var file, 
      args, 
      options, 
      callback

  if ('function' === typeof arguments[1]) {
    options = undefined
    callback = arguments[1]
  } else {
    options = arguments[1]
    callback = arguments[2]
  }

  if (options && options.rollingTimeout) {
    return _exec (command, options, callback)
  } else {
    // pass-through
    return origExec.apply(this, arguments)
  }
}

function _exec (command, options, callback) {
  var self = this,
      timeout = options.rollingTimeout,
      timeoutId,
      child,
      killSignal = (options || {}).killSignal || 'SIGTERM';

  function rescheduleKill () {
    if (timeoutId) {
      clearTimeout(timeoutId)
      timeoutId = null
    }
    timeoutId = setTimeout(function () {
      child.emit('rolling-timeout')
      child && child.kill(killSignal)
    }, timeout)
  }

  function cleanUpTimeout () {
    clearTimeout(timeoutId)
    timeoutId = null
  }


  delete options.rollingTimeout

  child = origExec(command, options, callback)

  child.stdout.on('data', rescheduleKill)
  child.stderr.on('data', rescheduleKill)

  child.on('close', cleanUpTimeout)
  child.on('exit', cleanUpTimeout)

  rescheduleKill()

  return child
}  // end _exec


})();
