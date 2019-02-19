
var exec = require('cordova/exec');

var PLUGIN_NAME = 'CustomBarcodeScanner';

var CustomBarcodeScanner = {
  scanQRcode: function (successCallback, erroCallback) {
    exec(successCallback, erroCallback, PLUGIN_NAME, 'scanQRCode', []);
  },
  scanBarcode: function (successCallback, erroCallback) {
    exec(successCallback, erroCallback, PLUGIN_NAME, 'scanBarcode', []);
  }
};

module.exports = CustomBarcodeScanner;
