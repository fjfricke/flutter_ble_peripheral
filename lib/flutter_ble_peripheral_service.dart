import 'flutter_ble_peripheral_characteristic.dart';

class FlutterBlePeripheralService {
  final String uuid;
  final List<FlutterBlePeripheralCharacteristic> characteristics;

  FlutterBlePeripheralService({required this.uuid, required this.characteristics});

  // Convert the service to a map
  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'characteristics': characteristics.map((c) => c.toMap()).toList(),
    };
  }
}