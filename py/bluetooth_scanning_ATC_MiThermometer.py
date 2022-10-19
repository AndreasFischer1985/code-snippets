#!/usr/bin/env python3

#--------------------------------------------------------------------------------
# The following lines of code scan for BLE advertisements from Xiaomi Mi sensors
# with custom ATC firmware (cf. github.com/atc1441/ATC_MiThermometer)
# and print their respective Temperature-, Humidity- & Battery-values.
# Requires bleak and asyncio (python3 -m pip install bleak asyncio).
#--------------------------------------------------------------------------------

import asyncio
from bleak import BleakScanner
async def scanBLE():
  devices = await BleakScanner.discover(timeout=20.0)
  res=[]
  for d in devices:
    print(d.details)
    if d.details['props']['Address'].startswith('A4:C1:38:'):
      b=d.details['props']['ServiceData']['0000181a-0000-1000-8000-00805f9b34fb']
      res.append({
        "Address":d.details['props']['Address'],
        "Temp":int.from_bytes(b[7:8],byteorder="big")/10,
        "Humid":int.from_bytes(b[8:9],byteorder="big")/100,
        "Bat":int.from_bytes(b[9:10],byteorder="big")/100})
      print(res[-1])
  return(res)

stats=asyncio.run(scanBLE())
print(stats)

#{'path': '/org/bluez/hci0/dev_A4_C1_38_E4_21_9E', 'props': {'Address': 'A4:C1:38:E4:21:9E', 'AddressType': 'public', 'Name': 'ATC_E4219E', 'Alias': 'ATC_E4219E', 'Paired': False, 'Trusted': True, 'Blocked': False, 'LegacyPairing': False, 'Connected': False, 'UUIDs': ['00001800-0000-1000-8000-00805f9b34fb', '00001801-0000-1000-8000-00805f9b34fb', '0000180f-0000-1000-8000-00805f9b34fb', '0000181a-0000-1000-8000-00805f9b34fb', '00001f10-0000-1000-8000-00805f9b34fb', '00010203-0405-0607-0809-0a0b0c0d1912'], 'Adapter': '/org/bluez/hci0', 'ServicesResolved': False, 'RSSI': -95, 'ServiceData': {'0000181a-0000-1000-8000-00805f9b34fb': bytearray(b'\xa4\xc18\xe4!\x9e\x00\xd3Pd\x0c\x1f\xb9')}}}
#{'Address': 'A4:C1:38:E4:21:9E', 'Temp': 21.1, 'Humid': 0.8, 'Bat': 1.0}

