import { IonicNativePlugin } from '@ionic-native/core';
export declare class CustomBarcodeScanner extends IonicNativePlugin {
    scanQRcode(options: ScannerOptions): Promise<string>;
    scanBarcode(options: ScannerOptions): Promise<any>;
}
export interface ScannerOptions {
    torchOn: boolean;
}
