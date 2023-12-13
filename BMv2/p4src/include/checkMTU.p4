/* -*- P4_16 -*- */
control process_check_mtu (
    inout headers hdr,
    inout local_metadata_t local_metadata,
    inout standard_metadata_t standard_metadata) {

    action set_int_exceed_mtu (bit<16> mtu) {
        if (local_metadata.int_meta.source == true) {
            if ((standard_metadata.packet_length + (bit<32>)INT_TOTAL_HEADER_SIZE + (bit<32>)INT_PER_HOP_METADATA_SIZE) >= (bit<32>)mtu) {
                local_metadata.int_meta.exceed_mtu = true;
                //local_metadata.int_meta.source = false;
            }
        }
        else if ((standard_metadata.packet_length + (bit<32>)INT_PER_HOP_METADATA_SIZE) >= (bit<32>)mtu) {
            local_metadata.int_meta.exceed_mtu = true;
            //local_metadata.int_meta.sink = true;
        }
    }

    table tb_set_int_exceed_mtu {
        actions = {
            set_int_exceed_mtu;
            NoAction;
        }
        default_action = NoAction();
        size = 1;
    }

    apply {
        tb_set_int_exceed_mtu.apply();
    }
  }

control process_check_mtu_egress (
      inout headers hdr,
      inout local_metadata_t local_metadata,
      inout standard_metadata_t standard_metadata) {

      action set_int_exceed_mtu_egress (bit<16> mtu) {
          if (local_metadata.int_meta.source == true) {
              if ((standard_metadata.packet_length + (bit<32>)INT_TOTAL_HEADER_SIZE + (bit<32>)INT_PER_HOP_METADATA_SIZE) >= (bit<32>)mtu) {
                  local_metadata.int_meta.exceed_mtu = true;
                  //local_metadata.int_meta.source = false;
              }
          }
          else if ((standard_metadata.packet_length + (bit<32>)INT_PER_HOP_METADATA_SIZE) >= (bit<32>)mtu) {
              local_metadata.int_meta.exceed_mtu = true;
              //local_metadata.int_meta.sink = true;
          }
      }

      table tb_set_int_exceed_mtu_egress {
          actions = {
              set_int_exceed_mtu_egress;
              NoAction;
          }
          default_action = NoAction();
          size = 1;
      }

      apply {
          tb_set_int_exceed_mtu_egress.apply();
      }
}

control process_clean_int_metadata (
    inout headers hdr,
    inout local_metadata_t local_metadata,
    inout standard_metadata_t standard_metadata) {

    action clean_int_metadata () {
        bit<16> len_bytes = (((bit<16>)hdr.intl4_shim.len) << 2) - INT_HEADER_SIZE;
        hdr.intl4_shim.len = hdr.intl4_shim.len - (bit<8>)(len_bytes >> 2);
        hdr.ipv4.len = hdr.ipv4.len - len_bytes;
        if (hdr.udp.isValid()) {
            hdr.udp.length_ = hdr.udp.length_ - len_bytes;
        }

        hdr.int_switch_id.setInvalid();
        hdr.int_level1_port_ids.setInvalid();
        hdr.int_hop_latency.setInvalid();
        hdr.int_q_occupancy.setInvalid();
        hdr.int_ingress_tstamp.setInvalid();
        hdr.int_egress_tstamp.setInvalid();
        hdr.int_level2_port_ids.setInvalid();
        hdr.int_egress_tx_util.setInvalid();
        hdr.int_data.setInvalid();
    }

    table tb_clean_int_metadata {
        actions = {
            clean_int_metadata;
        }
        default_action = clean_int_metadata();
    }
    apply {
        tb_clean_int_metadata.apply();
    }
  }
