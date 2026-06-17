#!/bin/bash
# =============================================================================
# shell/script.sh — Shared Logging Utility
# -----------------------------------------------------------------------------
# This script provides a reusable logging function used across all pipeline
# jobs. It is sourced (not executed) at the start of each pipeline step:
#
#   source shell/script.sh
#
# Why source instead of execute?
#   Sourcing runs the script in the current shell context, making the
#   log_message function available to all subsequent commands in that step.
#   Executing it as a subprocess would make the function invisible to the
#   calling shell.
#
# Usage in pipeline:
#   source shell/script.sh
#   log_message "Build started..."
#   log_message "Build complete."
# =============================================================================

# -----------------------------------------------------------------------------
# Log destination
# -----------------------------------------------------------------------------
# All log output is written to /dev/stdout so it appears directly in the
# GitHub Actions job log. Using a variable makes it easy to redirect to a
# file later if needed (e.g. LOG_FILE="/var/log/pipeline.log").
# -----------------------------------------------------------------------------
STDOUT="/dev/stdout"
LOG_FILE="$STDOUT"

# -----------------------------------------------------------------------------
# Default log message
# -----------------------------------------------------------------------------
# This message is logged automatically when the script is first sourced,
# confirming that the logging setup is working and showing the current date.
# It serves as a visible "script loaded" marker at the top of each job log.
# -----------------------------------------------------------------------------
LOG_MESSAGE="is the date, should log to $STDOUT"

# -----------------------------------------------------------------------------
# log_message() — timestamped logging function
# -----------------------------------------------------------------------------
# Prints a message to the log file with a timestamp prefix.
#
# Arguments:
#   $1 — the message string to log
#
# Output format:
#   [YYYY-MM-DD HH:MM:SS] <message>
#
# Example:
#   log_message "Pushing image to registry..."
#   → [2026-06-05 11:32:01] Pushing image to registry...
#
# Note: >> appends to LOG_FILE. Since LOG_FILE is /dev/stdout this is
# equivalent to echo, but the >> syntax works for both stdout and real files.
# -----------------------------------------------------------------------------
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Log the startup message when the script is sourced
# This confirms the script loaded successfully and shows the current timestamp
log_message "$LOG_MESSAGE"
