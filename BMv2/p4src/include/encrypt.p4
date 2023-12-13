#include "defines.p4"
#include "headers.p4"

control process_encrypt(
    inout headers hdr,
    inout local_metadata_t local_metadata,
    inout standard_metadata_t standard_metadata) {

    action encrypt_int_metadata (
        bit<32> int_switch_id_key,
        bit<16> int_level1_port_ids_key,
        bit<32> int_port_ids_key,
        bit<32> int_hop_latency_key,
        bit<8>  int_q_occupancy_key_1,
        bit<24> int_q_occupancy_key_2,
        bit<64> int_timestamp_key,
        bit<32> int_egress_tx_util_key){

        // encrypt switch id
        hdr.int_switch_id.switch_id = hdr.int_switch_id.switch_id ^ int_switch_id_key;

        //level1_port_id
        hdr.int_level1_port_ids.ingress_port_id = hdr.int_level1_port_ids.ingress_port_id ^ int_level1_port_ids_key;
        hdr.int_level1_port_ids.egress_port_id = hdr.int_level1_port_ids.egress_port_id ^ int_level1_port_ids_key;

        //level2_port_id
        hdr.int_level2_port_ids.ingress_port_id = hdr.int_level2_port_ids.ingress_port_id ^ int_port_ids_key;
        hdr.int_level2_port_ids.egress_port_id = hdr.int_level2_port_ids.egress_port_id ^ int_port_ids_key;

        // hop latency
        hdr.int_hop_latency.hop_latency = hdr.int_hop_latency.hop_latency ^ int_hop_latency_key;

        //q_occupancy
        hdr.int_q_occupancy.q_id = hdr.int_q_occupancy.q_id ^ int_q_occupancy_key_1;
        hdr.int_q_occupancy.q_occupancy = hdr.int_q_occupancy.q_occupancy ^ int_q_occupancy_key_2;

        //timestamp
        hdr.int_ingress_tstamp.ingress_tstamp = hdr.int_ingress_tstamp.ingress_tstamp ^ int_timestamp_key;
        hdr.int_egress_tstamp.egress_tstamp = hdr.int_egress_tstamp.egress_tstamp ^ int_timestamp_key;

        hdr.int_egress_tx_util.egress_port_tx_util = hdr.int_egress_tx_util.egress_port_tx_util ^ int_egress_tx_util_key;

        }

    table tb_encrypt {
        key = {
            hdr.int_switch_id.switch_id : exact;
        }
        actions = {
            encrypt_int_metadata;
            NoAction();
        }
        default_action = NoAction();
    }

    apply{
        tb_encrypt.apply();
    }

}
