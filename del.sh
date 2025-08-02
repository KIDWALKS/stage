#!/bin/bash

# ------------------------------------
# CONFIGURATION
# ------------------------------------
RUNNERS_BASE_DIR="/opt/github-runner-multi"
REMOVE_TOKEN="REPLACE_WITH_REAL_TOKEN"  # Temporary token from GitHub org runner removal screen (valid 1hr)

echo "🚨 Starting GitHub Runner cleanup process..."

# Loop through all runner directories
for runner_dir in "$RUNNERS_BASE_DIR"/*; do
    if [[ -d "$runner_dir" && -f "$runner_dir/config.sh" ]]; then
        echo "🔍 Found runner: $runner_dir"
        cd "$runner_dir" || continue

        # -------------------------------
        # Stop and clean systemd service
        # -------------------------------
        SERVICE_NAME=$(basename "$runner_dir" | sed 's/^/github-/')
        if sudo systemctl list-units --type=service | grep -q "$SERVICE_NAME"; then
            echo "🛑 Stopping systemd service: $SERVICE_NAME"
            sudo systemctl stop "$SERVICE_NAME" || true
            sudo systemctl disable "$SERVICE_NAME" || true
            sudo rm -f "/etc/systemd/system/$SERVICE_NAME.service"
            sudo systemctl daemon-reload
        else
            echo "ℹ️ No systemd service found for: $SERVICE_NAME"
        fi

        # -------------------------------
        # Unregister runner from GitHub
        # -------------------------------
        if [ -n "$REMOVE_TOKEN" ]; then
            echo "🔓 Removing runner with token..."
            ./config.sh remove --unattended --token "$REMOVE_TOKEN" || echo "⚠️ Failed to unregister with token"
        else
            echo "🔓 Removing runner without token..."
            ./config.sh remove --unattended || echo "⚠️ Failed to unregister"
        fi

        # -------------------------------
        # Delete runner directory
        # -------------------------------
        echo "🧹 Deleting runner directory: $runner_dir"
        rm -rf "$runner_dir"

        echo "✅ Cleaned: $(basename "$runner_dir")"
    fi
done

echo "🎉 All GitHub runners have been processed and cleaned."
