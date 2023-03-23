class FlutterBlePeripheralCharacteristic {
  final String uuid;
  final bool isReadable;
  final bool isWritable;
  final bool hasNotify;

  FlutterBlePeripheralCharacteristic({
    required this.uuid,
    required this.isReadable,
    required this.isWritable,
    required this.hasNotify,
  });

  // Convert the characteristic to a map
  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'isReadable': isReadable,
      'isWritable': isWritable,
      'hasNotify': hasNotify,
    };
  }
}