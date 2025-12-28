#!/usr/bin/env bash
#
# toggle-paste-summary.sh
# 
# Toggle the experimental.disable_paste_summary configuration option in OpenCode
#
# Usage:
#   toggle-paste-summary.sh           # Toggle current value
#   toggle-paste-summary.sh --enable  # Set to true (disable paste summary)
#   toggle-paste-summary.sh --disable # Set to false (enable paste summary)
#   toggle-paste-summary.sh --status  # Show current value without changing
#   toggle-paste-summary.sh --help    # Show this help message
#
# Version: 1.0.0

set -euo pipefail

# Configuration
readonly CONFIG_FILE="$HOME/.config/opencode/opencode.json"
readonly SCRIPT_NAME="$(basename "$0")"

# Color codes for output
readonly COLOR_RESET='\033[0m'
readonly COLOR_INFO='\033[0;34m'
readonly COLOR_SUCCESS='\033[0;32m'
readonly COLOR_ERROR='\033[0;31m'
readonly COLOR_WARN='\033[0;33m'

#######################################
# Print info message to stderr
# Arguments:
#   Message to print
#######################################
print_info() {
  echo -e "${COLOR_INFO}ℹ${COLOR_RESET} $*" >&2
}

#######################################
# Print error message to stderr
# Arguments:
#   Message to print
#######################################
print_error() {
  echo -e "${COLOR_ERROR}✗${COLOR_RESET} $*" >&2
}

#######################################
# Print success message to stderr
# Arguments:
#   Message to print
#######################################
print_success() {
  echo -e "${COLOR_SUCCESS}✓${COLOR_RESET} $*" >&2
}

#######################################
# Print warning message to stderr
# Arguments:
#   Message to print
#######################################
print_warn() {
  echo -e "${COLOR_WARN}⚠${COLOR_RESET} $*" >&2
}

#######################################
# Check if required dependencies are installed
# Returns:
#   0 if all dependencies are available, 1 otherwise
#######################################
check_dependencies() {
  if ! command -v jq &> /dev/null; then
    print_error "jq is required but not installed."
    print_info "Install with: brew install jq (macOS) or apt-get install jq (Linux)"
    return 1
  fi
  return 0
}

#######################################
# Create a timestamped backup of the configuration file
# Returns:
#   0 on success, 1 on failure
#######################################
backup_config() {
  local timestamp
  timestamp="$(date +%Y%m%d_%H%M%S)"
  local backup_file="${CONFIG_FILE}.backup.${timestamp}"
  
  if cp "$CONFIG_FILE" "$backup_file"; then
    print_info "Backup created: ${backup_file}"
    return 0
  else
    print_error "Failed to create backup"
    return 1
  fi
}

#######################################
# Get the current value of disable_paste_summary
# Returns:
#   Echoes "true" or "false", returns 0 on success, 1 on error
#######################################
get_current_value() {
  local value
  
  # Check if the file exists and is valid JSON
  if ! jq empty "$CONFIG_FILE" 2>/dev/null; then
    print_error "Configuration file contains invalid JSON"
    return 1
  fi
  
  # Try to get the value, default to false if not present
  value=$(jq -r '.experimental.disable_paste_summary // false' "$CONFIG_FILE" 2>/dev/null)
  
  echo "$value"
  return 0
}

#######################################
# Show usage information
#######################################
show_help() {
  cat << EOF
Usage: $SCRIPT_NAME [OPTIONS]

Toggle the experimental.disable_paste_summary configuration option in OpenCode.

OPTIONS:
  (none)      Toggle the current value
  --enable    Set to true (disable paste summary feature)
  --disable   Set to false (enable paste summary feature)
  --status    Show current value without modifying
  --help      Show this help message

EXAMPLES:
  $SCRIPT_NAME              # Toggle current setting
  $SCRIPT_NAME --enable     # Disable paste summary
  $SCRIPT_NAME --disable    # Enable paste summary
  $SCRIPT_NAME --status     # Check current setting

CONFIGURATION:
  File: $CONFIG_FILE
  Setting: experimental.disable_paste_summary

EOF
}

#######################################
# Determine the new value based on current value and arguments
# Arguments:
#   $1 - Current value ("true" or "false")
#   $2 - Mode ("toggle", "enable", "disable")
# Returns:
#   Echoes "true" or "false"
#######################################
determine_new_value() {
  local current="$1"
  local mode="$2"
  
  case "$mode" in
    enable)
      echo "true"
      ;;
    disable)
      echo "false"
      ;;
    toggle)
      if [[ "$current" == "true" ]]; then
        echo "false"
      else
        echo "true"
      fi
      ;;
    *)
      echo "$current"
      ;;
  esac
}

#######################################
# Update the configuration file with new value
# Arguments:
#   $1 - New value ("true" or "false")
# Returns:
#   0 on success, 1 on failure
#######################################
update_config() {
  local new_value="$1"
  local temp_file
  temp_file="$(mktemp)"
  
  # Check if experimental object exists
  local has_experimental
  has_experimental=$(jq -r 'has("experimental")' "$CONFIG_FILE")
  
  if [[ "$has_experimental" == "true" ]]; then
    # Update existing experimental.disable_paste_summary
    if ! jq --indent 2 ".experimental.disable_paste_summary = $new_value" "$CONFIG_FILE" > "$temp_file"; then
      rm -f "$temp_file"
      print_error "Failed to update JSON"
      return 1
    fi
  else
    # Create experimental object with disable_paste_summary
    if ! jq --indent 2 ". + {\"experimental\": {\"disable_paste_summary\": $new_value}}" "$CONFIG_FILE" > "$temp_file"; then
      rm -f "$temp_file"
      print_error "Failed to create experimental object"
      return 1
    fi
  fi
  
  # Validate the output is valid JSON
  if ! jq empty "$temp_file" 2>/dev/null; then
    print_error "Generated invalid JSON during update"
    rm -f "$temp_file"
    return 1
  fi
  
  # Atomically replace the original file
  if ! mv "$temp_file" "$CONFIG_FILE"; then
    print_error "Failed to update configuration file"
    rm -f "$temp_file"
    return 1
  fi
  
  # Cleanup temp file if it still exists
  rm -f "$temp_file"
  return 0
}

#######################################
# Parse command line arguments
# Arguments:
#   All script arguments
# Returns:
#   Echoes mode ("toggle", "enable", "disable", "status", "help")
#######################################
parse_arguments() {
  local mode="toggle"
  
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --help|-h)
        mode="help"
        shift
        ;;
      --enable)
        if [[ "$mode" != "toggle" ]]; then
          print_error "Conflicting flags: cannot use --enable with other mode flags"
          exit 1
        fi
        mode="enable"
        shift
        ;;
      --disable)
        if [[ "$mode" != "toggle" ]]; then
          print_error "Conflicting flags: cannot use --disable with other mode flags"
          exit 1
        fi
        mode="disable"
        shift
        ;;
      --status)
        if [[ "$mode" != "toggle" ]]; then
          print_error "Conflicting flags: cannot use --status with other mode flags"
          exit 1
        fi
        mode="status"
        shift
        ;;
      *)
        print_error "Unknown option: $1"
        print_info "Use --help for usage information"
        exit 1
        ;;
    esac
  done
  
  echo "$mode"
}

#######################################
# Main execution function
#######################################
main() {
  local mode
  local current_value
  local new_value
  
  # Parse arguments
  mode=$(parse_arguments "$@")
  
  # Handle help
  if [[ "$mode" == "help" ]]; then
    show_help
    exit 0
  fi
  
  # Check dependencies
  if ! check_dependencies; then
    exit 1
  fi
  
  # Verify config file exists
  if [[ ! -f "$CONFIG_FILE" ]]; then
    print_error "Configuration file not found: $CONFIG_FILE"
    exit 1
  fi
  
  # Check read permissions
  if [[ ! -r "$CONFIG_FILE" ]]; then
    print_error "Cannot read configuration file: $CONFIG_FILE"
    exit 1
  fi
  
  # Get current value
  if ! current_value=$(get_current_value); then
    exit 1
  fi
  
  # Display current value
  print_info "Current setting: disable_paste_summary = $current_value"
  
  # Handle status mode
  if [[ "$mode" == "status" ]]; then
    if [[ "$current_value" == "true" ]]; then
      print_info "Paste summary is currently DISABLED"
    else
      print_info "Paste summary is currently ENABLED"
    fi
    exit 0
  fi
  
  # Check write permissions
  if [[ ! -w "$CONFIG_FILE" ]]; then
    print_error "Cannot write to configuration file: $CONFIG_FILE"
    exit 1
  fi
  
  # Determine new value
  new_value=$(determine_new_value "$current_value" "$mode")
  
  # Check if change is needed
  if [[ "$current_value" == "$new_value" ]]; then
    print_info "Setting is already set to $new_value, no change needed"
    exit 0
  fi
  
  # Create backup
  if ! backup_config; then
    exit 1
  fi
  
  # Update configuration
  if update_config "$new_value"; then
    print_success "Updated setting: disable_paste_summary = $new_value"
    if [[ "$new_value" == "true" ]]; then
      print_success "Paste summary is now DISABLED"
    else
      print_success "Paste summary is now ENABLED"
    fi
  else
    print_error "Failed to update configuration"
    exit 1
  fi
}

# Run main function with all arguments
main "$@"
