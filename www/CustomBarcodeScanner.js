var exec = require('cordova/exec');

var PLUGIN_NAME = 'CustomBarcodeScanner';

var CustomBarcodeScanner = {
  scan: function (options, resolve, reject) {
    exec(resolve, reject, PLUGIN_NAME, 'scan', [options]);
  },
  scanPromise: function (options) {
    return new Promise((resolve, reject) => {
      exec(resolve, reject, PLUGIN_NAME, 'scan', [options]);
    });
  }
};

module.exports = CustomBarcodeScanner;
