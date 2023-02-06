package io.ionic.starter;

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
