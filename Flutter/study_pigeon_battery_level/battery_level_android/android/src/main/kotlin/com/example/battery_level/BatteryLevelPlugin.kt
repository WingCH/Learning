// Copyright 2024 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.battery_level

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding

/** BatteryLevelPlugin */
class BatteryLevelPlugin : FlutterPlugin, BatteryLevelApi {
    private var context: Context? = null

    override fun onAttachedToEngine(binding: FlutterPluginBinding) {
        context = binding.applicationContext
        BatteryLevelApi.setUp(binding.binaryMessenger, this)
    }

    override fun onDetachedFromEngine(binding: FlutterPluginBinding) {
        context = null
        BatteryLevelApi.setUp(binding.binaryMessenger, null)
    }

    override fun getBatteryLevel(): Long {
        val batteryLevel: Int = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            val batteryManager = context?.getSystemService(Context.BATTERY_SERVICE) as? BatteryManager
            batteryManager?.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY) ?: -1
        } else {
            val intent = context?.registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
            val level = intent?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
            val scale = intent?.getIntExtra(BatteryManager.EXTRA_SCALE, -1) ?: -1
            if (level != -1 && scale != -1) {
                (level * 100 / scale)
            } else {
                -1
            }
        }
        return batteryLevel.toLong()
    }

    override fun getBatteryState(): PlatformBatteryState {
        val intent = context?.registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
        val status = intent?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) ?: -1
        
        return when (status) {
            BatteryManager.BATTERY_STATUS_CHARGING -> PlatformBatteryState.CHARGING
            BatteryManager.BATTERY_STATUS_DISCHARGING -> PlatformBatteryState.DISCHARGING
            BatteryManager.BATTERY_STATUS_FULL -> PlatformBatteryState.FULL
            BatteryManager.BATTERY_STATUS_NOT_CHARGING -> PlatformBatteryState.DISCHARGING
            else -> PlatformBatteryState.UNKNOWN
        }
    }

    override fun getBatteryInfo(): BatteryInfo {
        return BatteryInfo(
            level = getBatteryLevel(),
            state = getBatteryState()
        )
    }
}
