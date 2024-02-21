# wsl-vscode-ansible-generator

This repo goal's is build an archive wich contents an wsl archive and an vscode synchronized for usage remote wsl in air gaped environement.

For each release, there is following "packages"

* full package which contains
* * rockylinux 8 "wsl edition" more light as possible.
* * * wsl preconfigured for vscode server + subcription-manager installed
* * * vscode server with extension present on home user
* * * ansible 2.12.* + molecule podman preinstalled (yes it's old)
* * * podman preinstalled and configured to use podman desktop socket
* * vscode windows match with the vscode server inside the wsl distribution
* * wsl2-ssh-bridge.exe
* * script to install the vscode + wsl distribution

For the future a package more ligh with only

* * vscode windows updated
* * vscode server updated
* * shell/script which helps update a distribution

## Requirements

### Mandatory

* [podman-desktop]([https://github.com/containers/podman-desktop/releases/download/v1.7.1/podman-desktop-airgap-1.7.1-setup-x64.exe) air gaped installed and fonctionnal on the destination workstation, if you use cisco anyconnect vpn. Podman desktop handles nicely vpn issues on wsl, don't forget enable option ["User mode networking"](https://podman-desktop.io/docs/proxy/using-a-vpn-on-windows).

### Optional

* a foreman or redhat satelite if you want install more rpm packages
