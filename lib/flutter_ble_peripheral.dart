import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral_characteristic.dart';
import 'flutter_ble_peripheral_service.dart';
import 'flutter_ble_peripheral_constants.dart';

class FlutterBlePeripheral {
  static const MethodChannel _channel =
  MethodChannel(FlutterBlePeripheralConstants.methodChannel);

  final List<FlutterBlePeripheralService> _services = [];
  final Map<FlutterBlePeripheralCharacteristic, Function(List<int>)> _notifiedCharacteristics_with_callback = {};

  Function(String)? _onDeviceConnected;
  Function(String)? _onDeviceDisconnected;

  // Initialize peripheral
  Future<bool> initialize() async {
    await _channel.invokeMethod(FlutterBlePeripheralConstants.initialize);
    return true;
  }

  // Start advertising
  Future<bool> startAdvertising(Map<String, dynamic> advertisementData) async {
    await _channel.invokeMethod(
        FlutterBlePeripheralConstants.startAdvertising, advertisementData);
    return true;
  }

  // Stop advertising
  Future<bool> stopAdvertising() async {
    await _channel.invokeMethod(FlutterBlePeripheralConstants.stopAdvertising);
    return true;
  }

  // Add service
  Future<void> addService(FlutterBlePeripheralService service) async {
    await _channel.invokeMethod(
        FlutterBlePeripheralConstants.addService, service.toMap());
    _services.add(service);
  }

  // Send data
  Future<void> sendData(FlutterBlePeripheralCharacteristic characteristic, List<int> data) async {
    await _channel.invokeMethod(FlutterBlePeripheralConstants.sendData, {
      'characteristicUUID': characteristic.uuid,
      'data': data,
    });
  }

  Future<void> addCharacteristicToUpdateCallback(FlutterBlePeripheralCharacteristic characteristic, Function(List<int>) callback) async {
    _notifiedCharacteristics_with_callback[characteristic] = callback;
    await _updateMethodCallHandler();
  }

  Future<void> deleteCharacteristicToUpdateCallback(FlutterBlePeripheralCharacteristic characteristic) async {
    _notifiedCharacteristics_with_callback.remove(characteristic);
    await _updateMethodCallHandler();
  }

  void setOnDeviceConnectedCallback(Function(String) callback) {
    _onDeviceConnected = callback;
  }

  void setOnDeviceDisconnectedCallback(Function(String) callback) {
    _onDeviceDisconnected = callback;
  }

  Future<void> _updateMethodCallHandler() async {
    // set args to contain all uuids from _notifiedCharacteristics_with_callback keys

    // // delete MethodCallHandler if it already exists
    // _channel.setMethodCallHandler(null);
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onCharacteristicUpdate' && _notifiedCharacteristics_with_callback.keys.any((c) => c.uuid == call.arguments['characteristicUUID'])) {
        final args = {
          'characteristicUUIDs': _notifiedCharacteristics_with_callback.keys.map((c) => c.uuid).toList(),
        };
        final characteristicUUID = call.arguments['characteristicUUID'];
        final characteristic = _notifiedCharacteristics_with_callback.keys.firstWhere((c) => c.uuid == characteristicUUID);
        final callback = _notifiedCharacteristics_with_callback[characteristic]!;
        final value = (call.arguments['value'] as List<dynamic>).cast<int>();
        callback(value);
        return _channel.invokeMethod('setCharacteristicValueUpdateCallback', args);
      }
      else if (call.method == 'onDeviceConnected') {
        final uuid = call.arguments['uuid'] as String;
        _onDeviceConnected?.call(uuid);
      } else if (call.method == 'onDeviceDisconnected') {
        final uuid = call.arguments['uuid'] as String;
        _onDeviceDisconnected?.call(uuid);
      }
    });
  }
}