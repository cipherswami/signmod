# regMOK::CIPH3R

regMOK helps signing custom kernel modules by generating a key and certificate, then enrolling the key in the MOK list for Secure Boot. It then installs the `signmod` script to sign modules with the generated certificate, enabling verification by MOK during boot.

### Key Components:

1. **MOK (Machine Owner Key) Enroller:**
   - Automatically generates a **custom key** and corresponding **certificate** pair.
   - Enrolls the **key** into the Machine Owner Key (MOK) list for use with Secure Boot.

2. **Module Signing Script:**
   - Installs a utility script named `signmod` to streamline the signing process.
   - This script uses the generated certificate to sign kernel modules, allowing them to be verified against the enrolled MOK during system boot.

## Installation

1. **Clone the Repository**:  
   ```bash
   git clone https://github.com/cipherswami/regMOK.git && cd regMOK
   ```

2. **Install MOK (also installs signmod)**:  
   
    **!! Important Note !!**  
    **Avoid Running the `install_MOK.sh` Script Multiple Times**  
    Running the `install_MOK.sh` script more than once will generate new keys and certificates, overwriting the existing ones on your system. This will result in new keys being added to the MOK database while the old keys become cluttered and unused. **TLDR; Run the script only once**.  

    set some password if prompeted any, which will be later used for enrolling MOK.

    ```bash
    chmod +x install_MOK.sh && sudo ./install_MOK.sh
    ```

3. **Reboot and enroll MOK**:  
    ```bash
    reboot
    ```
    During the next boot, when prompted by the MOK Manager, follow these steps:
    - Select Enroll MOK.
    - Continue by selecting View Key and confirm the enrollment.
    - Provide the password you set during the MOK registration (if prompted).
    - Finish the process and reboot again to complete the key enrollment.

4. **Verify MOK Installation**:  

    To confirm that your MOK certificate has been installed correctly
    ```bash
    sudo mokutil --list-enrolled
    ```
    Look for your certificate details (subject, issuer: kCN=KernelDevMods) in the output.

## Usage (Signing Kernel Modules)

Once the MOK is enrolled and the signmod is also installed, you can use the signmod to sign your kernel modules:
```bash
sudo signmod your_module.ko
```
Replace your_module.ko with the your kernel module file. This command will sign the module using the MOK key, allowing it to be loaded by the kernel on systems with Secure Boot enabled.

## Known Issue

After doing all the set up, if face with `insmod: ERROR: could not insert module hello.ko: Invalid module format` error, reinstall the headers and re comple the kernel module.

```bash
sudo apt --reinstall install linux-headers-`uname -r`
```
