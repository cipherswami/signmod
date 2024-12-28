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

2. **Clone the repository**:  

    ```bash
    git clone https://github.com/cipherswami/signmod.git && cd signmod
    ```

2. **Run the installer script**: 

    During installation, if prompted to set a password, set one, as it will be required later during MOK enrollment:

    ```bash
    chmod +x install.sh && sudo ./install.sh
    ```

3. **Clean up and MOK enrollment**:  

    Once the installation is complete you can safly remove the cloned repository: 

    ```bash
    cd .. && rm -rf signmod
    ```

    Now reboot your PC. During the next boot, you will see a prompt from the MOK Manager. Follow these steps:  

    - Press **any key** to enter the MOK Menu within the timeout.
    - Select **Enroll MOK** from the menu.  
    - Next, choose **Continue** and then **Yes**.   
    - When prompted for a password, enter the same **password** you set during the installation.  
    - Finally, select **Reboot** to complete the process.

4. **Verification**:  

    To confirm that your signmod MOK certificate has been installed correctly

    ```bash
    sudo mokutil --list-enrolled
    ```

    Look for your certificate details (subject, issuer: `CN=signmod`) in the output.

## Usage

Once the certificate is enrolled in MOK, and the signmod is installed, you can use the signmod to sign your kernel modules:

```bash
sudo signmod your_module.ko
```

This script will sign the module using the corresponding private key generated during installation.

## Uninstallation

To remove `signmod` and clean up all associated files and certificates, follow the steps below:

1. **Clone the repository**:

    ```bash
    git clone https://github.com/cipherswami/signmod.git && cd signmod
    ```

2. **Run the uninstaller script**:  

    During uninstallation, if prompted to set a password, set one, as it will be required later during MOK unenrollment:

    ```bash
    chmod +x uninstall.sh && sudo ./uninstall.sh
    ```

3. **Clean up and MOK unenrollment**:  

    Once the uninstallation is complete you can safly remove the cloned repository. 

    ```bash
    cd .. && rm -rf signmod
    ```

    Now reboot your PC. During the next boot, you will see a prompt from the MOK Manager. Follow these steps: 

    - Press **any key** to enter the MOK Menu within the timeout. 
    - Select **Delete key** from the menu.  
    - Next, choose **Continue** and then **Yes**.  
    - When prompted for a password, enter the same **password** you set during the installation.  
    - Finally, select **Reboot** to complete the process.

5. **Verification**:  

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
