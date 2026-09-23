#!/bin/bash
# ==============================================================================
# 🛰️ MATRIX PREAMBLE: ANONYMOUS PUBLIC HOST PROVISIONER
# ==============================================================================
mkdir -p "$HOME/.local/bin" "$HOME/.config/autostart"

echo "⚙️ Initializing unprivileged host-side listener matrix..."

# 1. Write the background listener directly into the local host profile
cat << 'EOF' > "$HOME/.local/bin/matrix_listener.sh"
#!/bin/bash
TARGET_LABEL="MATRIX_VAULT"
EXPECTED_PATH="/media/$USER/$TARGET_LABEL"

dbus-monitor --profile "type='signal',interface='org.freedesktop.UDisks2.Job',member='Completed'" | while read -r line; do
    if [ -d "$EXPECTED_PATH" ]; then
        if [ ! -f "/tmp/.matrix_active_marker" ]; then
            touch /tmp/.matrix_active_marker
            # Execute the proprietary, token-encrypted driver script directly from the USB
            if [ -f "$EXPECTED_PATH/run.sh" ]; then
                bash "$EXPECTED_PATH/run.sh"
            fi
        fi
    else
        if [ -f "/tmp/.matrix_active_marker" ]; then
            rm -f /tmp/.matrix_active_marker
            pkill -f gatekeeper_socket.py 2>/dev/null || true
            rm -f /tmp/.matrix_gitconfig
        fi
    fi
done
EOF

chmod +x "$HOME/.local/bin/matrix_listener.sh"

# 2. Register the listener inside the XDG Desktop Autostart sequence
cat << EOF > "$HOME/.config/autostart/matrix_hardware_trigger.desktop"
[Desktop Entry]
Type=Application
Name=Matrix USB Insertion Daemon
Exec=/bin/bash "$HOME/.local/bin/matrix_listener.sh"
Terminal=false
X-GNOME-Autostart-enabled=true
EOF

# 3. Immediately launch the background listener in user space
/bin/bash "$HOME/.local/bin/matrix_listener.sh" &

echo "=========================================================="
echo "✔ PREAMBLE COMPLIMENTED: Host is prepped and listening."
echo "👉 Slide in your proprietary USB Key to begin onboarding."
echo "=========================================================="
