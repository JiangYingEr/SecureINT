#include "defines.p4"
#include "headers.p4"

#ifndef __INT_HEADERS__
#define __INT_HEADERS__


/********Headers for INT*********/

// INT shim header for TCP/UDP
header intl4_shim_t {
    bit<4> int_type;                // Type of INT Header
    bit<2> npt;                     // Next protocol type
    bit<2> rsvd;                    // Reserved
    bit<8> len;                     // Length of INT Metadata header and INT stack in 4-byte words, not including the shim header (1 word)
    bit<6> udp_ip_dscp;            // depends on npt field. either original dscp, ip protocol or udp dest port
    bit<10> udp_ip;                // depends on npt field. either original dscp, ip protocol or udp dest port
}

const bit<16> INT_SHIM_HEADER_SIZE = 4;

// INT header
header int_header_t {
    bit<4>   ver;                    // Version
    bit<1>   d;                      // Discard
    bit<1>  e;
    bit<1>  m;
    bit<10>  rsvd;
    bit<2>  secure_mode;            // The mode of SecureINT. 1: centralized; 2: distributed
    bit<5>  hop_metadata_len;
    bit<8>  remaining_hop_cnt;
    bit<4>  instruction_mask_0003; /* split the bits for lookup */
    bit<4>  instruction_mask_0407;
    bit<4>  instruction_mask_0811;
    bit<4>  instruction_mask_1215;
    bit<16>  domain_specific_id;     // Unique INT Domain ID
    bit<16>  ds_instruction;         // Instruction bitmap specific to the INT Domain identified by the Domain specific ID
    bit<16>  ds_flags;               // Domain specific flags
}

const bit<16> INT_HEADER_SIZE = 12;

const bit<16> INT_TOTAL_HEADER_SIZE = INT_HEADER_SIZE + INT_SHIM_HEADER_SIZE;


// INT meta-value headers - different header for each value type
header int_switch_id_t {
    bit<32> switch_id;
}
header int_level1_port_ids_t {
    bit<16> ingress_port_id;
    bit<16> egress_port_id;
}
header int_hop_latency_t {
    bit<32> hop_latency;
}
header int_q_occupancy_t {
    bit<8> q_id;
    bit<24> q_occupancy;
}
header int_ingress_tstamp_t {
    bit<64> ingress_tstamp;
}
header int_egress_tstamp_t {
    bit<64> egress_tstamp;
}
header int_level2_port_ids_t {
    bit<32> ingress_port_id;
    bit<32> egress_port_id;
}
header int_egress_port_tx_util_t {
    bit<32> egress_port_tx_util;
}


//integrity verification, the siphash value
header int_integrity_checksum_t {
    bit<64> int_integrity_checksum;
}

// metadata  + padding + hashvalue
const bit<16> INT_PER_HOP_METADATA_SIZE = 44 + 4 + 8;
const bit<5> INT_PER_HOP_METADATA_SIZE_Words = 14;


//used for encryption

header padding_t {
    bit<32> padding;
}

header EM_value_t {
    bit<128> value;
}

header encryption_key_t {
    bit<128> k;
}

header permutation_t {
    bit<8> pos0;
    bit<8> pos1;
    bit<8> pos2;
    bit<8> pos3;
    bit<8> pos4;
    bit<8> pos5;
    bit<8> pos6;
    bit<8> pos7;
    bit<8> pos8;
    bit<8> pos9;
    bit<8> pos10;
    bit<8> pos11;
    bit<8> pos12;
    bit<8> pos13;
    bit<8> pos14;
    bit<8> pos15;
    bit<8> pos16;
    bit<8> pos17;
    bit<8> pos18;
    bit<8> pos19;
    bit<8> pos20;
    bit<8> pos21;
    bit<8> pos22;
    bit<8> pos23;
    bit<8> pos24;
    bit<8> pos25;
    bit<8> pos26;
    bit<8> pos27;
    bit<8> pos28;
    bit<8> pos29;
    bit<8> pos30;
    bit<8> pos31;
    bit<8> pos32;
    bit<8> pos33;
    bit<8> pos34;
    bit<8> pos35;
    bit<8> pos36;
    bit<8> pos37;
    bit<8> pos38;
    bit<8> pos39;
    bit<8> pos40;
    bit<8> pos41;
    bit<8> pos42;
    bit<8> pos43;
    bit<8> pos44;
    bit<8> pos45;
    bit<8> pos46;
    bit<8> pos47;
    bit<8> pos48;
    bit<8> pos49;
    bit<8> pos50;
    bit<8> pos51;
    bit<8> pos52;
    bit<8> pos53;
    bit<8> pos54;
    bit<8> pos55;
    bit<8> pos56;
    bit<8> pos57;
    bit<8> pos58;
    bit<8> pos59;
    bit<8> pos60;
    bit<8> pos61;
    bit<8> pos62;
    bit<8> pos63;
    bit<8> pos64;
    bit<8> pos65;
    bit<8> pos66;
    bit<8> pos67;
    bit<8> pos68;
    bit<8> pos69;
    bit<8> pos70;
    bit<8> pos71;
    bit<8> pos72;
    bit<8> pos73;
    bit<8> pos74;
    bit<8> pos75;
    bit<8> pos76;
    bit<8> pos77;
    bit<8> pos78;
    bit<8> pos79;
    bit<8> pos80;
    bit<8> pos81;
    bit<8> pos82;
    bit<8> pos83;
    bit<8> pos84;
    bit<8> pos85;
    bit<8> pos86;
    bit<8> pos87;
    bit<8> pos88;
    bit<8> pos89;
    bit<8> pos90;
    bit<8> pos91;
    bit<8> pos92;
    bit<8> pos93;
    bit<8> pos94;
    bit<8> pos95;
    bit<8> pos96;
    bit<8> pos97;
    bit<8> pos98;
    bit<8> pos99;
    bit<8> pos100;
    bit<8> pos101;
    bit<8> pos102;
    bit<8> pos103;
    bit<8> pos104;
    bit<8> pos105;
    bit<8> pos106;
    bit<8> pos107;
    bit<8> pos108;
    bit<8> pos109;
    bit<8> pos110;
    bit<8> pos111;
    bit<8> pos112;
    bit<8> pos113;
    bit<8> pos114;
    bit<8> pos115;
    bit<8> pos116;
    bit<8> pos117;
    bit<8> pos118;
    bit<8> pos119;
    bit<8> pos120;
    bit<8> pos121;
    bit<8> pos122;
    bit<8> pos123;
    bit<8> pos124;
    bit<8> pos125;
    bit<8> pos126;
    bit<8> pos127;

}

// SipHash internal state
header siphash_state_t {
    bit<64> v0;
    bit<64> v1;
    bit<64> v2;
    bit<64> v3;
}

//SipHash initial value
header siphash_constant_t {
    bit<64> i0;
    bit<64> i1;
    bit<64> i2;
    bit<64> i3;
}

// SipHash key
header siphash_key_t {
    bit<64> key_0;
    bit<64> key_1;
}


header int_data_t {
    // Maximum int metadata stack size in bits:
    // (0x3F - 3) * 4 * 8 (excluding INT shim header and INT header)
    varbit<1920> data;
}


// Report Telemetry Headers
header report_group_header_t {
    bit<4>  ver;
    bit<6>  hw_id;
    bit<22> seq_no;
    bit<32> node_id;
}

const bit<8> REPORT_GROUP_HEADER_LEN = 8;

header report_individual_header_t {
    bit<4>  rep_type;
    bit<4>  in_type;
    bit<8>  rep_len;
    bit<8>  md_len;
    bit<1>  d;
    bit<1>  q;
    bit<1>  f;
    bit<1>  i;
    bit<4>  rsvd;
    // Individual report inner contents for Reptype 1 = INT
    bit<16> rep_md_bits;
    bit<16> domain_specific_id;
    bit<16> domain_specific_md_bits;
    bit<16> domain_specific_md_status;
}
const bit<8> REPORT_INDIVIDUAL_HEADER_LEN = 12;

// Telemetry drop report header
header drop_report_header_t {
    bit<32> switch_id;
    bit<16> ingress_port_id;
    bit<16> egress_port_id;
    bit<8>  queue_id;
    bit<8>  drop_reason;
    bit<16> pad;
}
const bit<8> DROP_REPORT_HEADER_LEN = 12;


struct headers {

    // Original Packet Headers
    ethernet_t                  ethernet;
    ipv4_t			            ipv4;
    udp_t			            udp;
    tcp_t			            tcp;

    // INT Report Encapsulation
    ethernet_t                  report_ethernet;
    ipv4_t                      report_ipv4;
    udp_t                       report_udp;

    // INT Headers
    intl4_shim_t                intl4_shim;
    int_header_t                int_header;

    //INT Metadata
    int_switch_id_t             int_switch_id;
    int_level1_port_ids_t       int_level1_port_ids;
    int_hop_latency_t           int_hop_latency;
    int_q_occupancy_t           int_q_occupancy;
    int_ingress_tstamp_t        int_ingress_tstamp;
    int_egress_tstamp_t         int_egress_tstamp;
    int_level2_port_ids_t       int_level2_port_ids;
    int_egress_port_tx_util_t   int_egress_tx_util;
    int_data_t                  int_data;

    //used for encryption
    padding_t                   padding;

    //store permutation
    permutation_t               p;
    permutation_t               inverse_p;

    //encryption key
    encryption_key_t            encryption_key;

    // data to be encrypted
    EM_value_t                  plaintext_1;
    EM_value_t                  plaintext_2;
    EM_value_t                  plaintext_3;

    // encrypted data
    EM_value_t                  ciphertext_1;
    EM_value_t                  ciphertext_2;
    EM_value_t                  ciphertext_3;

    //SipHash
    siphash_state_t             siphash_internal_state;
    siphash_constant_t          siphash_initial_value;
    siphash_key_t               siphash_key;

    //checksum
    int_integrity_checksum_t    int_integrity_checksum;

    //INT Report Headers
    report_group_header_t       report_group_header;
    report_individual_header_t  report_individual_header;
    drop_report_header_t        drop_report_header;
}

const bit<8> CLONE_FL_1  = 1;

struct preserving_metadata_t {
    @field_list(CLONE_FL_1)
    bit<9> ingress_port;
    bit<9> egress_spec;
    @field_list(CLONE_FL_1)
    bit<9> egress_port;
    bit<32> clone_spec;
    bit<32> instance_type;
    bit<1> drop;
    bit<16> recirculate_port;
    bit<32> packet_length;
    bit<32> enq_timestamp;
    bit<19> enq_qdepth;
    bit<32> deq_timedelta;
    @field_list(CLONE_FL_1)
    bit<19> deq_qdepth;
    @field_list(CLONE_FL_1)
    bit<48> ingress_global_timestamp;
    bit<48> egress_global_timestamp;
    bit<32> lf_field_list;
    bit<16> mcast_grp;
    bit<32> resubmit_flag;
    bit<16> egress_rid;
    bit<1> checksum_error;
    bit<32> recirculate_flag;
}

struct int_metadata_t {
    switch_id_t switch_id;
    bit<16> new_bytes;
    bit<8>  new_words;
    bool  source;
    bool  sink;
    bool  transit;
    bool  exceed_mtu;
    bit<8> intl4_shim_len;
    bit<16> int_shim_len;
}

struct local_metadata_t {
    bit<16>       l4_src_port;
    bit<16>       l4_dst_port;
    int_metadata_t int_meta;
    preserving_metadata_t perserv_meta;
}

#endif
