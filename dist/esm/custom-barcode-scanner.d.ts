import { IonicNativePlugin } from '@ionic-native/core';
export declare class CustomBarcodeScanner extends IonicNativePlugin {
    scanQRcode(): Promise<string>;
    scanBarcode(): Promise<any>;
}
