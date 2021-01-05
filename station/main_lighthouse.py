### imports
import os
import subprocess
from repeated_timer import RepeatedTimer
from requests import get
import json
import board
import digitalio
import neopixel
from bluetooth import *

### params
delay_weather = 10.0 # seconds
delay_system = 1.0
city_id = 6454880 # Orsay (default)

cmd_update = 0
cmd_city = 1
cmd_color = 2
cmd_ip = 3
cmd_shutdown = 9

base = 'https://api.openweathermap.org/data/2.5/weather'
city = 'id=%s'
units = 'units=metric'
appid = 'appid=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
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

server_sock = BluetoothSocket(RFCOMM)
server_sock.bind(("", PORT_ANY))
server_sock.listen(1)
port = server_sock.getsockname()[1]
uuid = '6a8f42ea-2262-41f4-b128-7112f2173ede'
advertise_service(server_sock, 'Lighthouse Weather Server',
                  service_id = uuid,
                  service_classes = [ uuid, SERIAL_PORT_CLASS ],
                  profiles = [ SERIAL_PORT_PROFILE ])

timer_update = None
timer_system = None

### weather requests
def getCurrentWeather():
    if system_stopped:
        return

    try:
        data = get(url % (city_id), timeout = 5).json()
        temperature = int(data['main']['temp'])
        weather_id = data['weather'][0]['id']
        print('Request response: %s°C (id: %s)' % (temperature, weather_id), flush=True)
        return [temperature, weather_id]
    except Exception as e:
        print('Request connection error: %s' % e, flush=True)
        pass

def updateCurrentCity(data):
    global city_id
    city_id = data
    print('City id updated to %d' % city_id, flush=True)

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

### bluetooth
def sendCurrentData(degrees, weather_id, city_id):
    try:
        data = 'D=%s,W=%s,C=%d' % (degrees, weather_id, city_id)
        client_sock.send(data.encode('utf-8'))
    except Exception:
        pass

def disconnect():
    print('Disconnecting..', flush=True)
    try:
        server_sock.close()
        print('Socket closed.', flush=True)
    except Exception:
        pass

### system
def sendIpAddress():
    command = 'hostname -I'
    proc = subprocess.Popen(command, stdout = subprocess.PIPE, shell = True)
    proc = proc.communicate()[0]
    ip_address = str(proc).split(" ")[0].split('\'')[1]
    print ("Found ip: %s" % ip_address, flush=True)

    try:
        data = 'IP=%s' % (ip_address)
        client_sock.send(data.encode('utf-8'))
    except Exception as e:
        print('Socket exception: %s' % e, flush=True)
        pass

def stop():
    if not timer_update is None and timer_update.isRunning():
        timer_update.stop()
    if not timer_system is None and timer_system.isRunning():
        timer_system.stop()
    disconnect()
    stopNeopixels()

def shutdown():
    stop()
    print('Shutdown system.')
    os.system("sudo shutdown -h now")

### execute
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
    sendCurrentData(degrees, weather_id, city_id)
    print('---', flush=True)

def shouldShutdown():
    if not shutdown_button.value:
        print('Should shutdown system..', flush=True)
        shutdown()

timer_update = RepeatedTimer(delay_weather, updateWeather)
timer_system = RepeatedTimer(delay_system, shouldShutdown)

try:
    while True:
        print('Waiting for connection on RFCOMM channel %d' % port, flush=True)

        client_sock, client_info = server_sock.accept()
        print('Accepted connection from ', client_info, flush=True)

        while True:
            try:
                data = client_sock.recv(1024)
            except:
                break

            if len(data) == 0: break

            data_received = data.decode('utf-8').rstrip()
            print('Received data: ', data_received, flush=True)

            cmd = data_received.split('CMD=')[1].split(',VAL=')
            cmd_key = int(cmd[0])
            cmd_value = None
            if cmd_key == cmd_city or cmd_key == cmd_color:
                cmd_value = cmd[1]
            print('Cmd key: %d, Cmd value: %s' % (cmd_key, cmd_value), flush=True)

            if cmd_key == cmd_update:
                print('Command restart timer received..', flush=True)
                if not timer_update.isRunning():
                    timer_update.start()
            elif cmd_key == cmd_city:
                print('Command city received..', flush=True)
                if not timer_update.isRunning():
                    timer_update.start()
                updateCurrentCity(int(cmd_value))
            elif cmd_key == cmd_color:
                print('Command colors received..', flush=True)
                if timer_update.isRunning():
                    timer_update.stop()
                setNeopixelColor(cmd_value)
            elif cmd_key == cmd_ip:
                print('Command ip received..', flush=True)
                sendIpAddress()
            elif cmd_key == cmd_shutdown:
                print('Command shutdown received..', flush=True)
                shutdown()
            else:
                print('Command not implemented.', flush=True)
            print('---', flush=True)

        try:
            client_sock.close()
        except:
            pass

except KeyboardInterrupt:
    pass

stop()
