var exec = require('cordova/exec');

var PLUGIN_NAME = 'CustomBarcodeScanner';

var CustomBarcodeScanner = {
  scanQRcode: function (options, successCallback, errorCallback) {
    exec(successCallback, errorCallback, PLUGIN_NAME, 'scanQRCode', [options]);
  },
  scanBarcode: function (options, successCallback, errorCallback) {
    exec(successCallback, errorCallback, PLUGIN_NAME, 'scanBarcode', [options]);
  }
};

module.exports = CustomBarcodeScanner;
