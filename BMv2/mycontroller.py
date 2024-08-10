#!/usr/bin/env python2
import argparse
import grpc
import os
import sys
import copy
import _thread
import threading
from threading import Thread
from time import sleep
from p4utils.utils.sswitch_thrift_API import SimpleSwitchThriftAPI
import networkx as nx
import time
from random import *
import io
from scapy.all import *
from datetime import datetime


key_length =            128
switches =              []
keys =                  []
permutations =          []
inverse_permutations =  []
enid_2_real_id =        {}
Siphash_keys =          []
SipHash_inits =         []

class INTREP(Packet):
    name = "INT Report Header v2.0"
    fields_desc =  [
        BitField("version", 0, 4),
        BitField("hw_id", 0, 6),
        BitField("seq_number", 0, 22),
        BitField("node_id", 0, 32)]

class INTIndiviREP(Packet):
    name = "INT Report Individual Header v2.0"

    fields_desc =  [
        BitField("rep_type", 0, 4),
        BitField("in_type", 0, 4),
        BitField("rep_len", 0, 8),
        BitField("md_len", 0, 8),
        BitField("flag", 0, 4),
        BitField("rsvd", 0, 4),
        ShortField("RepMdBits", 0),
        ShortField("DomainID", 0),
        ShortField("DSMdBits", 0),
        ShortField("DSMdstatus", 0)]

class INTShim(Packet):
    name = "INT Shim header v2.1"
    fields_desc = [
        BitField("type", 0, 4),
        BitField("next_protocol", 0, 2),
        BitField("rsvd", 0, 2),
        BitField("int_length", 0, 8),
        ShortField("NPTDependentField", 0)]

class INTMD(Packet):
    name = "INT-MD Header v2.1"
    fields_desc =  [
        BitField("version", 0, 4),
        BitField("flags", 0, 3),
        BitField("reserved", 0, 12),
        BitField("HopMetaLength", 0, 5),
        BitField("RemainingHopCount", 0, 8),
        BitField("instruction_mask_0003", 0, 4),
        BitField("instruction_mask_0407", 0, 4),
        BitField("instruction_mask_0811", 0, 4),
        BitField("instruction_mask_1215", 0, 4),
        ShortField("DomainID", 0),
        ShortField("DomainInstructions", 0),
        ShortField("DomainFlags", 0)]

bind_layers(UDP,INTREP,dport=1234)
bind_layers(INTREP,INTIndiviREP)
bind_layers(INTIndiviREP,Ether,in_type=3)
bind_layers(INTShim,INTMD,type  = 1)

SWITCH_ID_BIT =             0b10000000
L1_PORT_IDS_BIT =           0b01000000
HOP_LATENCY_BIT =           0b00100000
QUEUE_BIT =                 0b00010000
INGRESS_TSTAMP_BIT =        0b00001000
EGRESS_TSTAMP_BIT =         0b00000100
L2_PORT_IDS_BIT =           0b00000010
EGRESS_PORT_TX_UTIL_BIT =   0b00000001

def str2hex(s):
    odata = 0
    su = s.upper()
    for c in su:
        tmp = ord(c)
        if tmp <= ord('9'):
            odata = odata << 4
            odata += tmp - ord('0')
        elif ord('A') <= tmp <= ord('F'):
            odata = odata << 4
            odata += tmp - ord('A') + 10
    return odata

class HopMetadata():
    def __init__(self):
        self.switch_id = None
        self.l1_ingress_port_id = None
        self.l1_egress_port_id = None
        self.hop_latency = None
        self.q_id = None
        self.q_occupancy = None
        self.ingress_tstamp = None
        self.egress_tstamp = None
        self.l2_ingress_port_id = None
        self.l2_egress_port_id = None
        self.egress_port_tx_util = None
        self.padding = None
        self.verification_checksum = None

    @staticmethod
    def from_bytes(data, ins_map):
        hop = HopMetadata()
        d = io.BytesIO(data)
        if ins_map & SWITCH_ID_BIT:
            hop.switch_id = int.from_bytes(d.read(4), byteorder='big')
        if ins_map & L1_PORT_IDS_BIT:
            hop.l1_ingress_port_id = int.from_bytes(d.read(2), byteorder='big')
            hop.l1_egress_port_id = int.from_bytes(d.read(2), byteorder='big')
        if ins_map & HOP_LATENCY_BIT:
            hop.hop_latency = int.from_bytes(d.read(4), byteorder='big')
        if ins_map & QUEUE_BIT:
            hop.q_id = int.from_bytes(d.read(1), byteorder='big')
            hop.q_occupancy = int.from_bytes(d.read(3), byteorder='big')
        if ins_map & INGRESS_TSTAMP_BIT:
            hop.ingress_tstamp = int.from_bytes(d.read(8), byteorder='big')
        if ins_map & EGRESS_TSTAMP_BIT:
            hop.egress_tstamp = int.from_bytes(d.read(8), byteorder='big')
        if ins_map & L2_PORT_IDS_BIT:
            hop.l2_ingress_port_id = int.from_bytes(d.read(4), byteorder='big')
            hop.l2_egress_port_id = int.from_bytes(d.read(4), byteorder='big')
        if ins_map & EGRESS_PORT_TX_UTIL_BIT:
            hop.egress_port_tx_util = int.from_bytes(d.read(4), byteorder='big')

        #padding
        hop.padding = int.from_bytes(d.read(4), byteorder='big')
        hop.verification_checksum = int.from_bytes(d.read(8), byteorder='big')
        return hop

    def __str__(self):
        return str(vars(self))


def parse_encrypted_metadata(meta):
    #print(meta.switch_id)
    realid = enid_2_real_id[meta.switch_id] - 1

    int_switch_id_key = keys[realid]['int_switch_id_key']
    meta.switch_id = meta.switch_id ^ str2hex(int_switch_id_key[2:])

    int_level1_port_ids_key = keys[realid]['int_level1_port_ids_key']
    meta.l1_ingress_port_id = meta.l1_ingress_port_id ^ str2hex(int_level1_port_ids_key[2:])
    meta.l1_egress_port_id = meta.l1_egress_port_id ^ str2hex(int_level1_port_ids_key[2:])

    int_hop_latency_key = keys[realid]['int_hop_latency_key']
    meta.hop_latency = meta.hop_latency ^ str2hex(int_hop_latency_key[2:])

    int_q_occupancy_key_1 = keys[realid]['int_q_occupancy_key_1']
    meta.q_id = meta.q_id ^ str2hex(int_q_occupancy_key_1[2:])

    int_q_occupancy_key_2 = keys[realid]['int_q_occupancy_key_2']
    meta.q_occupancy = meta.q_occupancy ^ str2hex(int_q_occupancy_key_2[2:])

    int_timestamp_key = keys[realid]['int_timestamp_key']
    meta.ingress_tstamp = meta.ingress_tstamp ^ str2hex(int_timestamp_key[2:])
    meta.egress_tstamp = meta.egress_tstamp ^ str2hex(int_timestamp_key[2:])

    int_port_ids_key = keys[realid]['int_port_ids_key']
    meta.l2_ingress_port_id = meta.l2_ingress_port_id ^ str2hex(int_port_ids_key[2:])
    meta.l2_egress_port_id = meta.l2_egress_port_id ^ str2hex(int_port_ids_key[2:])

    int_egress_tx_util_key = keys[realid]['int_egress_tx_util_key']
    meta.egress_port_tx_util = meta.egress_port_tx_util ^ str2hex(int_egress_tx_util_key[2:])

    return meta



def parse_metadata(int_pkt):
    #int_pkt.show()

    instructions = (int_pkt[INTMD].instruction_mask_0003 << 4) + int_pkt[INTMD].instruction_mask_0407
    int_len = int_pkt.int_length-3

    #+3 including padding and siphash value
    hop_meta_len = int_pkt[INTMD].HopMetaLength
    int_metadata = int_pkt.load[:int_len<<2]

    hop_count = int(int_len /hop_meta_len)
    hop_metadata = []
    timeconsumption = 0
    for i in range(hop_count):
        metadata_source = int_metadata[i*hop_meta_len<<2:(i+1)*hop_meta_len<<2]
        meta = HopMetadata.from_bytes(metadata_source, instructions)
        #meta.switch_id = enid_2_real_id[meta.switch_id]
        print(meta)
        t1 = datetime.now()
        #meta = parse_encrypted_metadata(meta)
        t2 = datetime.now()
        t = t2-t1
        #print(t)
        timeconsumption += meta.hop_latency
        #print(meta.hop_latency)
        hop_metadata.append(meta)
    #print(timeconsumption)

    return hop_metadata


def handle_pkt(pkt):
    if IP in pkt :
        #print("\n\n********* Receiving Telemtry Report ********")
        #pkt[INTREP].show()
        parse_metadata(INTShim(pkt.load))

# Import P4Runtime lib from parent utils dir
# Probably there's a better way of doing this.

def generate_key(length):
    k1 = '0x' + ''.join([choice("0123456789ABCDEF") for i in range(length)])

    return k1

def generate_permutation(length):
    p = [i for i in range(length)]
    shuffle(p)
    inv_p = [0 for i in range(length)]
    for i in range(length):
        inv_p[p[i]] = i

    for i in range(length):
        p[i] = str(p[i])
        inv_p[i] = str(inv_p[i])

    return p, inv_p


def issue_keys(num):
    switch_num = num
    for i in range(switch_num):
        s = SimpleSwitchThriftAPI(9090 + i)
        #print(i)



        skey = {}
        skey['int_switch_id_key'] = int_switch_id_key
        skey['int_level1_port_ids_key'] = int_level1_port_ids_key
        skey['int_port_ids_key'] = int_port_ids_key
        skey['int_hop_latency_key'] = int_hop_latency_key
        skey['int_q_occupancy_key_1'] = int_q_occupancy_key_1
        skey['int_q_occupancy_key_2'] = int_q_occupancy_key_2
        skey['int_timestamp_key'] = int_timestamp_key
        skey['int_egress_tx_util_key'] = int_egress_tx_util_key

        s.table_add("process_encrypt.tb_encrypt", "encrypt_int_metadata", str(i+1), tkey)

        keys.append(skey)
        switches.append(s)

        #print(int_switch_id_key[2:])
        #print(int_switch_id_key)
        t = str2hex(int_switch_id_key[2:])
        #print(i+1)
        #print(t ^ (i+1))
        encrypted_id = t ^ (i+1)
        enid_2_real_id[encrypted_id] = i+1


def mysniff(iface):
    sniff(iface = iface,filter='inbound and tcp or udp',
        prn = lambda x: handle_pkt(x))


def main():


    switch_num = 5
    for i in range(switch_num):
        s = SimpleSwitchThriftAPI(9090 + i)
        s.set_queue_rate(9000)
        s.set_queue_depth(9000)

        k1 = generate_key(key_length//4)
        keys.append(k1)

        p, inv_p = generate_permutation(key_length)
        permutations.append(p)
        inverse_permutations.append(inv_p)


        s.table_add("process_encrypt.tb_read_encryption_key", "read_encryption_key", str(i+1), [k1])
        s.table_add("process_encrypt.tb_read_permutation", "read_permutation", str(i+1), p)

        s.table_add("process_encrypt.tb_read_inverse_permutation", "read_inverse_permutation", str(i+1), inv_p)
    #for k in enid_2_real_id.keys():
        #print(k)
        #print(enid_2_real_id[k])
        spkey1 = generate_key(64//4)
        spkey2 = generate_key(64//4)
        Siphash_keys.append([spkey1, spkey2])

        i0 = generate_key(64//4)
        i1 = generate_key(64//4)
        i2 = generate_key(64//4)
        i3 = generate_key(64//4)
        SipHash_inits.append([i0, i1, i2, i3])

        s.table_add("process_SipHash_1_3.tb_read_SipRound_keys", "read_SipRound_keys", str(i+1), [spkey1, spkey2, i0, i1, i2, i3])


    t1 = threading.Thread(target = mysniff, args = ("s1-cpu-eth1",))
    t2 = threading.Thread(target = mysniff, args = ("s2-cpu-eth1",))
    t3 = threading.Thread(target = mysniff, args = ("s3-cpu-eth1",))
    t4 = threading.Thread(target = mysniff, args = ("s4-cpu-eth1",))
    t5 = threading.Thread(target = mysniff, args = ("s5-cpu-eth1",))
    #t6 = threading.Thread(target = mysniff, args = ("s6-cpu-eth1",))
    #t7 = threading.Thread(target = mysniff, args = ("s7-cpu-eth1",))
    #t8 = threading.Thread(target = mysniff, args = ("s8-cpu-eth1",))
    #t9 = threading.Thread(target = mysniff, args = ("s9-cpu-eth1",))
    #t10 = threading.Thread(target = mysniff, args = ("s10-cpu-eth1",))
    t1.start()
    t2.start()
    t3.start()
    t4.start()
    t5.start()






if __name__ == '__main__':
    main()
