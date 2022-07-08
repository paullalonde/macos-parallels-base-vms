# MacOS Parallels Base Virtual Machines

Boots macOS into a Parallels Desktop virtual machine.

<!-- Creates a Parallels virtual machine containing macOS. -->

The resulting VM is suitable for further provisioning via Packer.

## Requirements

- Packer 1.8
- Parallels Desktop 17
- Parallels Virtualization SDK

## Manual Steps

1. Install macOS normally.
1. In the Installation Assistant (i.e., the wizard that turns various macOS features on or off),
   configure the VM to your liking.
   The only important setting is the computer account, which **must** be set to:
      - Full Name: `Packer`
      - Account name: `packer`
      - Password: *something quick to type and easy to remember; we will change it later*
1. Wait until the Finder starts up.
1. Eject the installation media, which will appear as a CD on the Desktop (eg `Install macOS Catalina`).
1. In Parallels Desktop's **Action** menu, click **Install Parallels Tools**.
   This will mount a CD called `Parallels Tools` on the Desktop.
   Open it, the double-click the `Install` icon. This will actually install the tools.
   When installation is complete, click the **Restart** button.
1. Once restarted, login to the VM using the `packer` user and the password you set previously.
1. Eject the `Parallels Tools` CD.
1. Open Terminal
   1. Change the user's shell to `bash`:
      ```bash
      chsh -s /bin/bash
      ```
   1. Install the Command Line Developer Tools.
      This is required in order to further provision the VM with Packer, later on.
      ```bash
      xcode-select --install
      ```
1. Open System Preferences
   1. Navigate to **Users & Groups**.
      1. Click the **Change Password** button.
      1. Change the password to **$$$$$$$$**
   1. Navigate to **Sharing**.
      1. Turn on **Remote Login**.
