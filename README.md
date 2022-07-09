# MacOS Parallels Base Virtual Machines

Installs macOS into a Parallels Desktop virtual machine.
It supports the follow versions of macOS:

- Catalina
- Big Sur
- Monterey

This involves running a script, which in turn calls Packer,
which in turn brings up a new Parallels Desktop virtual machine.
The VM is created with an ISO image attached to it; this image contains the macOS installation software.
Packer then waits until it can establish an SSH connection to the VM.
Once it can, it saves the VM into the `vms` directory.

While Packer is waiting, one must perform a number of manual steps within the VM in order to actually
complete the installation of macOS.
That's because macOS installation is designed to be interactive;
there's no simple way (ignoring MDM solutions) to do it in an unattended manner.

The macOS VM's administrator account is called `packer`, and its password is determined below.
It's important to get this right, since it's how Packer logs in to the VM.

The resulting VM is suitable for further provisioning via Packer.

## Caveats

The procedure outlined below isn't exactly elegant.
In fact, it's downright painful.
However it does work well enough for my needs, and I have no incentive to improve it.
That's because the testing cycle takes over an hour!

## Requirements

- Packer 1.8
- Parallels Desktop 17
- Parallels Virtualization SDK 17.1.4

## Setup

1. Edit the Packer variables file for the version of macOS you are interested in, at `conf/<os>.pkrvars.hcl`.
   Modify the following settings:
   - `iso_url`: The URL to the bootable ISO image.
     Images can be created by running [this script](https://github.com/paullalonde/macos-bootable-iso-images).
   - `iso_checksum`: The ISO image's checksum.
1. Create a file at `conf/secrets.pkrvars.hcl` with the following contents.
   Replace the `<REPLACE-ME>` with a secure password.
   ```
   ssh_password = "<REPLACE-ME>"
   ```

## Procedure

1. Run the script:
   ```bash
   ./make-base-vm.sh --os <name>
   ```
   where *name* is one of:
   - `catalina`
   - `bigsur`
   - `monterey`
1. Packer will create the VM, then wait until an SSH connection can be established.
1. While Packer is waiting, perform the in-VM manual steps (see below).
1. Once the SSH connection is established, Packer will prompt you to type `<enter>`.
1. Packer then saves the VM under the `vms` directory.

## In-VM Manual Steps

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
1. On Big Sur and later, the system will display a *System Extension Updated* alert.
   1. Click the **Postpone** button in the Parallels Tools window.
   1. Click the **Open Security & Privacy** button in the alert.
   1. Once in the *Security & Privacy* pane:
      1. Click the lock icon to make changes.
      1. Click the **Allow** button. This will restart macOS.
1. On Catalina and below, click the **Restart** button in the Parallels Tools window.
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
      1. Change the password to the value of the `ssh_password` variable above.
   1. Navigate to **Sharing**.
      1. Turn on **Remote Login**.
         This will allow Packer (on the host machine) to finally connect to the VM via SSH.
