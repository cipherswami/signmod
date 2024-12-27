#!/bin/bash

# Check if the script is run with sudo
if [ "$(id -u)" -ne "0" ]; then
    echo "[!] This script must be run with sudo."
    exit 1
fi

# Variables
KEY_DIR="/etc/ssl/private"
CERT_DIR="/etc/ssl/certs"
PRIVATE_KEY="$KEY_DIR/MOK.priv"
CERTIFICATE_DER="$CERT_DIR/MOK.der"
CERTIFICATE_PEM="$CERT_DIR/MOK.pem"
KEY_SIZE=2048
DAYS_VALID=3650
CERT_SUBJECT="/C=IN/ST=AndhraPradesh/L=Visakhapatnam/O=fCoderSociety/OU=KernelDev/CN=KernelDevMods"
SIGNMOD_SCRIPT="signmod"
SIGNMOD_PATH="/usr/local/bin/$SIGNMOD_SCRIPT"

# Function to install req packages
install_packages() {
    echo "[#] Installing Req. Packages"
    apt-get update -y || { echo "[!] Failed to update package list"; exit 1; }
    apt-get install -y mokutil openssl || { echo "[!] Failed to install required packages"; exit 1; }
    echo ""
}

# Function to generate a new private key and self-signed certificate
generate_keys() {
    echo "[#] Generating a new private key and self-signed certificate..."

    # Generate private key and certificate in DER format
    openssl req -new -x509 -newkey rsa:$KEY_SIZE -keyout "$PRIVATE_KEY" -out "$CERTIFICATE_DER" -outform DER -nodes -days $DAYS_VALID -subj "$CERT_SUBJECT" || { echo "[!] Failed to generate keys"; exit 1; }

    # Convert DER to PEM format
    openssl x509 -in "$CERTIFICATE_DER" -out "$CERTIFICATE_PEM" -outform PEM || { echo "[!] Failed to convert DER to PEM"; exit 1; }
    echo ""
}

# Function to set appropriate permissions
set_permissions() {
    echo "[#] Setting permissions..."

    chmod 600 "$PRIVATE_KEY" || { echo "[!] Failed to set permissions for private key"; exit 1; }
    chmod 644 "$CERTIFICATE_PEM" || { echo "[!] Failed to set permissions for PEM certificate"; exit 1; }
    chmod 644 "$CERTIFICATE_DER" || { echo "[!] Failed to set permissions for DER certificate"; exit 1; }
    chown root:root "$PRIVATE_KEY" "$CERTIFICATE_PEM" "$CERTIFICATE_DER" || { echo "[!] Failed to change ownership"; exit 1; }
    echo ""
}

# Function to register the certificate with MOK
register_mok() {
    echo "[#] Registering the certificate with MOK..."
    mokutil --import "$CERTIFICATE_DER" || { echo "[!] Failed to register certificate with MOK"; exit 1; }

    echo "[#] A reboot is required to enroll the key. Please follow the prompts during boot to complete the enrollment."
    echo "Press Enter to continue..."
    read
}

# Function to install the signmod script
install_signmod_script() {
    echo "[#] Installing signmod script to /usr/local/bin..."

    # Check if the signmod script exists in the current directory
    if [ ! -f "$SIGNMOD_SCRIPT" ]; then
        echo "[!] signmod script not found in the current directory."
        exit 1
    fi

    # Copy the script to /usr/local/bin and make it executable
    cp "$SIGNMOD_SCRIPT" "$SIGNMOD_PATH" || { echo "[!] Failed to copy signmod script"; exit 1; }
    chmod +x "$SIGNMOD_PATH" || { echo "[!] Failed to make signmod script executable"; exit 1; }
    echo "[#] signmod script installed successfully at $SIGNMOD_PATH"
    echo ""
}

# Main script execution
echo "[#] Starting MOK installation..."
echo ""
install_packages
#####################################
#  Comment out this section if you  #
#     only need install signmod     #
#####################################
generate_keys
set_permissions
register_mok
####################################
install_signmod_script

echo "[#] MOK installation completed. Reboot your system to complete the key enrollment."
