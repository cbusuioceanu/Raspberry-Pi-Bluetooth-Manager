# Raspberry Pi Bluetooth Manager aka RPiBTman [![Build Status](https://travis-ci.org/cbusuioceanu/Raspberry-Pi-Bluetooth-Manager.svg?branch=master)](https://travis-ci.org/github/cbusuioceanu/Raspberry-Pi-Bluetooth-Manager)
The first official release of the easiest and fastest script to manage your Raspberry Pi Bluetooth. A state of the art shell script :)
<p align="center">
<img src="https://themainframe.network/img/github/bluetooth_raspberry_logo.png" alt="Official Bluetooth & Raspberry logos" />
</p>

### Contents

- [Video](#video)
- [Description](#description)
- [How to use](#how-to-use)
- [Photo gallery](#photo-gallery)
----------------------------------
# Video
*soon*

# Description
**Raspberry Pi Bluetooth Manager**, aka **RPiBTman**, helps you manage your bluetooth devices connected to and from RPi. It has a lot of fail safe features so, even if you are a total beginner, you can't break anything. Not unintentionally :smile:

Running this script the first time, you will see a notification that will tell you this is the first time running it. That notification will show up only once. There are two "if's" that can change the notification behaviour: 1. If you decide to remove the script config file, the notification will appear again. 2. If the first time config process fails. No need to worry about any of these.

<table>
  <tr>
    <th colspan="3" align="center">The most important functions of this script (for the moment)</th>
  </tr>
  <tr>
    <td colspan="3" align="left">:crown: Receive/Give Internet from your phone/tablet/laptop etc to your Raspberry Pi</td>
  </tr>
  <tr>
    <td colspan="3" align="left">:crown: Transmit Internet from your Raspberry Pi to any device via Bluetooth</td>
  </tr>  
  <tr>
    <th colspan="3" align="center">What can you do with Raspberry Pi Bluetooth Manager?</th>
  </tr>
  <tr>
    <td>:heavy_check_mark: List available BT controllers</td>
    <td>:heavy_check_mark: View Bluetooth status</td>
    <td>:heavy_check_mark: Show paired BT device info</td>
  </tr>
  <tr>
    <td>:heavy_check_mark: Turn bluetooth on/off</td>
    <td>:heavy_check_mark: Select default BT controller</td>
    <td>:heavy_check_mark: View Discoverable status</td>
  </tr>
  <tr>
    <td>:heavy_check_mark: Trust/Untrust BT devices</td>
    <td>:heavy_check_mark: Make bluetooth discoverable on/off</td>
    <td>:heavy_check_mark: Set/Reset BT controller alias (name)</td>
  </tr>
  <tr>
    <td>:heavy_check_mark: View pairable status</td>
    <td>:heavy_check_mark: Block/Unblock BT devices</td>
    <td>:heavy_check_mark: Make bluetooth pairable on/off</td>
  </tr>
  <tr>
    <td>:heavy_check_mark: List scanned/paired BT devices</td>
    <td>:heavy_check_mark: Scan for BT devices</td>
    <td>:heavy_check_mark: Remove BT devices</td>
  </tr>
  <tr>
    <td>:heavy_check_mark: Check needed dependencies</td>
    <td>:heavy_check_mark: Configure network bridge</td>
    <td>:heavy_check_mark: Configure ISC-DHCP-SERVER</td>
  </tr>
  <tr>
    <td>:heavy_check_mark: Configure iptables</td>
    <td>:heavy_check_mark: Configure services</td>
    <td>:heavy_check_mark: Disconnect devices</td>
  </tr>  
</table>


# How to use
You'll need a Raspbery Pi 3 or a Raspberry Pi 4 with Raspbian OS (32 or 64bit) to use this script.
If this is the first time you use this, stay close: the setup is fully automated!

```shell
git clone https://github.com/cbusuioceanu/Raspberry-Pi-Bluetooth-Manager.git rpibtman && cd rpibtman && sudo bash rpibtman.sh
```
The first time configuration of the system & script will start. Make sure the configuration ends cleanly and you are redirected to the Main Menu of the script.
Main Menu has detailed options and is pretty simple for everyone. I will also detail everything here.

##### LEGEND: BT=Bluetooth; devs=Devices; 
##### Main Menu
- [x] 1. Available BT controllers -> list them
- [x] 2. Select default BT controller -> e.g. if you have for example the RPi BT controller and a USB one, choose one of them
- [x] 3. Set/Reset BT controller alias -> change the broadcast name of your Pi bluetooth or reset it to default (raspberry)
- [x] 4. List scanned/paired BT devices -> list scanned or paired bluetooth devices with RPi
- [x] 5. Bluetooth status -> is controller on or off
- [x] 6. Discoverable status -> is discoverability on or off
- [x] 7. Pairable status -> is pairability on or off
- [x] 8. Receive Internet from phone -> give your Raspberry Pi an Internet connection from your Smartphone/Tablet/Smartwatch etc
- [x] 9. Transmit Internet from RPi -> give your smart devices an Internet connection from RPi
- [x] 10. Scan for Bluetooth devices -> start scanning for local active bluetooth devices
- [x] 11. Show paired BT device info -> view your paired bluetooth devices info
- [x] 12. Trust/Untrust BT devices -> trust/untrust a paired bluetooth device
- [x] 13. Block/Unblock BT devices -> block/unblock a paired bluetooth device
- [x] 14. Remove BT device -> remove a paired bluetooth device
- [x] 15. Disconnect BT device -> disconnect a device from your RPi
- [x] q. Exit

##### Shortcuts
- [x] 4s. List scanned BT devs -> directly list scanned devices via menu 4
- [x] 4p. List paired BT devs -> directly list paired devices via menu 4
- [x] 50. Bluetooth off -> turn bluetooth off
- [x] 51. Bluetooth on -> turn bluetooth on
- [x] 60. Discoverable off -> turn rpi discoverable off
- [x] 61. Discoverable on -> turn rpi discoverable on
- [x] 70. Pairable off -> turn rpi pairing off 
- [x] 71. Pairable on ->  turn rpi pairing on

##### Utils
You can use this any time but all of these steps will be automatically run at first time config.
- [x] c1. Check dependencies
- [x] c2. Config Bridge
- [x] c3. Config ISC-DHCP-SERVER
- [x] c4. Config iptables
- [x] c5. Config services

# Photo gallery
<img src="https://themainframe.network/img/github/raspberry_pi_bluetooth_manager_image_1.png" width="18%"></img> <img src="https://themainframe.network/img/github/raspberry_pi_bluetooth_manager_image_2.png" width="18%"></img> <img src="https://themainframe.network/img/github/raspberry_pi_bluetooth_manager_image_3.png" width="18%"></img> <img src="https://themainframe.network/img/github/raspberry_pi_bluetooth_manager_image_4.png" width="18%"></img> <img src="https://themainframe.network/img/github/raspberry_pi_bluetooth_manager_image_5.png" width="18%"></img> <img src="https://themainframe.network/img/github/raspberry_pi_bluetooth_manager_image_6.png" width="18%"></img> <img src="https://themainframe.network/img/github/raspberry_pi_bluetooth_manager_image_7.png" width="18%"></img> <img src="https://themainframe.network/img/github/raspberry_pi_bluetooth_manager_image_8.png" width="18%"></img> <img src="https://themainframe.network/img/github/raspberry_pi_bluetooth_manager_image_9.png" width="18%"></img> <img src="https://themainframe.network/img/github/raspberry_pi_bluetooth_manager_image_10.png" width="18%"></img> <img src="https://themainframe.network/img/github/raspberry_pi_bluetooth_manager_image_11.png" width="18%"></img> <img src="https://themainframe.network/img/github/raspberry_pi_bluetooth_manager_image_12.png" width="18%"></img> <img src="https://themainframe.network/img/github/raspberry_pi_bluetooth_manager_image_13.png" width="18%"></img> <img src="https://themainframe.network/img/github/raspberry_pi_bluetooth_manager_image_14.png" width="18%"></img> <img src="https://themainframe.network/img/github/raspberry_pi_bluetooth_manager_image_15.png" width="18%"></img> 
