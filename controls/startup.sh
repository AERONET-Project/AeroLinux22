#!/bin/bash
ROOT_DIR=$(HOME)/aerolinux1

modem_check=$(lsusb | grep Qualcomm)
if [ -z "$modem_check" ]; then
	$(ROOT_DIR)/cimel_connect/models_connect_and_reset local
else
	$(ROOT_DIR)/cimel_connect/models_connect_and_reset hologram
fi
