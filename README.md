# AFC Plugin for Moonraker - Installation and Configuration Guide

## Overview
The AFC Plugin integrates the Armored Filament Carousel (AFC) with Moonraker and Mainsail/Fluidd, allowing you to track the filament spools loaded into the AFC and display the relevant information directly in the web interface. This guide will walk you through the installation and configuration process for the plugin and custom Mainsail compilation.

### Prerequisites
- Moonraker installed on your 3D printer controller (e.g., a Raspberry Pi running Klipper)
- Mainsail or Fluidd for controlling and monitoring your 3D printer
- Python 3.9 or higher

## 1. Installing the Moonraker AFC Plugin

### Installation Steps
1. **Run the Installer Script**
   - Make the `install.sh` script executable and run it to install the plugin:
     ```sh
     chmod +x install.sh
     ./install.sh
     ```

2. **Configuration File Settings**
   - To enable the plugin, update the Moonraker configuration file (`moonraker.conf`) with the following settings if they were not automatically added:
     ```ini
     [afc_plugin]
     spoolman_enabled: true  # Set to true if Spoolman integration is enabled, false otherwise
     spoolman_ip: 192.168.1.100  # Optional, replace with the IP of your Spoolman server (default is localhost)
     spoolman_port: 7192  # Default port for Spoolman
     ```
   - Save the configuration file.

3. **Restart Moonraker**
   - Restart Moonraker to load the new plugin:
     ```sh
     sudo systemctl restart moonraker
     ```

### Moonraker Plugin Configuration Options
- **`spoolman_enabled`**: Set to `true` if you want to integrate the plugin with Spoolman to enrich the filament data.
- **`spoolman_ip`**: The IP address where Spoolman is running. Defaults to `localhost`.
- **`spoolman_port`**: The port on which Spoolman is running. Default is `7192`.

## 2. Custom Mainsail Compilation for AFC Panel
To display AFC information within the Mainsail UI, a custom panel needs to be added to Mainsail. This section details how to compile Mainsail with this new custom AFC panel.

### Steps to Compile Mainsail with AFC Panel
1. **Clone Mainsail Repository**
   - Clone the Mainsail repository to your local machine:
     ```sh
     git clone https://github.com/mainsail-crew/mainsail.git
     cd mainsail
     ```

2. **Add AFC Panel**
   - Add the `AfcPanel.vue` file to the Mainsail components:
     - Copy `AfcPanel.vue` to `src/components/panels/`.
     - Modify the necessary configuration in `src/index.ts` to import and register the new AFC panel component.

3. **Build Mainsail**
   - Compile Mainsail with the new AFC panel included:
     ```sh
     npm install
     npm run build && npm run build.zip
     ```

4. **Deploy the Custom Mainsail Build**
   - Upload the compiled build to your 3D printer controller (e.g., Raspberry Pi), replacing the existing Mainsail installation:
     ```sh
     unzip build.zip -d /var/www/mainsail
     ```

## 3. Backup Information for Existing Mainsail
During the installation process, the current version of Mainsail is automatically backed up in the home directory to ensure that you can roll back if necessary.

- **Backup Directory**: `/home/pi/mainsail.old`
- The backup allows you to restore the previous version in case of issues with the new compilation.
- To restore the old version:
  ```sh
  sudo rm -rf /var/www/mainsail
  sudo mv /home/pi/mainsail.old /var/www/mainsail
  ```

## Troubleshooting
- **Panel Not Showing in Mainsail**: Ensure that you have properly registered the `AfcPanel.vue` in the `src/index.ts` file before compiling Mainsail.
- **Spoolman Data Not Showing**: Confirm that the `spoolman_enabled` flag is set to `true` in the Moonraker configuration file and that the Spoolman server is reachable at the specified IP and port.

## Support
For further support, feel free to open an issue on the repository or contact the maintainer directly.

