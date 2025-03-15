package com.example.greenchoice

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.greenchoice/pytorch"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "runModel") {
                val input = call.argument<FloatArray>("input")
                val model = PyTorchModel(assets)
                model.loadModel("model.pt")
                val output = model.runInference(input!!)
                result.success(output)
            } else {
                result.notImplemented()
            }
        }
    }
}
