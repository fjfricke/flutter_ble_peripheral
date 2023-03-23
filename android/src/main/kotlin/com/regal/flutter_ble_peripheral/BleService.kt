package com.regal.flutter_ble_peripheral

import android.bluetooth.BluetoothGattCharacteristic
import android.bluetooth.BluetoothGattService
import java.util.UUID

data class BleService(
    val uuid: UUID,
    val characteristics: List<BleCharacteristic>
) {
    companion object {
        fun fromMap(map: Map<String, Any>): BleService? {
            val uuidString = map["uuid"] as? String
            val characteristicsData = map["characteristics"] as? List<Map<String, Any>>
            if (uuidString != null && characteristicsData != null) {
                val uuid = UUID.fromString(uuidString)
                val characteristics = characteristicsData.mapNotNull { BleCharacteristic.fromMap(it) }
                return BleService(uuid, characteristics)
            }
            return null
        }
    }

    fun toGattService(): BluetoothGattService {
        val gattService = BluetoothGattService(uuid, BluetoothGattService.SERVICE_TYPE_PRIMARY)
        characteristics.forEach { characteristic ->
            gattService.addCharacteristic(characteristic.toGattCharacteristic())
        }
        return gattService
    }
}
