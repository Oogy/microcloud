#!/usr/bin/env bash

system_is_raspberry_pi() {
  local model_file="/proc/device-tree/model"

  [ -f "$model_file" ] && tr -d '\0' <"$model_file" | grep -qi "raspberry pi"
}

system_run_sudo() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  else
    sudo "$@"
  fi
}

system_read_sysfs_serial() {
  local path="$1"

  if [ -f "$path" ]; then
    tr -d '\0' <"$path"
    return 0
  fi

  return 1
}

system_cmdline_path() {
  if [ -f /boot/firmware/cmdline.txt ]; then
    echo /boot/firmware/cmdline.txt
    return 0
  fi

  if [ -f /boot/cmdline.txt ]; then
    echo /boot/cmdline.txt
    return 0
  fi

  return 1
}

system_cmdline_has_arg() {
  local arg="$1"

  grep -qE "(^|\\s)${arg}(\\s|$)" /proc/cmdline
}

system_enable_cgroup_memory_if_needed() {
  local cmdline_path
  local current
  local next

  if ! system_is_raspberry_pi; then
    return 0
  fi

  if system_cmdline_has_arg "cgroup_enable=memory" && system_cmdline_has_arg "cgroup_memory=1"; then
    return 0
  fi

  cmdline_path="$(system_cmdline_path || true)"
  if [ -z "$cmdline_path" ]; then
    echo "unable to find cmdline.txt" >&2
    return 1
  fi

  current="$(cat "$cmdline_path")"
  next="$current"

  if ! system_cmdline_has_arg "cgroup_enable=memory"; then
    next="$next cgroup_enable=memory"
  fi

  if ! system_cmdline_has_arg "cgroup_memory=1"; then
    next="$next cgroup_memory=1"
  fi

  if [ "$next" != "$current" ]; then
    system_run_sudo sh -c "printf '%s' \"$next\" > \"$cmdline_path\""
    return 10
  fi

  return 0
}

system_schedule_reboot() {
  if system_run_sudo systemctl reboot; then
    return 0
  fi

  system_run_sudo shutdown -r now
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
