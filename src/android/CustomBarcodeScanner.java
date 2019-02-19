package br.com.mbamobi;

import android.content.Intent;
import android.util.Log;

import com.google.zxing.integration.android.IntentIntegrator;
import com.google.zxing.integration.android.IntentResult;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;

public class CustomBarcodeScanner extends CordovaPlugin {

    private CallbackContext callbackContext;

    private static final String TAG = "CustomBarcodeScanner";

    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);

        Log.d(TAG, "Initializing CustomBarcodeScanner");
    }

    public boolean execute(String action, JSONArray args, final CallbackContext callbackContext) throws JSONException {
        this.callbackContext = callbackContext;

        if (action.equals("scanQRCode")) {
            this.scanCode("QR_CODE");
        } else if (action.equals("scanBarcode")) {
            this.scanCode("ITF");
        }

        return true;
    }

    private void scanCode(String format) {

        this.cordova.setActivityResultCallback(this);

        IntentIntegrator integrator = new IntentIntegrator(this.cordova.getActivity());
        integrator.setDesiredBarcodeFormats(format);
        integrator.setBeepEnabled(false);
        integrator.setCaptureActivity(AnyOrientationActivity.class);
        integrator.setPrompt("Alinhe o código para a leitura.");

        integrator.initiateScan();

    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent intent) {
        if (intent != null) {
            IntentResult result = IntentIntegrator.parseActivityResult(requestCode, resultCode, intent);

            if (result != null) {
                try {
                    callbackContext.success(result.getContents());
                } catch (Exception e) {
                    this.sendParseDataError();
                }
            } else {
                callbackContext.success("");
            }

        } else {
            callbackContext.success("");
        }
    }

    private void sendParseDataError() {
        this.sendError("ZXing IntentIntegrator parse error");
    }

    private void sendError(String msg) {
        callbackContext.error(msg);
    }

}
