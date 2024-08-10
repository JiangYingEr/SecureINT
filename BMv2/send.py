from scapy.all import *
from time import sleep
from datetime import datetime
import threading
import random



source_macs_pool = []
num_rule = 10000

packets = []

hard_timeout = 200
idle_timeout = 20

def get_if():
    ifs=get_if_list()
    iface=None # "h1-eth0"
    for i in get_if_list():
        if "eth0" in i:
            iface=i
            break;
    if not iface:
        print("Cannot find eth0 interface")
        exit(1)
    return iface



def sendpacket(pkt):
    while True:
        sendp(pkt, iface='h1-eth0')
        break
        #sleep(0.016)



def main():
    #with open('/home/kdz/data/random_macs.txt', 'r') as f:
     #   macs = f.readlines()
    #f.close()
    #for mac in macs:
     #   #print(mac)
     #   source_macs_pool.append(mac[:-1])


    iface = get_if()
    srcmac = get_if_hwaddr(iface)
    #load = bytes('test', 'utf-8').zfill(9395)
    load = bytes('test', 'utf-8').zfill(5)
    #load = bytes('test', 'utf-8').zfill(9455)


    pkt = Ether(src=srcmac, dst='ff:ff:ff:ff:ff:ff') / IP(dst='10.0.3.2',flags = 2) / UDP(dport=666, sport=random.randint(49152,65535)) / load

    #t = 0
    t1 = threading.Thread(target=sendpacket, args=(pkt, ))
    #t2 = threading.Thread(target=sendpacket, args=(pkt, ))
    #t3 = threading.Thread(target=sendpacket, args=(pkt, ))
    #t2 = threading.Thread(target=sendpacket, args=(601, 1200, ))
    #t3 = threading.Thread(target=sendpacket, args=(1201, 1800, ))
    t1.start()
    #sleep(25)
    #t2.start()
    #sleep(25)
    #t3.start()

if __name__ == '__main__':
    main()
