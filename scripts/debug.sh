#!/bin/bash

# Android

## Pair the device via ADB (update host, port, and code)
adb pair 192.168.1.100:5555 123456

## Connect to the device via ADB
adb connect 192.168.1.100:5555
