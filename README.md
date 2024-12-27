# Kernel Module Signer :: CIPH3R <!-- omit in toc -->

**signmod** streamlines the process of signing custom kernel modules for secure boot enabled systems. The installation script generates a certificate/key pair, and enrolls the certificate in the MOK, and the private key is later used by signmod to sign the modules, enabling seamless module loading.

## Table of contents <!-- omit in toc -->
- [Installation](#installation)
- [Usage](#usage)
- [Uninstallation](#uninstallation)
- [Issues](#issues)

## Installation

1. **Install headers**:  
 
    Ensure Linux headers are installed for the script to function properly:  

   ```bash
   sudo apt install -y linux-headers-$(uname -r)
   ```

3. **Install signmod**:  
   
    Clone or download the repository:

    ```bash
    git clone https://github.com/cipherswami/signmod.git && cd signmod
    ```

    Run the installer script:

    > **!! Important Note !!** - Running the `install.sh` script more than once will generate new keys and certificates, overwriting the existing ones on your system. This will result in new keys being added to the MOK database while the old keys become cluttered and unused.  
    > **TL;DR**: _Run the installation script only once_.   
    
    During installation, if prompted to set a password, choose one, as it will be required later during **MOK enrollment**.

    ```bash
    chmod +x install.sh && sudo ./install.sh
    ```

1. **MOK enrollment**:  

    Once the installation is complete, reboot your PC. During the next boot, follow the steps below when prompted by the MOK Manager: 

    - Select **Enroll MOK**.
    - Continue by selecting **View Key** and **confirm** the enrollment.
    - Enter the same **password** you set during the installation.
    - Once done continue to boot.

    To reboot:

    ```bash
    sudo reboot now
    ```

2. **Verify MOK**:  

    To confirm that your signmod MOK certificate has been installed correctly

    ```bash
    sudo mokutil --list-enrolled
    ```

    Look for your certificate details (subject, issuer: kCN=signmod) in the output.

## Usage

Once the certificate is enrolled in MOK, and the signmod is installed, you can use the signmod to sign your kernel modules:

```bash
sudo signmod your_module.ko
```

This script will sign the module using the corresponding private key generated during installation.

## Uninstallation

To remove `signmod` and clean up all associated files and certificates, follow the steps below:

1. **Clone or download the repository**:

    ```bash
    git clone https://github.com/cipherswami/signmod.git && cd signmod
    ```

2. **Run the uninstaller script**:  

    ```bash
    chmod +x uninstall.sh && sudo ./uninstall.sh
    ```

2. **Reboot your system**:  

    After running the uninstallation script, a reboot is required to complete the removal of the MOK certificate. During the next boot, follow the steps below:
    
    - When prompted by the MOK Manager, select **Delete MOK**.
    - Confirm your choice and follow the on-screen instructions.
    - Enter the password you used during the initial MOK enrollment.

3. **Verify uninstallation**:  

    After rebooting, you can confirm the removal by running:

    ```bash
    sudo mokutil --list-enrolled
    ```

    Ensure that your `signmod` MOK certificate is no longer listed.


## Issues

1. **insmod: ERROR: could not insert module hello.ko: Invalid module format**  
   
   **Solution:** Purge and reinstall the headers.

    ```bash
    sudo apt purge -y linux-headers-$(uname -r) && sudo apt install -y linux-headers-$(uname -r)
    ```
