/* -*- P4_16 -*- */
#include <core.p4>
#include <v1model.p4>
#include "include/defines.p4"
#include "include/headers.p4"
#include "include/int_headers.p4"
#include "include/parser.p4"
#include "include/checksum.p4"
#include "include/forward.p4"
#include "include/int_source.p4"
#include "include/int_transit.p4"
#include "include/int_sink.p4"
#include "include/checkMTU.p4"
#include "include/encrypt.p4"
#include "include/SipHash.p4"

/*************************************************************************
****************  I N G R E S S   P R O C E S S I N G   ******************
*************************************************************************/

control MyIngress(inout headers hdr,
                  inout local_metadata_t local_metadata,
                  inout standard_metadata_t standard_metadata) {


    apply {
        if(hdr.ipv4.isValid()) {
            l3_forward.apply(hdr, local_metadata, standard_metadata);

            if(hdr.udp.isValid() || hdr.tcp.isValid()) {
                process_int_source_sink.apply(hdr, local_metadata, standard_metadata);
                // set INT source and int_sink

                process_check_mtu.apply(hdr, local_metadata, standard_metadata);
                // check whether the packet length will exceed MTU after inserting INT metadata (and header)

            }

            if (local_metadata.int_meta.source == true && local_metadata.int_meta.exceed_mtu != true) {
                // the current switch is INT source and the packet length is not long

                process_int_source.apply(hdr, local_metadata);
                // initialize INT packet
            }

            if ((local_metadata.int_meta.exceed_mtu == true || local_metadata.int_meta.sink == true) && hdr.int_header.isValid()) {
                // exceed MTU or the current switch is INT sink

                // clone packet for Telemetry Report
                // clone3(CloneType.I2E, REPORT_MIRROR_SESSION_ID,standard_metadata);
                // clone(CloneType.I2E, REPORT_MIRROR_SESSION_ID);
                local_metadata.perserv_meta.ingress_port = standard_metadata.ingress_port;
                local_metadata.perserv_meta.egress_port = standard_metadata.egress_port;
                local_metadata.perserv_meta.deq_qdepth = standard_metadata.deq_qdepth;
                local_metadata.perserv_meta.ingress_global_timestamp = standard_metadata.ingress_global_timestamp;
                clone_preserving_field_list(CloneType.I2E, REPORT_MIRROR_SESSION_ID, CLONE_FL_1);
            }
        }
    }
}

/*************************************************************************
****************  E G R E S S   P R O C E S S I N G   *******************
*************************************************************************/


control MyEgress(inout headers hdr,
                 inout local_metadata_t local_metadata,
                 inout standard_metadata_t standard_metadata) {

    apply {
        if (hdr.int_header.isValid()) {
            if(standard_metadata.instance_type == PKT_INSTANCE_TYPE_INGRESS_CLONE) {
                standard_metadata.ingress_port = local_metadata.perserv_meta.ingress_port;
                standard_metadata.egress_port = local_metadata.perserv_meta.egress_port;
                standard_metadata.deq_qdepth = local_metadata.perserv_meta.deq_qdepth;
                standard_metadata.ingress_global_timestamp = local_metadata.perserv_meta.ingress_global_timestamp;

                process_check_mtu_egress.apply(hdr, local_metadata, standard_metadata);
            }
            if (local_metadata.int_meta.exceed_mtu == true && standard_metadata.instance_type != PKT_INSTANCE_TYPE_INGRESS_CLONE) {
                // the current packet is a normal INT packet whose length is long

                process_clean_int_metadata.apply(hdr, local_metadata, standard_metadata);
                // clean existing INT metadata
            }
            if (local_metadata.int_meta.exceed_mtu != true || standard_metadata.instance_type != PKT_INSTANCE_TYPE_INGRESS_CLONE) {
                // the current packet is a normal INT packet whose length is NOT long

                process_int_transit.apply(hdr, local_metadata, standard_metadata);
                // insert INT metadata

                process_encrypt.apply(hdr, local_metadata, standard_metadata);
                // encrypt (or decrypt, which is disabled by default)

                process_SipHash_1_3.apply(hdr, local_metadata, standard_metadata);
                // generate hash
            }
            if (standard_metadata.instance_type == PKT_INSTANCE_TYPE_INGRESS_CLONE) {
                process_int_report.apply(hdr, local_metadata, standard_metadata);
                // generate INT report
            }
            if (local_metadata.int_meta.sink == true && standard_metadata.instance_type != PKT_INSTANCE_TYPE_INGRESS_CLONE) {
                process_int_sink.apply(hdr, local_metadata, standard_metadata);
                // remove INT header and metadata
            }
        }
    }
}

/*************************************************************************
***********************  S W I T C H  *******************************
*************************************************************************/

V1Switch(
    MyParser(),
    MyVerifyChecksum(),
    MyIngress(),
    MyEgress(),
    MyComputeChecksum(),
    MyDeparser()
) main;
