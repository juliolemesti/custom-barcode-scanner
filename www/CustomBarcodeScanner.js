var exec = require('cordova/exec');

var PLUGIN_NAME = 'CustomBarcodeScanner';

var CustomBarcodeScanner = {
  scan: function (options, successCallback, errorCallback) {
    exec(successCallback, errorCallback, PLUGIN_NAME, 'scan', [options]);
  }
};

module.exports = CustomBarcodeScanner;
