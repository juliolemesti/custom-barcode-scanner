import { IonicNativePlugin } from '@ionic-native/core';
export declare class CustomBarcodeScanner extends IonicNativePlugin {
    scan(options: ScannerOptions): Promise<string>;
}
export interface ScannerOptions {
    torchOn: boolean;
}
