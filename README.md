# SignMod::CIPH3R

The **signmod** script streamlines the process of signing custom kernel modules for systems with Secure Boot enabled. The installation script generates a key pair, enrolls the certificate in the MOK, and the corresponding private key is later used by signmod to sign the modules, enabling secure and seamless module loading.

## Installation

1. **Clone the Repository**:  
   ```bash
   git clone https://github.com/cipherswami/signmod.git && cd signmod
   ```

2. **Install signmod**:  
   
    **!! Important Note !!**  

    Running the `install_signmod.sh` script more than once will generate new keys and certificates, overwriting the existing ones on your system. This will result in new keys being added to the MOK database while the old keys become cluttered and unused.  

    **TL;DR**: _Run the installation script only once_.   
    
    During installation if prompted to set a password, set something later it will be asked during MOK enrollment after the reboot.

    ```bash
    chmod +x install_signmod.sh && sudo ./install_signmod.sh
    ```

3. **MOK enrollment**:  

    Reboot your PC, during the next boot when prompted by the MOK Manager, follow these steps:

    - Select Enroll MOK.
    - Continue by selecting View Key and confirm the enrollment.
    - Provide the password you set during the MOK registration (if prompted).
    - Finish the process, and continue to boot.

    ```bash
    sudo reboot now
    ```

4. **Verify MOK Installation**:  

    To confirm that your MOK certificate has been installed correctly

    ```bash
    sudo mokutil --list-enrolled
    ```

    Look for your certificate details (subject, issuer: kCN=KernelDevMods) in the output.

## Usage (Signing Kernel Modules)

Once the certificate is enrolled in MOK, and the signmod installed, you can use the signmod to sign your kernel modules:
```bash
sudo signmod your_module.ko
```
This script will sign the module using the corresponding private key generated during installation, enabling it to be loaded by the kernel on Secure Boot enabled systems.

## Known Issue

If you encounter the `insmod: ERROR: could not insert module hello.ko: Invalid module format` error after completing the setup, purge and reinstall the headers.

```bash
sudo apt purge -y linux-headers-$(uname -r)
sudo apt install -y linux-headers-$(uname -r)
```
