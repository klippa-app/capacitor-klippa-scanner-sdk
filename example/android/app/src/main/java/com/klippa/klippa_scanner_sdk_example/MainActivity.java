package com.klippa.klippa_scanner_sdk_example;

import android.os.Bundle;

import com.getcapacitor.BridgeActivity;
import com.klippa.capacitorscanner.KlippaScannerSDKPlugin;

public class MainActivity extends BridgeActivity {

     @Override
     public void onCreate(Bundle savedInstanceState) {
        registerPlugin(KlippaScannerSDKPlugin.class);
        super.onCreate(savedInstanceState);
     }
}
