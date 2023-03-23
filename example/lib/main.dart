import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral_characteristic.dart';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Flutter BLE Peripheral Example')),
        body: const Center(child: BlePeripheralWidget()),
      ),
    );
  }
}

class BlePeripheralWidget extends StatefulWidget {
  const BlePeripheralWidget({Key? key}) : super(key: key);

  @override
  _BlePeripheralWidgetState createState() => _BlePeripheralWidgetState();
}

class _BlePeripheralWidgetState extends State<BlePeripheralWidget> {
  final FlutterBlePeripheral _blePeripheral = FlutterBlePeripheral();
  final characteristic = FlutterBlePeripheralCharacteristic(
    uuid: '00402A37-0000-1000-8000-00805F9B34FB',
    hasNotify: true,
    isReadable: true,
    isWritable: true,
  );
  late final FlutterBlePeripheralService service;
  bool _isAdvertising = false;
  String receivedText = '';

  @override
  void initState() {
    super.initState();
    _blePeripheral.initialize();
    service = FlutterBlePeripheralService(
      uuid: '0010180D-0000-1000-8000-00805F9B34FB',
      characteristics: [characteristic],
    );
    _blePeripheral.addCharacteristicToUpdateCallback(characteristic, _updateCallback);
  }

  @override
  void dispose() {
    _blePeripheral.stopAdvertising();
    super.dispose();
  }

  void _updateCallback(List<int> value) {
    setState(() {
      receivedText = String.fromCharCodes(value);
    });
  }


  void _toggleAdvertising() async {
    if (_isAdvertising) {
      await _blePeripheral.stopAdvertising();
    } else {
      await _blePeripheral.addService(service);
      // advertise service
      await _blePeripheral.startAdvertising({
        'localName': 'Flutter BLE Peripheral',
      });
    }
    setState(() {
      _isAdvertising = !_isAdvertising;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'BLE Advertising: ${_isAdvertising ? 'ON' : 'OFF'}',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: _toggleAdvertising,
          child: Text(_isAdvertising ? 'Stop Advertising' : 'Start Advertising'),
        ),
        // text input and button to update value of created service
        TextField(
          decoration: const InputDecoration(
            hintText: 'Input data to send',
          ),
          onChanged: (value) async {
              await _blePeripheral.sendData(
                characteristic,
                value.codeUnits,
              );
          },
        ),
        Text(
          'Received Text: $receivedText',
        )
      ],
    );
  }
}
