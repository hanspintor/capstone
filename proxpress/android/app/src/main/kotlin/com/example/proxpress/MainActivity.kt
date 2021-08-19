package io.flutter.plugins.firebasecoreexample

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
    fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine?) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
    }
}