import dbus

from ble_gatt_server.advertisement import Advertisement
from ble_gatt_server.service import Application, Service, Characteristic, Descriptor

GATT_CHRC_IFACE = "org.bluez.GattCharacteristic1"
NOTIFY_TIMEOUT = 5000

class BleApplication(Application):
    pass

class WeatherStationAdvertisement(Advertisement):
    def __init__(self, index):
        Advertisement.__init__(self, index, "peripheral")
        self.add_local_name("LighthouseStationBLE")
        self.include_tx_power = True

class WeatherService(Service):
    WEATHER_SVC_UUID = "00000000-8cb1-44ce-9a66-001dca0941a6"

    def __init__(self, index):
        self.city_id = 6454880 # Orsay (default)
        Service.__init__(self, index, self.WEATHER_SVC_UUID, True)
        self.add_characteristic(WeatherCharacteristic(self))
        self.add_characteristic(ResumeWeatherCharacteristic(self))
        self.add_characteristic(CityIdCharacteristic(self))

    def get_city_id(self):
        return self.city_id

    def set_city_id(self, city_id):
        self.city_id = city_id

    def get_weather_id(self):
        return self.weather_id

    def set_weather_id(self, weather_id):
        self.weather_id = weather_id

    def get_degrees(self):
        return self.degrees

    def set_degrees(self, degrees):
        self.degrees = degrees

class WeatherCharacteristic(Characteristic):
    WEATHER_CHARACTERISTIC_UUID = "00000001-8cb1-44ce-9a66-001dca0941a6"

    def __init__(self, service):
        self.notifying = False

        Characteristic.__init__(
                self, self.WEATHER_CHARACTERISTIC_UUID,
                ["notify", "read"], service)
        self.add_descriptor(WeatherDescriptor(self))

    def get_weather(self):
        value = []

        degrees = self.service.get_degrees()
        weather_id = self.service.get_weather_id()
        city_id = self.service.get_city_id()
        data = 'D=%s,W=%s,C=%s' % (degrees, weather_id, city_id)
        print('Sending: ', data, flush=True)

        for c in data:
            value.append(dbus.Byte(c.encode()))

        return value

    def set_weather_callback(self):
        if self.notifying:
            value = self.get_weather()
            self.PropertiesChanged(GATT_CHRC_IFACE, {"Value": value}, [])

        return self.notifying

    def StartNotify(self):
        if self.notifying:
            return

        self.notifying = True
        print('Start notify weather service', flush=True)

        value = self.get_weather()
        self.PropertiesChanged(GATT_CHRC_IFACE, {"Value": value}, [])
        self.add_timeout(NOTIFY_TIMEOUT, self.set_weather_callback)

    def StopNotify(self):
        self.notifying = False

    def ReadValue(self, options):
        value = self.get_weather()

        return value

class WeatherDescriptor(Descriptor):
    WEATHER_DESCRIPTOR_UUID = "0001"
    WEATHER_DESCRIPTOR_VALUE = "Weather forecast updates"

    def __init__(self, characteristic):
        Descriptor.__init__(
                self, self.WEATHER_DESCRIPTOR_UUID,
                ["read"],
                characteristic)

    def ReadValue(self, options):
        value = []
        desc = self.WEATHER_DESCRIPTOR_VALUE

        for c in desc:
            value.append(dbus.Byte(c.encode()))

        return value

class ResumeWeatherCharacteristic(Characteristic):
    RESUME_WEATHER_CHARACTERISTIC_UUID = "00000002-8cb1-44ce-9a66-001dca0941a6"

    def __init__(self, service):
        Characteristic.__init__(
                self, self.RESUME_WEATHER_CHARACTERISTIC_UUID,
                ["write"], service)
        self.add_descriptor(ResumeWeatherDescriptor(self))

    def WriteValue(self, value, options):
        print('Resume command received', flush=True)
        self.service.get_characteristics()[0].StartNotify()

class ResumeWeatherDescriptor(Descriptor):
    RESUME_WEATHER_DESCRIPTOR_UUID = "0002"
    RESUME_WEATHER_DESCRIPTOR_VALUE = "Resume weather"

    def __init__(self, characteristic):
        Descriptor.__init__(
                self, self.RESUME_WEATHER_DESCRIPTOR_UUID,
                ["read"],
                characteristic)

    def ReadValue(self, options):
        value = []
        desc = self.RESUME_WEATHER_DESCRIPTOR_VALUE

        for c in desc:
            value.append(dbus.Byte(c.encode()))

        return value

class CityIdCharacteristic(Characteristic):
    CITY_ID_CHARACTERISTIC_UUID = "00000003-8cb1-44ce-9a66-001dca0941a6"

    def __init__(self, service):
        Characteristic.__init__(
                self, self.CITY_ID_CHARACTERISTIC_UUID,
                ["read", "write"], service)
        self.add_descriptor(CityIdDescriptor(self))

    def WriteValue(self, value, options):
        print('Value received: ', (str(value)), flush=True)
        val = "".join(map(chr, value))
        print('New city value:', val, flush=True)

        self.service.set_city_id(val)
        self.service.get_characteristics()[0].StartNotify()

    def ReadValue(self, options):
        value = []

        val = self.service.get_city_id()
        value.append(dbus.Byte(val.encode()))

        return value

class CityIdDescriptor(Descriptor):
    CITY_ID_DESCRIPTOR_UUID = "0003"
    CITY_ID_DESCRIPTOR_VALUE = "City id"

    def __init__(self, characteristic):
        Descriptor.__init__(
                self, self.CITY_ID_DESCRIPTOR_UUID,
                ["read"],
                characteristic)

    def ReadValue(self, options):
        value = []
        desc = self.CITY_ID_DESCRIPTOR_VALUE

        for c in desc:
            value.append(dbus.Byte(c.encode()))

        return value

class RgbColorService(Service):
    RGB_COLOR_SVC_UUID = "00000000-8194-4451-aaf5-7874c7c16a27"

    def __init__(self, index):
        Service.__init__(self, index, self.RGB_COLOR_SVC_UUID, True)
        self.add_characteristic(RgbColorCharacteristic(self))

    def get_rgb_color(self):
        return self.rgb_color

    def set_rgb_color(self, rgb_color):
        self.rgb_color = rgb_color

class RgbColorCharacteristic(Characteristic):
    RGB_COLOR_CHARACTERISTIC_UUID = "00000001-8194-4451-aaf5-7874c7c16a27"

    def __init__(self, service):
        Characteristic.__init__(
                self, self.RGB_COLOR_CHARACTERISTIC_UUID,
                ["write"], service)
        self.add_descriptor(RgbColorDescriptor(self))

    def WriteValue(self, value, options):
        app.services[0].get_characteristics()[0].StopNotify()
        print('Weather service notifying stopped', flush=True)

        print('Value received: ', (str(value)), flush=True)
        val = "".join(map(chr, value))
        print('New rgb color value: ', val, flush=True)

        self.service.set_rgb_color(val)

class RgbColorDescriptor(Descriptor):
    RGB_COLOR_DESCRIPTOR_UUID = "0001"
    RGB_COLOR_DESCRIPTOR_VALUE = "RGB Color array"

    def __init__(self, characteristic):
        Descriptor.__init__(
                self, self.RGB_COLOR_DESCRIPTOR_UUID,
                ["read"],
                characteristic)

    def ReadValue(self, options):
        value = []
        desc = self.RGB_COLOR_DESCRIPTOR_VALUE

        for c in desc:
            value.append(dbus.Byte(c.encode()))

        return value

class SystemService(Service):
    SYSTEM_SVC_UUID = "00000000-61c8-471e-94f3-5050570167b2"

    def __init__(self, index):
        Service.__init__(self, index, self.SYSTEM_SVC_UUID, True)
        self.add_characteristic(IpAddressSystemCharacteristic(self))
        self.add_characteristic(ShutdownSystemCharacteristic(self))

    def get_ip_address(self):
        return self.ip_address

    def set_ip_address(self, ip_address):
        self.ip_address = ip_address

class IpAddressSystemCharacteristic(Characteristic):
    IP_ADDRESS_SYSTEM_CHARACTERISTIC_UUID = "00000001-61c8-471e-94f3-5050570167b2"

    def __init__(self, service):
        Characteristic.__init__(
                self, self.IP_ADDRESS_SYSTEM_CHARACTERISTIC_UUID,
                ["read"], service)
        self.add_descriptor(IpAddressSystemDescriptor(self))

    def ReadValue(self, options):
        value = []

        data = self.service.get_ip_address()
        for c in data:
            value.append(dbus.Byte(c.encode()))

        return value

class IpAddressSystemDescriptor(Descriptor):
    IP_ADDRESS_SYSTEM_DESCRIPTOR_UUID = "0001"
    IP_ADDRESS_SYSTEM_DESCRIPTOR_VALUE = "Ip address"

    def __init__(self, characteristic):
        Descriptor.__init__(
                self, self.IP_ADDRESS_SYSTEM_DESCRIPTOR_UUID,
                ["read"],
                characteristic)

    def ReadValue(self, options):
        value = []
        desc = self.IP_ADDRESS_SYSTEM_DESCRIPTOR_VALUE

        for c in desc:
            value.append(dbus.Byte(c.encode()))

        return value

class ShutdownSystemCharacteristic(Characteristic):
    SHUTDOWN_SYSTEM_CHARACTERISTIC_UUID = "00000002-61c8-471e-94f3-5050570167b2"

    def __init__(self, service):
        Characteristic.__init__(
                self, self.SHUTDOWN_SYSTEM_CHARACTERISTIC_UUID,
                ["write"], service)
        self.add_descriptor(ShutdownSystemDescriptor(self))

    def WriteValue(self, value, options):
        print('Shutdown command received', flush=True)
        app.services[0].get_characteristics()[0].StopNotify()
        print('Weather service notifying stopped', flush=True)
        ##### app.shutdown()

class ShutdownSystemDescriptor(Descriptor):
    SHUTDOWN_SYSTEM_DESCRIPTOR_UUID = "0001"
    SHUTDOWN_SYSTEM_DESCRIPTOR_VALUE = "Shutdown system"

    def __init__(self, characteristic):
        Descriptor.__init__(
                self, self.SHUTDOWN_SYSTEM_DESCRIPTOR_UUID,
                ["read"],
                characteristic)

    def ReadValue(self, options):
        value = []
        desc = self.SHUTDOWN_SYSTEM_DESCRIPTOR_VALUE

        for c in desc:
            value.append(dbus.Byte(c.encode()))

        return value
