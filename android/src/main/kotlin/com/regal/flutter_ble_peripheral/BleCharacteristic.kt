package com.regal.flutter_ble_peripheral

import android.bluetooth.BluetoothGattCharacteristic
import android.bluetooth.BluetoothGattService
import java.util.UUID

data class BleCharacteristic(
    val uuid: UUID,
    val properties: Int,
    val permissions: Int
) {
    companion object {
        fun fromMap(map: Map<String, Any>): BleCharacteristic? {
            val uuidString = map["uuid"] as? String
            val isReadable = map["isReadable"] as? Boolean ?: false
            val isWritable = map["isWritable"] as? Boolean ?: false
            val hasNotify = map["hasNotify"] as? Boolean ?: false

            if (uuidString != null) {
                val uuid = UUID.fromString(uuidString)
                var properties = 0
                var permissions = 0

                if (isReadable) {
                    properties = properties or BluetoothGattCharacteristic.PROPERTY_READ
                    permissions = permissions or BluetoothGattCharacteristic.PERMISSION_READ
                }

                if (isWritable) {
                    properties = properties or BluetoothGattCharacteristic.PROPERTY_WRITE
                    permissions = permissions or BluetoothGattCharacteristic.PERMISSION_WRITE
                }

                if (hasNotify) {
                    properties = properties or BluetoothGattCharacteristic.PROPERTY_NOTIFY
                }

                return BleCharacteristic(uuid, properties, permissions)
            }
            return null
        }
    }

    fun toGattCharacteristic(): BluetoothGattCharacteristic {
        return BluetoothGattCharacteristic(uuid, properties, permissions)
    }
}
