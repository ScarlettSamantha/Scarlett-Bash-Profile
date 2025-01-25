#!/bin/bash

# Function to create a raw device mapping for VirtualBox
create_raw_device() {
  # Check for help flag
  if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    _create_raw_device_help
    return 0
  fi

  # Default values
  local filename=${1:-"./raw1.vmdk"}
  local drive=${2:-"PhysicalDrive1"}
  local format=${3:-"VMDK"}
  local variant=${4:-"RawDisk"}

  # Check if VBoxManage is installed
  if ! command -v VBoxManage &> /dev/null; then
    echo "Error: VBoxManage is not installed or not in PATH."
    _create_raw_device_help
    return 1
  fi

  # Validate that the raw drive exists
  if [[ ! -e "/dev/${drive}" && ! "$drive" =~ ^PhysicalDrive[0-9]+$ ]]; then
    echo "Error: Invalid or non-existent raw drive specified: $drive"
    _create_raw_device_help
    return 1
  fi

  # Attempt to create the raw device mapping
  VBoxManage createmedium disk \
    --filename "$filename" \
    --format "$format" \
    --variant "$variant" \
    --property RawDrive="\\\\.\\$drive" 2> /dev/null

  # Check if the command was successful
  if [[ $? -ne 0 ]]; then
    echo "Error: Failed to create raw device mapping."
    _create_raw_device_help
    return 1
  fi

  echo "Raw device mapping created successfully:"
  echo " - Filename: $filename"
  echo " - Drive: $drive"
  echo " - Format: $format"
  echo " - Variant: $variant"
}

# Function to display help information
_create_raw_device_help() {
  echo "Usage: create_raw_device [filename] [physical_drive] [format] [variant]"
  echo ""
  echo "Parameters:"
  echo "  filename       Path to the raw device mapping file (default: './raw1.vmdk')."
  echo "  physical_drive The physical drive to map, e.g., 'PhysicalDrive1' (default: 'PhysicalDrive1')."
  echo "  format         The format of the raw device mapping file (default: 'VMDK')."
  echo "  variant        The variant type, usually 'RawDisk' (default: 'RawDisk')."
  echo ""
  echo "Examples:"
  echo "  create_raw_device"
  echo "      Creates './raw1.vmdk' mapped to 'PhysicalDrive1' using default settings."
  echo ""
  echo "  create_raw_device './mydisk.vmdk' 'PhysicalDrive2'"
  echo "      Creates './mydisk.vmdk' mapped to 'PhysicalDrive2'."
  echo ""
  echo "  create_raw_device './mydisk.vmdk' 'PhysicalDrive2' 'VMDK' 'RawDisk'"
  echo "      Creates './mydisk.vmdk' mapped to 'PhysicalDrive2' with explicit format and variant."
  echo ""
  echo "  create_raw_device --help"
  echo "      Displays this help message."
}

# Function to check if VirtualBox is installed
_check_virtualbox_installed() {
  # Default the argument to "true" if not provided
  local check="${1:-true}"

  # If the argument is "false", skip the check
  if [[ "$check" == "false" ]]; then
    return 0
  fi

  # Check if VBoxManage command exists
  if command -v VBoxManage &> /dev/null; then
    indent_message 3 "$SUCCESS_EMOJI VirtualBox is installed."
    return 0
  else
    indent_message 3 "$FAILURE_EMOJI VirtualBox is not installed. Please install it and ensure VBoxManage is in your PATH."
    return 1
  fi
}

_check_virtualbox_installed true