package com.regal.flutter_ble_peripheral

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class FlutterBlePeripheralPlugin : FlutterPlugin, MethodCallHandler {
  private lateinit var channel: MethodChannel
  private lateinit var peripheralManager: PeripheralManager

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, FlutterBlePeripheralConstants.methodChannel)
    channel.setMethodCallHandler(this)
    peripheralManager = PeripheralManager(flutterPluginBinding.applicationContext)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      FlutterBlePeripheralConstants.initialize -> {
        peripheralManager.initialize()
        result.success(null)
      }
      FlutterBlePeripheralConstants.startAdvertising -> {
        val advertisementData = call.arguments as? Map<String, Any>
        peripheralManager.startAdvertising(advertisementData)
        result.success(null)
      }
      FlutterBlePeripheralConstants.stopAdvertising -> {
        peripheralManager.stopAdvertising()
        result.success(null)
      }
      FlutterBlePeripheralConstants.addService -> {
        val serviceData = call.arguments as? Map<String, Any>
        if (serviceData != null) {
          val service = BleService.fromMap(serviceData)
          if (service != null) {
            peripheralManager.addService(service)
            result.success(null)
          } else {
            result.error("INVALID_ARGUMENTS", "Invalid service data", null)
          }
        } else {
          result.error("INVALID_ARGUMENTS", "Invalid arguments", null)
        }
      }
      FlutterBlePeripheralConstants.sendData -> {
        val arguments = call.arguments as? Map<String, Any>
        val characteristicUUID = arguments?.get("characteristicUUID") as? String
        val data = arguments?.get("data") as? List<Int>
        if (characteristicUUID != null && data != null) {
          peripheralManager.sendData(characteristicUUID, data)
          result.success(null)
        } else {
          result.error("INVALID_ARGUMENTS", "Invalid arguments", null)
        }
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
