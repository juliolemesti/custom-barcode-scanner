var __extends = (this && this.__extends) || (function () {
    var extendStatics = Object.setPrototypeOf ||
        ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
        function (d, b) { for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p]; };
    return function (d, b) {
        extendStatics(d, b);
        function __() { this.constructor = d; }
        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };
})();
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
(function (factory) {
    if (typeof module === "object" && typeof module.exports === "object") {
        var v = factory(require, exports);
        if (v !== undefined) module.exports = v;
    }
    else if (typeof define === "function" && define.amd) {
        define(["require", "exports", "@angular/core", "@ionic-native/core"], factory);
    }
})(function (require, exports) {
    "use strict";
    Object.defineProperty(exports, "__esModule", { value: true });
    var core_1 = require("@angular/core");
    var core_2 = require("@ionic-native/core");
    var CustomBarcodeScanner = (function (_super) {
        __extends(CustomBarcodeScanner, _super);
        function CustomBarcodeScanner() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        CustomBarcodeScanner.prototype.scanQRcode = function () { return; };
        CustomBarcodeScanner.prototype.scanBarcode = function () { return; };
        CustomBarcodeScanner.decorators = [
            { type: core_1.Injectable },
        ];
        CustomBarcodeScanner.ctorParameters = function () { return []; };
        __decorate([
            core_2.Cordova(),
            __metadata("design:type", Function),
            __metadata("design:paramtypes", []),
            __metadata("design:returntype", Promise)
        ], CustomBarcodeScanner.prototype, "scanQRcode", null);
        __decorate([
            core_2.Cordova(),
            __metadata("design:type", Function),
            __metadata("design:paramtypes", []),
            __metadata("design:returntype", Promise)
        ], CustomBarcodeScanner.prototype, "scanBarcode", null);
        CustomBarcodeScanner = __decorate([
            core_2.Plugin({
                pluginName: 'CustomBarcodeScanner',
                plugin: 'cordova-plugin-custom-scanner',
                pluginRef: 'CustomBarcodeScanner',
                repo: 'https://github.com/juliolemesti/custom-barcode-scanner',
                platforms: ['android', 'iOS']
            })
        ], CustomBarcodeScanner);
        return CustomBarcodeScanner;
    }(core_2.IonicNativePlugin));
    exports.CustomBarcodeScanner = CustomBarcodeScanner;
});
//# sourceMappingURL=custom-barcode-scanner.js.map