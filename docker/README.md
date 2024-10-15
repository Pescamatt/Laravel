<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/othneildrew/Best-README-Template">
    <img src="https://upload.wikimedia.org/wikipedia/en/thumb/7/7e/W%C3%BCrth_logo.svg/300px-W%C3%BCrth_logo.svg.png" alt="Logo" width="300" height="64">
  </a>

<h3 align="center">Docker on Windows</h3>

   <p align="center">
      This guide help you to install docker on Windows
      <br/>
   </p>
</div>

<!-- TABLE OF CONTENTS -->
[[_TOC_]]

## Installation

### Requirements

1. A machine with Windows 10 Version 1903 or higher, with Build 18362 or higher
2. [Windows Terminal](https://github.com/microsoft/terminal/releases) (optional).

### Step 1 - Enable the Windows Subsystem for Linux

You must first enable the "Windows Subsystem for Linux" optional feature before installing any Linux distributions on
Windows.

Open PowerShell as Administrator (Start menu > PowerShell > right-click > Run as Administrator) and enter this command:

```
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
```

### Step 2 - Enable Virtual Machine feature

Before installing WSL 2, you must enable the Virtual Machine Platform optional feature. Your machine will require
virtualization capabilities to use this feature.

```
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```

**NB. Restart your machine to complete the WSL install and update to WSL 2.**

### Step 3 - Download the Linux kernel update package

1. Download the latest package:
    - [WSL2 Linux kernel update package for x64 machines](https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi)
      .


2. Run the update package downloaded in the previous step. (Double-click to run - you will be prompted for elevated
   permissions, select ‘yes’ to approve this installation.)

### Step 4 - Set WSL 2 as your default version

Open PowerShell and run this command to set WSL 2 as the default version when installing a new Linux distribution:

```
wsl --set-default-version 2
```

### Step 5 - Install your Linux distribution of choice

#### Download from Microsoft Store (if you can :smirk:)

1. Open the Microsoft Store and select your favorite Linux distribution.

   **NB. For our project we use Ubuntu 20.04 LTS.**

   ![Microsoft Store!](https://docs.microsoft.com/en-us/windows/wsl/media/store.png "Microsoft Store")

   List of available distribution on the store:
    - Ubuntu 18.04 LTS
    - Ubuntu 20.04 LTS
    - openSUSE Leap 15.1
    - SUSE Linux Enterprise Server 12 SP5
    - SUSE Linux Enterprise Server 15 SP1
    - Kali Linux
    - Debian GNU/Linux
    - Fedora Remix for WSL
    - Pengwin
    - Pengwin Enterprise
    - Alpine WSL
    - Raft(Free Trial)


2. From the distribution's page, select "Get".
   ![Microsoft Store!](https://docs.microsoft.com/en-us/windows/wsl/media/ubuntustore.png "Microsoft Store Ubuntu")

#### Manual install Ubuntu (if you have problem with Microsoft Store)

1. Installing Ubuntu on WSL by sideloading the .appx

   **NB. For our project we use Ubuntu 20.04 LTS.**


- [Ubuntu 20.04 LTS (Focal)](https://aka.ms/wslubuntu2004).
- [Ubuntu 18.04 LTS (Bionic)](https://aka.ms/wsl-ubuntu-1804).
- [Ubuntu 16.04 LTS (Xenial)](https://aka.ms/wsl-ubuntu-1604).

2. They can be installed by enabling sideloading in Windows 10 and double-clicking the .appx and clicking Install or
   with PowerShell:

```
Add-AppxPackage .\Ubuntu_2004.2020.424.0_x64.appx
```

### Finish the installation of chosen Linux distribution

1. From the start menu search for the Linux distribution you have installed and click on it.
2. The first time you launch a newly installed Linux distribution, a console window will open and you'll be asked to
   wait for a minute or two for files to de-compress and be stored on your PC. All future launches should take less than
   a second.
   ![Ubuntu Terminal](https://docs.microsoft.com/en-us/windows/wsl/media/ubuntuinstall.png "Ubuntu Terminal")

**CONGRATULATIONS! You've successfully installed and set up a Linux distribution that is completely integrated with your
Windows operating system!**

### Step 6 - Check WSL Version

1. Open a powershell as administrator and check for WSL version using this command

   ```
   wsl --list --verbose
   ```
   If you read **Version 2** all good, otherwise run this command

   ```
   wsl --set-version <DistroName> 2
   ```

### Step 7 - Copy Würth certificate

1. Copy the Würth certificate inside the WLS2

   **NB If you don't have it (and you don't have) ask in the Webex group IT Web Dev**
   ```bash
    cp /mnt/c/Users/{YourUser}/Desktop/ca-bundle.crt /usr/local/share/ca-certificates/ca-bundle.crt
    sudo update-ca-certificates
   ```


### Step 8 - Install Docker

1. Open WSL2 terminal and run this command.

   ```bash
    sudo chmod +x ./scripts/install.sh
   ```
   ```bash
    ./scripts/install.sh
   ```

### Step 9 - Clone the project inside the WLS2

1. Create a folder anywhere you want
2. Inside the folder clone the project

   ```bash
   git clone git@git.wuerth.it:pandora/docker.git
   ```

**NB. For clone with ssh you need to add your ssh-key to gitlab**

### Step 10 - Start project

1. Move to the docker folder and copy .env.example to .env
    ```bash
    cp .env.example .env
    ```

2. Copy the certificate inside the WLS2

   **NB If you don't have it ask in the Webex group IT Web Dev**
   ```bash
    cp /mnt/c/Users/{YourUser}/Desktop/ca-bundle.crt /home/{YourUser}/{FolderCreated}/docker/php/ca_bundle.crt
   ```

3. Clone **aggiustami-2.0** project that you need to run

   **Move one folder up respect the docker folder**
   ```bash
    git clone git@git.wuerth.it:webdev/aggiustami-2.0.git aggiustami2
   ```

4. Move inside docker folder and tart docker daemon, wait some second before run next command
    ```bash
    make start-daemon
    ```

5. Open a new WLS2 terminal, go to docker folder and initialize the project, wait for docker 
    ```bash
    make initialize
    ```
   
## Useful commands
For a complete list of command simply run
```bash
make help
```

## Tips

### Start container
Next time that you want to start container use 
```bash
make start
```
instead of
```bash
make initialize
```

### Stop container
For stop the container use the command 
```bash
make stop
```

### Enter to container 
For enter to main container where project is located simple type
```bash
make connect
```
For enter to database container use
```bash
make connect-db
```

<div align="center">Made with :heartbeat: by <a href="https://git.wuerth.it/luca.zangheri">Luca</a></div>