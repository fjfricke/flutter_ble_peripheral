import Flutter
import UIKit
import CoreBluetooth

public class FlutterBlePeripheralPlugin: NSObject, FlutterPlugin {
    private var peripheralManager: PeripheralManager?
    private let channel: FlutterMethodChannel
    
    public init(channel: FlutterMethodChannel) {
        self.channel = channel
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: FlutterBlePeripheralConstants.methodChannel, binaryMessenger: registrar.messenger())
        let instance = FlutterBlePeripheralPlugin(channel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case FlutterBlePeripheralConstants.initialize:
            peripheralManager = PeripheralManager()
            result(nil)
        case FlutterBlePeripheralConstants.startAdvertising:
            if let args = call.arguments as? [String: Any] {
                peripheralManager?.startAdvertising(args: args)
                result(nil)
            } else {
                result(FlutterError.init(code: FlutterBlePeripheralError.invalidArguments.rawValue, message: "Invalid arguments", details: nil))
            }
        case FlutterBlePeripheralConstants.stopAdvertising:
            peripheralManager?.stopAdvertising()
            result(nil)
        case FlutterBlePeripheralConstants.addService:
            if let args = call.arguments as? [String: Any], let service = BleService.fromMap(args) {
                peripheralManager?.addService(service: service)
                result(nil)
            } else {
                result(FlutterError.init(code: FlutterBlePeripheralError.invalidArguments.rawValue, message: "Invalid arguments", details: nil))
            }
        case FlutterBlePeripheralConstants.sendData:
            if let args = call.arguments as? [String: Any], let uuidString = args["characteristicUUID"] as? String, let data = args["data"] as? [UInt8] {
                let uuid = CBUUID(string: uuidString)
                peripheralManager?.sendData(characteristicUUID: uuid, data: Data(data))
                result(nil)
            } else {
                result(FlutterError.init(code: FlutterBlePeripheralError.invalidArguments.rawValue, message: "Invalid arguments", details: nil))
            }
        case FlutterBlePeripheralConstants.setCharacteristicValueUpdateCallback:
            if let args = call.arguments as? [String: Any], let uuidStrings = args["characteristicUUIDs"] as? [String] {
               let uuids = uuidStrings.map { CBUUID(string: $0) }
                    peripheralManager?.setCharacteristicValueUpdateCallback { characteristic, data in
                        if uuids.contains(characteristic.uuid) {
                            let args: [String: Any] = [
                                "characteristicUUID": characteristic.uuid.uuidString,
                                "value": data
                            ]
                            self.channel.invokeMethod("onCharacteristicUpdate", arguments: args)
                        }
                    }
                    result(nil)
                } else {
                    result(FlutterError.init(code: FlutterBlePeripheralError.invalidArguments.rawValue, message: "Invalid arguments", details: nil))
                }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
//    private func setCharacteristicValueUpdateCallback(call: FlutterMethodCall, result: @escaping FlutterResult) {
//        guard let args = call.arguments as? [String: Any],
//              let characteristicUUIDString = args["characteristicUUID"] as? String else {
//            result(FlutterError(code: "invalid_argument", message: "Invalid arguments", details: nil))
//            return
//        }
//        guard let peripheralManager = peripheralManager else {
//            result(FlutterError(code: "peripheral_manager_unavailable", message: "Peripheral manager unavailable", details: nil))
//            return
//        }
//        let characteristicUUID = CBUUID(string: characteristicUUIDString)
//        let valueUpdateCallback = { (peripheral: CBPeripheral, characteristic: CBCharacteristic) in
//            let value = characteristic.value ?? Data()
//            let arguments: [String: Any] = [
//                "characteristicUUID": characteristic.uuid.uuidString,
//                "value": [UInt8](value)
//            ]
//            self.eventSink?("onCharacteristicUpdate", arguments)
//        }
//        valueUpdateCallbacks[characteristicUUID] = valueUpdateCallback
//        result(nil)
//    }

}
