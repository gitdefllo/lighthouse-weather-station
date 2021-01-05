# Lighthouse Weather Station

> **Make sure your RPi uses `Python3` and `pip3`** (see [the Adafruit guide](https://learn.adafruit.com/circuitpython-on-raspberrypi-linux/installing-circuitpython-on-raspberry-pi)).

### RPi installation

On RPi ZW, we need to install the following dependencies:

```bash
$ sudo pip3 install Adafruit-Blinka
$ sudo pip3 install adafruit-circuitpython-neopixel
$ sudo pip3 install pybluez
```

We need to configure the Pi by changing the name of Bluetooth:

```bash
$ sudo bluetoothctl
[bluetooth]# system-alias 'LighthouseWeatherStation'
[bluetooth]# quit
```

Make it discoverable at boot by adding this line at end of `/etc/rc.local` file: 

```bash
...
hciconfig hci0 piscan
exit 0
```

(Optionnaly,) change the timeout by editing `/etc/bluetooth/main.conf`:

```bash
DiscoverableTimeout = 5
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
$ sudo python main_lighthouse.py
```

This should output:

```bash
Waiting for connection on RFCOMM channel 1
---
Update weather
Request response: 2°C (id: 803)
Color selected: (0, 153, 255)
---

```
