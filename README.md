# Lighthouse Weather Station

The device informs about the weather with a color set. It also provides ways to change the location or the lighthouse's color from a smartphone using Bluetooth Low Energy.  

<img height="320" src="https://github.com/gitdefllo/lighthouse-weather-station/blob/master/media/station/lighthouse_2.jpg"/>

You can find all the necessary files in these packages:

- `app/lighthouse_weather`: a Flutter mobile app
- `station`: a Python service for RPi
- `print`: the 3D print files
- `media`: photos and screenshots

---
> :warning: **This project has been migrated to support Bluetooth Low Energy**  
> See [Using Bluetooth Low Energy between Raspberry Pi and Flutter](https://fllo.medium.com/using-bluetooth-low-energy-between-raspberry-pi-and-flutter-cba012c48b97)  
> Checkout the branch [*feature_classic_bluetooth*](https://github.com/gitdefllo/lighthouse-weather-station/tree/feature_classic_bluetooth) to use Classic Bluetooth protocol on RFCOMM.
---

Read [How I built a lighthouse weather station?](https://fllo.medium.com/how-i-built-a-lighthouse-weather-station-12edd2a6a13b) to see how this was created.

# Installation

---
> :warning: **Make sure your RPi uses `Python3` and `pip3`** (see [the Adafruit guide](https://learn.adafruit.com/circuitpython-on-raspberrypi-linux/installing-circuitpython-on-raspberry-pi)).
---

### RPi installation

On RPi ZW, we need to install the following dependencies:

```bash
$ sudo apt install python3-dbus
$ sudo pip3 install Adafruit-Blinka
$ sudo pip3 install adafruit-circuitpython-neopixel
```

Enable the "experimental" flag to bluetooth deamon in `bluez`:

```bash
$ sudo nano /etc/systemd/system/dbus-org.bluez.service
```
Add `-E` flag at the end of line:

```bash
ExecStart=/usr/lib/bluetooth/bluetoothd -E
```

Then, restart the Pi as follows:

```bash
$ sudo reboot
```

### Mobile app configuration

On the Pi, by using `echo -e 'show\nquit' | sudo bluetoothctl`, you will get the following output:

```bash
Controller XX:XX:XX:XX:XX:XX (public)
	Name: raspberrypi
	Alias: LighthouseWeatherStation
	...
```

Copy-paste the MAC address `XX:XX:XX:XX:XX:XX` into the mobile app, in `/lib/bloc/bluetooth/bluetooth_bloc.dart`:

```dart
final String _nameLighthouseStation = 'LighthouseWeatherStation';
final String _addressLighthouseStation = 'XX:XX:XX:XX:XX:XX';
```

### Python service configuration

Go to [OpenWeatherMap](https://openweathermap.org/) and get an api key.  
You have to copy-paste it in the Python script instead of `xxx`:

```python
appid = 'appid=xxx'
```

### Start the Lighthouse Weather Station

```bash
$ sudo python3 main.py
```

This should output:

```bash
GATT application running
GATT application registered
GATT advertisement registered
---
Update weather
Request response: 18°C (weather: 803)
Color selected: (255, 255, 0)
...
```

Then, when a device is connected, the output should add `Sending` line:

```bash
Update weather
Request response: 18°C (weather: 803)
Color selected: (255, 255, 0)
Sending:  D=19,W=803,C=6454880
...
```

# Media

When the device is off:

<img height="332" src="https://github.com/gitdefllo/lighthouse-weather-station/blob/master/media/station/lighthouse_1.jpg"/>

When set a custom color (white for example):

<img height="340" src="https://github.com/gitdefllo/lighthouse-weather-station/blob/master/media/station/lighthouse_4.jpg"/>
