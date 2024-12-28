#!/bin/bash

# Check if the script is run with sudo
if [ "$(id -u)" -ne "0" ]; then
    echo "[!] This script must be run with sudo."
    exit 1
fi

# Variables
PRIVATE_KEY="/etc/ssl/private/signmod.priv"
CERTIFICATE_DER="/etc/ssl/certs/signmod.der"
CERTIFICATE_PEM="/etc/ssl/certs/signmod.pem"
SIGNMOD_SRC="src/signmod"
SIGNMOD_DST="/usr/local/bin/signmod"
KEY_SIZE=2048
DAYS_VALID=3650
CERT_SUBJECT="/C=IN/ST=AndhraPradesh/L=Visakhapatnam/O=fCoderSociety/CN=signmod"

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

    echo "[#] Setting permissions..."

    chmod 600 "$PRIVATE_KEY" || { echo "[!] Failed to set permissions for private key"; exit 1; }
    chmod 644 "$CERTIFICATE_PEM" || { echo "[!] Failed to set permissions for PEM certificate"; exit 1; }
    chmod 644 "$CERTIFICATE_DER" || { echo "[!] Failed to set permissions for DER certificate"; exit 1; }
    chown root:root "$PRIVATE_KEY" "$CERTIFICATE_PEM" "$CERTIFICATE_DER" || { echo "[!] Failed to change ownership"; exit 1; }
    echo ""
}

# Function to register the certificate with MOK
register_mok() {
    echo "[#] Registering the certificate with MOK (reboot required) ..."
    echo ""

    # Check if certificate exists or not
    if [ ! -f "$CERTIFICATE_DER" ]; then
        echo "[#] Certificate file not found at $CERTIFICATE_DER."
        exit 1
    fi

    # Installing certificate in MOK
    echo "[#] Set a password for MOK enrollment now, and use the same password during enrollment after the reboot."
    mokutil --import "$CERTIFICATE_DER" || { echo "[!] Failed to register certificate with MOK"; exit 1; }
    echo "[#] Certificate registered successfully."
    echo ""
}


# Function to install the signmod script
install_signmod() {
    echo "[#] Installing signmod script ..."

    # Check if the signmod script exists in the current directory
    if [ ! -f "$SIGNMOD_SRC" ]; then
        echo "[!] signmod script not found"
        exit 1
    fi

    # Copy the script to /usr/local/bin and make it executable
    cp "$SIGNMOD_SRC" "$SIGNMOD_DST" || { echo "[!] Failed to copy signmod script"; exit 1; }
    chmod +x "$SIGNMOD_DST" || { echo "[!] Failed to make signmod script executable"; exit 1; }
    echo "[#] signmod script installed successfully at $SIGNMOD_DST"
    echo ""
}

# Main script execution
banner
install_packages
########################################################################################
# Comment out this section if you dont need to generate and register the keys with MOK
generate_keys
register_mok
########################################################################################
install_signmod

echo "[#] signmod installation completed. Reboot your system to complete the key enrollment."
echo ""
