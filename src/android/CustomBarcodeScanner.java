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
import org.json.JSONObject;

public class CustomBarcodeScanner extends CordovaPlugin {

    private CallbackContext callbackContext;

    private static final String TAG = "CustomBarcodeScanner";

    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);

        Log.d(TAG, "Initializing CustomBarcodeScanner");
    }

    public boolean execute(String action, JSONArray args, final CallbackContext callbackContext) throws JSONException {
        this.callbackContext = callbackContext;

        JSONObject options = args.optJSONObject(0);
        if (action.equals("scanQRCode")) {
            this.scanCode(new String[]{IntentIntegrator.QR_CODE}, options);
        } else if (action.equals("scanBarcode")) {
            String[] formats = {IntentIntegrator.EAN_8, IntentIntegrator.EAN_13, IntentIntegrator.ITF};
            this.scanCode(formats, options);
        }

        return true;
    }

    private void scanCode(String[] formats, JSONObject options) {

        this.cordova.setActivityResultCallback(this);

        IntentIntegrator integrator = new IntentIntegrator(this.cordova.getActivity());
        integrator.setDesiredBarcodeFormats(formats);
        integrator.setBeepEnabled(false);
        integrator.setCaptureActivity(AnyOrientationActivity.class);
        integrator.setPrompt("Alinhe o código para a leitura.");
        integrator.addExtra(AnyOrientationActivity.EXTRA_TORCH_ON, options.optBoolean(AnyOrientationActivity.EXTRA_TORCH_ON, false));

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
