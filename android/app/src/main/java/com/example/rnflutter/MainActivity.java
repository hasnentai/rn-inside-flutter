package com.example.rnflutter;

import io.flutter.embedding.android.FlutterActivity;


import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.Settings;
import android.widget.Toast;



//import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.FlutterEngineCache;
public class MainActivity extends FlutterActivity {

	private final int OVERLAY_PERMISSION_REQ_CODE = 1;  // Choose any value

	private FlutterEngine flutterEngine;

	final String ENGINE_ID = "1";	

	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		 // Register your native module package with the Flutter engine

		 

        FlutterEngineCache.getInstance().put(ENGINE_ID, this.getFlutterEngine());

        GeneratedPluginRegistrant.registerWith(this.getFlutterEngine());
		this.flutterEngine = this.getFlutterEngine();
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) { // Only for development
			if (!Settings.canDrawOverlays(this)) {
				Intent intent = new Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:" + getPackageName()));
				startActivityForResult(intent, OVERLAY_PERMISSION_REQ_CODE);
			}
		}

		new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), "main_channel").setMethodCallHandler(
			new MethodCallHandler() {
				@Override
				public void onMethodCall(MethodCall call, Result result) {
				switch (call.method) {
					case "startRNActivity":
						result.success(null);
						Intent intent = new Intent(MainActivity.this, MyReactActivity.class);
						intent.putExtra("FLUTTER_ENGINE",ENGINE_ID );
						startActivity(intent);
						break;
					default:
						result.notImplemented();
				}
				}
			}
		);
		
		
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		if (requestCode == OVERLAY_PERMISSION_REQ_CODE) { // Only for development 
			if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
				if (!Settings.canDrawOverlays(this)) {
					Toast.makeText(this, "SYSTEM_ALERT_WINDOW permission not granted", Toast.LENGTH_LONG).show();
					// SYSTEM_ALERT_WINDOW permission not granted
				}
			}
		}
		//mReactInstanceManager.onActivityResult( this, requestCode, resultCode, data );
	}
}