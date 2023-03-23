import CoreBluetooth

typealias CharacteristicUpdateCallback = (CBCharacteristic, [UInt8]) -> Void

class PeripheralManager: NSObject, CBPeripheralManagerDelegate {
    private var peripheralManager: CBPeripheralManager!
    private var services: [CBMutableService] = []
    private var characteristicUpdateCallback: CharacteristicUpdateCallback?
    
    private let onDeviceConnected: (String) -> Void
    private let onDeviceDisconnected: (String) -> Void

    init(onDeviceConnected: @escaping (String) -> Void, onDeviceDisconnected: @escaping (String) -> Void) {
        self.onDeviceConnected = onDeviceConnected
        self.onDeviceDisconnected = onDeviceDisconnected
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }

    func startAdvertising(args: [String: Any]) {
        let localName = args["localName"] as? String ?? ""
        let advertisementData: [String: Any] = [
            CBAdvertisementDataLocalNameKey: localName,
            CBAdvertisementDataServiceUUIDsKey: services.map { $0.uuid }
        ]
        peripheralManager.startAdvertising(advertisementData)
    }

    func stopAdvertising() {
        peripheralManager.stopAdvertising()
    }

    func addService(service: BleService) {
        let mutableService = service.toMutableService()
        services.append(mutableService)
        peripheralManager.add(mutableService)
    }

    func sendData(characteristicUUID: CBUUID, data: Data) {
        guard let service = services.first(where: { $0.characteristics?.contains(where: { $0.uuid == characteristicUUID }) ?? false }),
              let characteristic = service.characteristics?.first(where: { $0.uuid == characteristicUUID }) as? CBMutableCharacteristic
        else { return }
        peripheralManager.updateValue(data, for: characteristic, onSubscribedCentrals: nil)
    }
    
    func setCharacteristicValueUpdateCallback(callback: @escaping CharacteristicUpdateCallback) {
        characteristicUpdateCallback = callback
    }

    // CBPeripheralManagerDelegate
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            print("Peripheral is powered on")
        } else {
            print("Peripheral is not powered on")
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for request in requests {
            if let value = request.value {
                characteristicUpdateCallback?(request.characteristic, Array(value))
            }
            peripheralManager.respond(to: request, withResult: .success)
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        self.onDeviceConnected(central.identifier.uuidString)
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        self.onDeviceDisconnected(central.identifier.uuidString)
    }
}
