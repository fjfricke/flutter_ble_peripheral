import CoreBluetooth

struct BleService {
    let uuid: CBUUID
    let characteristics: [BleCharacteristic]

    static func fromMap(_ map: [String: Any]) -> BleService? {
        guard let uuidString = map["uuid"] as? String,
              let characteristicsData = map["characteristics"] as? [[String: Any]] else {
            return nil
        }
        let uuid = CBUUID(string: uuidString)

        let characteristics = characteristicsData.compactMap { BleCharacteristic.fromMap($0) }
        return BleService(uuid: uuid, characteristics: characteristics)
    }

    func toMutableService() -> CBMutableService {
        let mutableCharacteristics = characteristics.map { $0.toMutableCharacteristic() }
        let mutableService = CBMutableService(type: uuid, primary: true)
        mutableService.characteristics = mutableCharacteristics
        return mutableService
    }
}
