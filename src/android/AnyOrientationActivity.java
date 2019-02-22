package br.com.mbamobi;

import android.app.Activity;
import android.app.Application;
import android.content.pm.PackageManager;
import android.content.res.Resources;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.util.DisplayMetrics;
import android.view.KeyEvent;
import android.view.View;
import android.view.animation.AlphaAnimation;
import android.widget.Button;

import com.journeyapps.barcodescanner.BarcodeView;
import com.journeyapps.barcodescanner.CaptureManager;
import com.journeyapps.barcodescanner.DecoratedBarcodeView;
import com.journeyapps.barcodescanner.Size;
import com.journeyapps.barcodescanner.camera.CameraManager;

public class AnyOrientationActivity extends Activity implements
        DecoratedBarcodeView.TorchListener {

    static String EXTRA_TORCH_ON = "torchOn";

    private CaptureManager capture;
    private DecoratedBarcodeView barcodeScannerView;
    private boolean isTorchOn = false;
    private Button switchFlashlightButton;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        barcodeScannerView = initializeContent();
        barcodeScannerView.setTorchListener(this);

        setTorchButton();

        capture = new CaptureManager(this, barcodeScannerView);
        capture.initializeFromIntent(getIntent(), savedInstanceState);
        capture.decode();


    }

    private void setTorchButton() {
        if (hasFlash()) {
            int switchFlashlightButtonId = getResourceIdentifier("switch_flashlight", "id");
            switchFlashlightButton = findViewById(switchFlashlightButtonId);
            switchFlashlightButton.getBackground().setAlpha(100);

            if (getIntent().getBooleanExtra(EXTRA_TORCH_ON, false)) {
                barcodeScannerView.setTorchOn();
            }
        } else {
            switchFlashlightButton.setVisibility(View.GONE);
        }

    }

    /**
     * Override to use a different layout.
     *
     * @return the DecoratedBarcodeView
     */
    protected DecoratedBarcodeView initializeContent() {

        int anyOrientationLayout = getResourceIdentifier("any_orientation", "layout");
        setContentView(anyOrientationLayout);

        int barcodeScannerId = getResourceIdentifier("zxing_barcode_scanner", "id");
        DecoratedBarcodeView decoratedBarcodeView = findViewById(barcodeScannerId);

        this.calculateFrameSize(decoratedBarcodeView);

        return decoratedBarcodeView;
    }

    private void calculateFrameSize(DecoratedBarcodeView decoratedBarcodeView) {
        DisplayMetrics displayMetrics = new DisplayMetrics();
        getWindowManager().getDefaultDisplay().getMetrics(displayMetrics);

        int width = (int) (displayMetrics.widthPixels * .90);
        int height = (int) (displayMetrics.heightPixels * .90);
        Size size = new Size(width, height);

        int barcodeViewId = getResourceIdentifier("zxing_barcode_surface", "id");
        BarcodeView barcodeView = decoratedBarcodeView.findViewById(barcodeViewId);
        barcodeView.setFramingRectSize(size);
    }

    private int getResourceIdentifier(String name, String type) {
        Application app = getApplication();
        String package_name = app.getPackageName();
        Resources resources = app.getResources();

        return resources.getIdentifier(name, type, package_name);
    }

    @Override
    protected void onResume() {
        super.onResume();
        capture.onResume();
    }

    @Override
    protected void onPause() {
        super.onPause();
        capture.onPause();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        capture.onDestroy();
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        capture.onSaveInstanceState(outState);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String permissions[], @NonNull int[] grantResults) {
        capture.onRequestPermissionsResult(requestCode, permissions, grantResults);
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        return barcodeScannerView.onKeyDown(keyCode, event) || super.onKeyDown(keyCode, event);
    }

    private boolean hasFlash() {
        return getApplicationContext().getPackageManager().hasSystemFeature(PackageManager.FEATURE_CAMERA_FLASH);
    }

    public void switchFlashlight(View view) {
        if (isTorchOn) barcodeScannerView.setTorchOff();
        else barcodeScannerView.setTorchOn();
    }

    @Override
    public void onTorchOn() {
        isTorchOn = true;
        switchFlashlightButton.getBackground().setAlpha(255);
        AlphaAnimation alphaAnim = new AlphaAnimation(0.4f, 1.0f);
        alphaAnim.setDuration(200);
        switchFlashlightButton.startAnimation(alphaAnim);
    }

    @Override
    public void onTorchOff() {
        isTorchOn = false;
        switchFlashlightButton.getBackground().setAlpha(100);
        AlphaAnimation alphaAnim = new AlphaAnimation(1.0f, 0.4f);
        alphaAnim.setDuration(200);
        switchFlashlightButton.startAnimation(alphaAnim);
    }
}
