#!/bin/bash

# Check if the script is run with sudo
if [ "$(id -u)" -ne "0" ]; then
    echo "[!] This script must be run with sudo."
    exit 1
fi

# Variables
SCRIPT_NAME="signmod"
KEY_DIR="/etc/ssl/private"
CERT_DIR="/etc/ssl/certs"
PRIVATE_KEY="$KEY_DIR/$SCRIPT_NAME.priv"
CERTIFICATE_DER="$CERT_DIR/$SCRIPT_NAME.der"
CERTIFICATE_PEM="$CERT_DIR/$SCRIPT_NAME.pem"
SIGNMOD_DST="/usr/local/bin/signmod"

# Function to display banner
banner() {
    clear
    echo "##############################################################"
    echo "#------------------------------------------------------------#"
    echo "#                        signmod                             #"
    echo "#------------------------------------------------------------#"
    echo "################## Author: cipherswami #######################"
    echo ""
}

# Function to remove signmod script
remove_signmod() {
    echo "[#] Removing signmod script from /usr/local/bin ..."
    if [ -f "$SIGNMOD_DST" ]; then
        rm -f "$SIGNMOD_DST" || { echo "[!] Failed to remove signmod script"; exit 1; }
        echo "[#] signmod script removed successfully."
    else
        echo "[#] signmod script not found. Skipping."
    fi
    echo ""
}

# Function to unregister the certificate from MOK
unregister_mok() {
    echo "[#] Unregistering the certificate from MOK (reboot required) ..."
    mokutil --delete "$CERTIFICATE_DER" || { echo "[!] Failed to unregister MOK"; exit 1; }
    echo "[#] Certificate scheduled for removal. Reboot to complete the process."
    echo ""
}

# Function to remove keys and certificates
remove_keys() {
    echo "[#] Removing private key and certificates..."
    rm -f "$PRIVATE_KEY" "$CERTIFICATE_DER" "$CERTIFICATE_PEM" || { echo "[!] Failed to remove keys or certificates"; exit 1; }
    echo "[#] Keys and certificates removed successfully."
    echo ""
}

# Main script execution
banner
remove_signmod
unregister_mok
remove_keys

echo "[#] signmod uninstallation completed."
echo ""
