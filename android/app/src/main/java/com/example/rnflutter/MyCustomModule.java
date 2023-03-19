
package com.example.rnflutter;


import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import android.app.Activity;


import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.android.FlutterFragment;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class MyCustomModule extends ReactContextBaseJavaModule {
    
    private FlutterEngine flutterEngine;
    private static MethodChannel channel;

  public MyCustomModule(ReactApplicationContext reactContext,FlutterEngine flutterEngine) {
    super(reactContext);
    this.flutterEngine = flutterEngine;
  }

  @Override
  public String getName() {
    return "MyCustomModule";
  }

  @ReactMethod
  public void getData(String param1, String param2, Promise promise) {
    // Your native code to retrieve data here
    Activity activity = getCurrentActivity();
    if (activity == null) {
        return;
      }
    String result = param1;
    promise.resolve(result);
    activity.runOnUiThread(new Runnable() {

        @Override
        public void run() {
          if (channel == null) {
            
            channel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "my_channel");
          }
  
          channel.invokeMethod("receiveMessage", result);
        }
      });
   
  }

  @ReactMethod
  public void getStoreData(String param1) {
    // Your native code to retrieve data here
    Activity activity = getCurrentActivity();
    if (activity == null) {
        return;
      }
    String result = param1;
    
    activity.runOnUiThread(new Runnable() {

        @Override
        public void run() {
          if (channel == null) {
            
            channel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "my_channel");
          }
  
          channel.invokeMethod("storeData", result);
        }
      });
   
  }

}
