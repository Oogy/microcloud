#!/usr/bin/env bash

system_is_raspberry_pi() {
  local model_file="/proc/device-tree/model"

  [ -f "$model_file" ] && tr -d '\0' <"$model_file" | grep -qi "raspberry pi"
}

system_read_sysfs_serial() {
  local path="$1"

  if [ -f "$path" ]; then
    tr -d '\0' <"$path"
    return 0
  fi

  return 1
}

system_device_serial() {
  local serial=""

  if system_is_raspberry_pi; then
    serial="$(system_read_sysfs_serial /sys/firmware/devicetree/base/serial-number || true)"
    if [ -n "$serial" ]; then
      echo "$serial"
      return 0
    fi
  fi

  serial="$(system_read_sysfs_serial /sys/class/dmi/id/chassis_serial || true)"
  if [ -n "$serial" ] && [ "$serial" != "None" ] && [ "$serial" != "To be filled by O.E.M." ]; then
    echo "$serial"
    return 0
  fi

  if command -v dmidecode >/dev/null 2>&1; then
    serial="$(dmidecode -s chassis-serial-number 2>/dev/null || true)"
    if [ -n "$serial" ] && [ "$serial" != "None" ] && [ "$serial" != "To be filled by O.E.M." ]; then
      echo "$serial"
      return 0
    fi
  fi

  return 1
}
