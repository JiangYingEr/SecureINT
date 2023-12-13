#include "defines.p4"
#include "headers.p4"

control process_SipHash_1_3(
    inout headers hdr,
    inout local_metadata_t local_metadata,
    inout standard_metadata_t standard_metadata) {

    action SipHash_initialization() {
        hdr.siphash_internal_state.setValid();
        hdr.siphash_internal_state.v0 = hdr.siphash_key.key_0 ^ hdr.siphash_initial_value.i0;
        hdr.siphash_internal_state.v1 = hdr.siphash_key.key_1 ^ hdr.siphash_initial_value.i1;
        hdr.siphash_internal_state.v2 = hdr.siphash_key.key_0 ^ hdr.siphash_initial_value.i2;
        hdr.siphash_internal_state.v3 = hdr.siphash_key.key_1 ^ hdr.siphash_initial_value.i3;
    }

    action SipRound() {
        hdr.siphash_internal_state.v0 = hdr.siphash_internal_state.v0 + hdr.siphash_internal_state.v1;
        hdr.siphash_internal_state.v1 = hdr.siphash_internal_state.v1[50:0] ++ hdr.siphash_internal_state.v1[63:51];
        hdr.siphash_internal_state.v1 = hdr.siphash_internal_state.v1 ^ hdr.siphash_internal_state.v0;
        hdr.siphash_internal_state.v0 = hdr.siphash_internal_state.v0[31:0] ++ hdr.siphash_internal_state.v0[63:32];
        hdr.siphash_internal_state.v2 = hdr.siphash_internal_state.v3 + hdr.siphash_internal_state.v2;

        hdr.siphash_internal_state.v3 = hdr.siphash_internal_state.v3[47:0] ++ hdr.siphash_internal_state.v3[63:48];
        hdr.siphash_internal_state.v3 = hdr.siphash_internal_state.v3 ^ hdr.siphash_internal_state.v2;
        hdr.siphash_internal_state.v0 = hdr.siphash_internal_state.v0 + hdr.siphash_internal_state.v3;
        hdr.siphash_internal_state.v3 = hdr.siphash_internal_state.v3[42:0] ++ hdr.siphash_internal_state.v3[63:43];
        hdr.siphash_internal_state.v3 = hdr.siphash_internal_state.v3 ^ hdr.siphash_internal_state.v0;

        hdr.siphash_internal_state.v2 = hdr.siphash_internal_state.v2 + hdr.siphash_internal_state.v1;
        hdr.siphash_internal_state.v1 = hdr.siphash_internal_state.v1[46:0] ++ hdr.siphash_internal_state.v1[63:47];
        hdr.siphash_internal_state.v1 = hdr.siphash_internal_state.v1 ^ hdr.siphash_internal_state.v2;
        hdr.siphash_internal_state.v2 = hdr.siphash_internal_state.v2[31:0] ++ hdr.siphash_internal_state.v2[63:32];
    }

    action read_SipRound_keys(bit<64> key_0, bit<64> key_1, bit<64> i_0, bit<64> i_1, bit<64> i_2, bit<64> i_3) {
        hdr.siphash_key.setValid();
        hdr.siphash_key.key_0 = key_0;
        hdr.siphash_key.key_1 = key_1;

        hdr.siphash_initial_value.setValid();
        hdr.siphash_initial_value.i0 = i_0;
        hdr.siphash_initial_value.i1 = i_1;
        hdr.siphash_initial_value.i2 = i_2;
        hdr.siphash_initial_value.i3 = i_3;
    }

    action conjunct_plaintext (){

        hdr.plaintext_1.setValid();
        hdr.plaintext_1.value[127:96]   =    hdr.int_switch_id.switch_id;
        hdr.plaintext_1.value[95:80]    =    hdr.int_level1_port_ids.ingress_port_id;
        hdr.plaintext_1.value[79:64]    =    hdr.int_level1_port_ids.egress_port_id;
        hdr.plaintext_1.value[63:32]    =    hdr.int_hop_latency.hop_latency;
        hdr.plaintext_1.value[31:24]    =    hdr.int_q_occupancy.q_id;
        hdr.plaintext_1.value[23:0]     =    hdr.int_q_occupancy.q_occupancy;

        hdr.plaintext_2.setValid();
        hdr.plaintext_2.value[127:64]   =    hdr.int_ingress_tstamp.ingress_tstamp;
        hdr.plaintext_2.value[63:32]    =    hdr.int_level2_port_ids.ingress_port_id;
        hdr.plaintext_2.value[31:0]     =    hdr.int_egress_tx_util.egress_port_tx_util;

        hdr.plaintext_3.setValid();
        hdr.plaintext_3.value[127:64]   =    hdr.int_egress_tstamp.egress_tstamp;
        hdr.plaintext_3.value[63:32]    =    hdr.int_level2_port_ids.egress_port_id;
        hdr.plaintext_3.value[31:0]     =    hdr.padding.padding;

    }

    table tb_read_SipRound_keys {
        key = {
            local_metadata.int_meta.switch_id : exact;
        }
        actions = {
            read_SipRound_keys();
            NoAction();
        }
        default_action = NoAction();
    }

    apply {
        tb_read_SipRound_keys.apply();
        if (hdr.siphash_key.isValid()) {
            SipHash_initialization();
            //hdr.padding.padding = 0x66666666;

            if (hdr.plaintext_1.isValid() == false) {
                conjunct_plaintext();
            }

            //c round
            hdr.siphash_internal_state.v3 = hdr.siphash_internal_state.v3 ^ hdr.plaintext_1.value[127:64];
            SipRound();
            hdr.siphash_internal_state.v0 = hdr.siphash_internal_state.v0 ^ hdr.plaintext_1.value[127:64];

            hdr.siphash_internal_state.v3 = hdr.siphash_internal_state.v3 ^ hdr.plaintext_1.value[63:0];
            SipRound();
            hdr.siphash_internal_state.v0 = hdr.siphash_internal_state.v0 ^ hdr.plaintext_1.value[63:0];

            hdr.siphash_internal_state.v3 = hdr.siphash_internal_state.v3 ^ hdr.plaintext_2.value[127:64];
            SipRound();
            hdr.siphash_internal_state.v0 = hdr.siphash_internal_state.v0 ^ hdr.plaintext_2.value[127:64];

            hdr.siphash_internal_state.v3 = hdr.siphash_internal_state.v3 ^ hdr.plaintext_2.value[63:0];
            SipRound();
            hdr.siphash_internal_state.v0 = hdr.siphash_internal_state.v0 ^ hdr.plaintext_2.value[63:0];

            hdr.siphash_internal_state.v3 = hdr.siphash_internal_state.v3 ^ hdr.plaintext_3.value[127:64];
            SipRound();
            hdr.siphash_internal_state.v0 = hdr.siphash_internal_state.v0 ^ hdr.plaintext_3.value[127:64];

            hdr.siphash_internal_state.v3 = hdr.siphash_internal_state.v3 ^ hdr.plaintext_3.value[63:0];
            SipRound();
            hdr.siphash_internal_state.v0 = hdr.siphash_internal_state.v0 ^ hdr.plaintext_3.value[63:0];

            //d round
            hdr.siphash_internal_state.v2 = hdr.siphash_internal_state.v2 ^ 0xff;
            SipRound();
            SipRound();
            SipRound();


            hdr.int_integrity_checksum.int_integrity_checksum = hdr.siphash_internal_state.v0 ^ hdr.siphash_internal_state.v1 ^ hdr.siphash_internal_state.v2 ^ hdr.siphash_internal_state.v3;



        }

    }
}
