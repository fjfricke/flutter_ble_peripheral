import CoreBluetooth

struct BleCharacteristic {
    let uuid: CBUUID
    let properties: CBCharacteristicProperties
    let permissions: CBAttributePermissions

    static func fromMap(_ map: [String: Any]) -> BleCharacteristic? {
        guard let uuidString = map["uuid"] as? String,
              let isReadable = map["isReadable"] as? Bool,
              let isWritable = map["isWritable"] as? Bool,
              let hasNotify = map["hasNotify"] as? Bool else {
            return nil
        }
        
        let uuid = CBUUID(string: uuidString)

        var properties: CBCharacteristicProperties = []
        var permissions: CBAttributePermissions = []

        if isReadable {
            properties.insert(.read)
            permissions.insert(.readable)
        }

        if isWritable {
            properties.insert(.write)
            permissions.insert(.writeable)
        }

        if hasNotify {
            properties.insert(.notify)
        }

        return BleCharacteristic(uuid: uuid, properties: properties, permissions: permissions)
    }

    func toMutableCharacteristic() -> CBMutableCharacteristic {
        let mutableCharacteristic = CBMutableCharacteristic(type: uuid, properties: properties, value: nil, permissions: permissions)
        return mutableCharacteristic
    }
}
