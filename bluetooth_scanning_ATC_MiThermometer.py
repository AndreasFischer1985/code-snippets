#!/usr/bin/env python3

#--------------------------------------------------------------------------------
# The following lines of code scan for BLE advertisements from Xiaomi Mi sensors
# with custom ATC firmware (cf. github.com/atc1441/ATC_MiThermometer)
# and print their respective Temperature-, Humidity- & Battery-values.
#--------------------------------------------------------------------------------

import asyncio
from bleak import BleakScanner
async def scanBLE():
  devices = await BleakScanner.discover(timeout=20.0)
  res=[]
  for d in devices:
    if 'A4:C1:38:' in d.details['props']['Address']:
      print(d.details)
      b=d.details['props']['ServiceData']['0000181a-0000-1000-8000-00805f9b34fb']
      print(d.details['props']['Address'])
      print("Tem="+str(int.from_bytes(b[7:8],byteorder="big")/10)) #Temp
      print("Hum="+str(int.from_bytes(b[8:9],byteorder="big")/100)) #Humid
      print("Bat="+str(int.from_bytes(b[9:10],byteorder="big")/100)) #Bat
      res.append(d)
  return(res)

devs=asyncio.run(scanBLE())

for d in devs:
  if 'A4:C1:38:' in d.details['props']['Address']:
    b=d.details['props']['ServiceData']['0000181a-0000-1000-8000-00805f9b34fb']
    d.details['props']['Address']
    int.from_bytes(b[7:8],byteorder="big")/10   # Temp
    int.from_bytes(b[8:9],byteorder="big")/100  # Humid
    int.from_bytes(b[9:10],byteorder="big")/100 # Bat
    for x in b[0:6]:  # MAC-Address
      hex(x)

#python3 -m pip install bleak asyncio

