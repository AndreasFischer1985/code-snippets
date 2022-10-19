#!/usr/bin/env python3

import socket
mac="98d8638c57b6" # MAC-Address of Link2Home-Socket
port=35932
state="FF" #00=OFF, FF=ON
string="a104"+mac+"000901f202d171500101"+state
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
sock.sendto(bytes.fromhex(string),("192.168.1.255",port))
