# imports
import os
import subprocess
import board
import digitalio
import neopixel
from requests import get
import json
from gatt_server import BleApplication, WeatherStationAdvertisement, WeatherService, RgbColorService, SystemService
from repeated_timer import RepeatedTimer

### params
delay_weather = 10.0 # seconds
delay_system = 1.0
city_id = 6454880 # Orsay (default)

timer_update = None
timer_system = None

base = 'https://api.openweathermap.org/data/2.5/weather'
city = 'id=%s'
units = 'units=metric'
appid = 'appid=xxx'
url = '%s?%s&%s&%s' % (base, city, units, appid)

shutdown_pin = board.D4
shutdown_button = digitalio.DigitalInOut(shutdown_pin)
shutdown_button.direction = digitalio.Direction.INPUT
shutdown_button.pull = digitalio.Pull.UP
system_stopped = False

pixels_pin = board.D18
pixels_count = 3
pixels_order = neopixel.GRB
pixels = neopixel.NeoPixel(pixels_pin,
                pixels_count,
                brightness = 1.0,
                auto_write = False,
                pixel_order = pixels_order)

### weather requests
def getCurrentWeather():
    if system_stopped:
        return

    try:
        data = get(url % (city_id), timeout = 5).json()
        temperature = int(data['main']['temp'])
        weather_id = data['weather'][0]['id']
        print('Request response: %s°C (weather: %s)' % (temperature, weather_id), flush=True)
        return [temperature, weather_id]
    except Exception as e:
        print('Request connection error: %s' % e, flush=True)
        pass

def updateCurrentCity(data):
    print('Update city id to %d' % data, flush=True)
    ble_app.services[0].set_city_id(data)

### neopixels
def selectColorByDegrees(degrees):
    if degrees <= 0:
        return (255, 255, 255) # white
    elif degrees > 0 and degrees <= 10:
        return (0, 153, 255) # blue
    elif degrees > 10 and degrees <= 15:
        return (0, 204, 0) # green
    elif degrees > 15 and degrees <= 20:
        return (255, 255, 0) # yellow
    elif degrees > 20 and degrees <= 30:
        return (204, 102, 0) # orange
    else:
        return (204, 0, 0) # red

def updateNeopixelColor(degrees):
    if system_stopped:
        return

    color = selectColorByDegrees(degrees)
    print('Color selected: {}'.format(color), flush=True)
    pixels.fill(color)
    pixels.show()

def setNeopixelColor(colors):
    rgb = [int(x) for x in colors.split(",")]
    print('Colors rgb: ', rgb, flush=True)
    pixels.fill((rgb[0], rgb[1], rgb[2]))
    pixels.show()

def stopNeopixels():
    pixels.fill((0,0,0))
    pixels.show()

### system
def stop():
    if not timer_update is None and timer_update.isRunning():
        timer_update.stop()
    stopNeopixels()
    if not timer_system is None and timer_system.isRunning():
        timer_system.stop()

def shutdown():
    stop()
    print('Shutdown system.')
    os.system("sudo shutdown -h now")

### commands
def updateWeather():
    print('---', flush=True)
    print('Update weather', flush=True)
    data = getCurrentWeather()
    if not data:
        print('Abort: weather data is None', flush=True)
        return

    degrees = data[0]
    weather_id = data[1]

    updateNeopixelColor(degrees)
    ble_app.services[0].set_degrees(degrees)
    ble_app.services[0].set_weather_id(weather_id)
    print('---', flush=True)

def getIpAddress():
    command = 'hostname -I'
    proc = subprocess.Popen(command, stdout = subprocess.PIPE, shell = True)
    proc = proc.communicate()[0]
    ip_address = str(proc).split(" ")[0].split('\'')[1]
    print ("IP Address registered: %s" % ip_address, flush=True)
    return ip_address

def shouldShutdown():
    if not shutdown_button.value:
        print('Should shutdown system..', flush=True)
        shutdown()

# execution
ble_app = BleApplication()
ble_app.add_service(WeatherService(0))
ble_app.add_service(RgbColorService(1))
ble_app.add_service(SystemService(2))
ble_app.register()

ble_adv = WeatherStationAdvertisement(0)
ble_adv.register()

timer_update = RepeatedTimer(delay_weather, updateWeather)
timer_system = RepeatedTimer(delay_system, shouldShutdown)

try:
    print('GATT application running')
    ble_app.services[2].set_ip_address(getIpAddress())
    ble_app.run()
except KeyboardInterrupt:
    ble_app.quit()
    pass

stop()
