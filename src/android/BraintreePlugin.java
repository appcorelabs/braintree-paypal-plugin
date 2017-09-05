package com.plugin.braintree;

import android.util.Log;

import com.braintreepayments.api.BraintreeFragment;
import com.braintreepayments.api.PayPal;
import com.braintreepayments.api.exceptions.InvalidArgumentException;
import com.braintreepayments.api.interfaces.PaymentMethodNonceCreatedListener;
import com.braintreepayments.api.models.PaymentMethodNonce;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Map;

public final class BraintreePlugin extends CordovaPlugin {

    private static final String TAG = "BraintreePlugin";


    @Override
    public synchronized boolean execute(String action, final JSONArray args, final CallbackContext callbackContext) throws JSONException {

        if (action == null) {
            return false;
        }

        if (action.equals("initialize")) {
            try {
                Log.i("EZER", "Getting callbackContext 1 - " + callbackContext);
                this.initialize(args, callbackContext);
            }
            catch (Exception exception) {
                callbackContext.error("BraintreePlugin uncaught exception: " + exception.getMessage());
            }

            return true;
        } else {
            // The given action was not handled above.
            return false;
        }
    }

    private synchronized void initialize(final JSONArray args, final CallbackContext callbackContext) throws JSONException, InvalidArgumentException {

        // Ensure we have the correct number of arguments.
        if (args.length() != 1) {
            callbackContext.error("A token is required.");
            return;
        }
        // Obtain the arguments.
        String token = args.getString(0);

        if (token == null || token.equals("")) {
            callbackContext.error("A token is required.");
            return;
        }
        this.cordova.setActivityResultCallback(this);
        BraintreeFragment mBraintreeFragment = BraintreeFragment.newInstance(this.cordova.getActivity(), token);
        mBraintreeFragment.addListener(new PaymentMethodNonceCreatedListener() {
            @Override
            public void onPaymentMethodNonceCreated(PaymentMethodNonce paymentMethodNonce) {
                Map<String, Object> resultMap = new HashMap<String, Object>();
                String nonce = paymentMethodNonce.getNonce();
                resultMap.put("nonce", nonce);
                Log.d(TAG, "Paypal Nonce - " + nonce);
                callbackContext.success(new JSONObject(resultMap));
            }
        });
        try {
            Thread.sleep(1500);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        PayPal.authorizeAccount(mBraintreeFragment);
        Log.i(TAG, "Getting callbackContext - " + callbackContext);
    }
}