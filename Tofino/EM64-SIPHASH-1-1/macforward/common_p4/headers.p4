
#ifndef _HEADERS_
#define _HEADERS_

typedef bit<48> mac_addr_t;
typedef bit<32> ipv4_addr_t;
typedef bit<128> ipv6_addr_t;
typedef bit<12> vlan_id_t;

typedef bit<16> ether_type_t;
const ether_type_t ETHERTYPE_IPV4 = 16w0x0800;
const ether_type_t ETHERTYPE_ARP = 16w0x0806;
const ether_type_t ETHERTYPE_IPV6 = 16w0x86dd;
const ether_type_t ETHERTYPE_VLAN = 16w0x8100;

typedef bit<8> ip_protocol_t;
const ip_protocol_t IP_PROTOCOLS_ICMP = 1;
const ip_protocol_t IP_PROTOCOLS_TCP = 6;
const ip_protocol_t IP_PROTOCOLS_UDP = 17;

header ethernet_h {
    mac_addr_t dst_addr;
    mac_addr_t src_addr;
    bit<16> ether_type;
}


header ipv4_t {
    bit<4>    version;
    bit<4>    ihl;
    bit<8>    diffserv;
    bit<16>   totalLen;
    bit<16>   identification;
    bit<3>    flags;
    bit<13>   fragOffset;
    bit<8>    ttl;
    bit<8>    protocol;
    bit<16>   hdrChecksum;
    ipv4_addr_t srcAddr;
    ipv4_addr_t dstAddr;
}


header data_t {
    bit<32> data;
}

header data1_t {
    bit<128> data;
}

header endata_t {
    bit<1> pos0;
    bit<1> pos1;
    bit<1> pos2;
    bit<1> pos3;
    bit<1> pos4;
    bit<1> pos5;
    bit<1> pos6;
    bit<1> pos7;
}



//integrity verification, the siphash value
header integrity_checksum_t {
    bit<32> integrity_checksum;
}

header encryption_key_t {
    bit<32> k;
}


// SipHash internal state
header siphash_state_t {
    bit<32> v0;
    bit<32> v1;
    bit<32> v2;
    bit<32> v3;
}

struct metadata_t {
    bit<16>       l4_src_port;
    bit<16>       l4_dst_port;
    //siphash_state_t     siphash_a;
    //siphash_state_t		siphash_b;
}

struct header_t {
    ethernet_h ethernet;
    ipv4_t       ipv4;

    //data_t data; 
    data1_t data1;
    //endata_t plaintext;
    endata_t c0;
    endata_t c1;
    endata_t c2;
    endata_t c3;
    endata_t c4;
    endata_t c5;
    endata_t c6;
    endata_t c7;
    endata_t c8;
    endata_t c9;
    endata_t c10;
    endata_t c11;
    endata_t c12;
    endata_t c13;
    endata_t c14;
    endata_t c15;

    //SipHash
    siphash_state_t             siphash_internal_state;
    siphash_state_t siphash_a;
    //siphash_state_t siphash_b;
    //encryption_key_t    encryption_key;
    //cipher_t    c;


    //checksum
    integrity_checksum_t        integrity_checksum;
}

struct empty_header_t {}

struct empty_metadata_t {}

#endif
