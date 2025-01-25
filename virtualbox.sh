#!/bin/bash

# Function to create a raw device mapping for VirtualBox
create_raw_device() {
  # Check for help flag
  if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    _create_raw_device_help
    return 0
  fi

  # Default values
  local filename="./raw1.vmdk"
  local drive=""
  local format="VMDK"
  local variant="RawDisk"
  local chown_value="$(whoami):$(id -gn)"
  local chmod_value="0600"

  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --chown)
        chown_value="$2"
        shift 2
        ;;
      --chmod)
        chmod_value="$2"
        shift 2
        ;;
      --filename)
        filename="$2"
        shift 2
        ;;
      --drive)
        drive="$2"
        shift 2
        ;;
      --format)
        format="$2"
        shift 2
        ;;
      --variant)
        variant="$2"
        shift 2
        ;;
      *)
        echo "Unknown argument: $1"
        _create_raw_device_help
        return 1
        ;;
    esac
  done

  # Validate that the raw drive is specified
  if [[ -z "$drive" ]]; then
    echo "Error: No physical drive specified."
    _create_raw_device_help
    return 1
  fi

  # Validate that the raw drive exists
  if [[ ! -e "$drive" && ! "$drive" =~ ^PhysicalDrive[0-9]+$ ]]; then
    echo "Error: Invalid or non-existent raw drive specified: $drive"
    _create_raw_device_help
    return 1
  fi

  # Check if VBoxManage is installed
  _check_virtualbox_installed || return 1

  # Attempt to create the raw device mapping
  VBoxManage createmedium disk \
    --filename "$filename" \
    --format "$format" \
    --variant "$variant" \
    --property RawDrive="$drive" 2> /dev/null

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

  # Apply chown if specified
  if [[ -n "$chown_value" ]]; then
    chown "$chown_value" "$filename"
    if [[ $? -eq 0 ]]; then
      echo "Ownership set to: $chown_value"
    else
      echo "Warning: Failed to set ownership to: $chown_value"
    fi
  fi

  # Apply chmod if specified
  if [[ -n "$chmod_value" ]]; then
    chmod "$chmod_value" "$filename"
    if [[ $? -eq 0 ]]; then
      echo "Permissions set to: $chmod_value"
    else
      echo "Warning: Failed to set permissions to: $chmod_value"
    fi
  fi
}

# Function to display help information
_create_raw_device_help() {
  echo "Usage: create_raw_device --drive [physical_drive] [options]"
  echo ""
  echo "Required Parameters:"
  echo "  --drive         The physical drive to map, e.g., '/dev/sdx' or '/dev/nvmeXnY' (Linux) or 'PhysicalDriveX' (Windows)."
  echo ""
  echo "Optional Parameters:"
  echo "  --filename      Path to the raw device mapping file (default: './raw1.vmdk')."
  echo "  --format        The format of the raw device mapping file (default: 'VMDK')."
  echo "  --variant       The variant type, usually 'RawDisk' (default: 'RawDisk')."
  echo "  --chown         Set ownership of the resulting file (default: current user and group)."
  echo "  --chmod         Set permissions of the resulting file (default: '0600')."
  echo ""
  echo "Examples:"
  echo "  create_raw_device --drive '/dev/sdb' --filename './mydisk.vmdk' --chown 'user:group' --chmod '0644'"
  echo "      Creates './mydisk.vmdk' mapped to '/dev/sdb', sets ownership to 'user:group', and permissions to '0644'."
}

# Function to check if VirtualBox is installed
_check_virtualbox_installed() {
  if command -v VBoxManage &> /dev/null; then
    indent_message 3 "$SUCCESS_EMOJI VirtualBox is installed and VBoxManage is available."
    return 0
  else
    indent_message 3 "$FAILURE_EMOJI VirtualBox is not installed. Please install it and ensure VBoxManage is in your PATH."
    return 1
  fi
}

_check_virtualbox_installed true