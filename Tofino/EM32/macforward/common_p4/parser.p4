parser SwitchIngressParser(
        packet_in pkt,
        out header_t hdr,
        out metadata_t ig_md,
        out ingress_intrinsic_metadata_t ig_intr_md) {

    TofinoIngressParser() tofino_parser;

    state start {
        tofino_parser.apply(pkt, ig_intr_md);
        transition parse_ethernet;
    }

    state parse_ethernet {
        pkt.extract(hdr.ethernet);
        transition parse_data;

    }


     state parse_data {
        pkt.extract(hdr.plaintext);
        transition  accept;
     }
}

control SwitchIngressDeparser(packet_out pkt,
                              inout header_t hdr,
                              in metadata_t ig_md,
                              in ingress_intrinsic_metadata_for_deparser_t 
                                ig_intr_dprsr_md
                              ) {

    apply {
        pkt.emit(hdr.ethernet);
        pkt.emit(hdr.ciphertext);
    }
}


parser EgressParser(packet_in        pkt,
    /* User */
    out header_t          hdr,
    out metadata_t         eg_md,
    /* Intrinsic */
    out egress_intrinsic_metadata_t  eg_intr_md)
{
    /* This is a mandatory state, required by Tofino Architecture */

    state start {
        //pkt.extract(eg_intr_md);
        transition parse_ethernet;
    }

    state parse_ethernet {
        pkt.extract(hdr.ethernet);
        transition parse_data;
    }

    state parse_data {
        pkt.extract(hdr.data);
        transition  accept;
    }
/*
    state parser_dp0 {
        pkt.extract(hdr.dp_0);
        transition parse_dp1;}
    state parser_dp1 {
        pkt.extract(hdr.dp_1);
        transition parse_dp2;}
    state parser_dp2 {
        pkt.extract(hdr.dp_2);
        transition parse_dp3;}
    state parser_dp3 {
        pkt.extract(hdr.dp_3);
        transition parse_dp4;}
    state parser_dp4 {
        pkt.extract(hdr.dp_4);
        transition parse_dp5;}
    state parser_dp5 {
        pkt.extract(hdr.dp_5);
        transition parse_dp6;}
    state parser_dp6 {
        pkt.extract(hdr.dp_6);
        transition parse_dp7;}
    state parser_dp7 {
        pkt.extract(hdr.dp_7);
        transition parse_dp8;}
    state parser_dp8 {
        pkt.extract(hdr.dp_8);
        transition parse_dp9;}
    state parser_dp9 {
        pkt.extract(hdr.dp_9);
        transition parse_dp10;}
    state parser_dp10 {
        pkt.extract(hdr.dp_10);
        transition parse_dp11;}
    state parser_dp11 {
        pkt.extract(hdr.dp_11);
        transition parse_dp12;}
    state parser_dp12 {
        pkt.extract(hdr.dp_12);
        transition parse_dp13;}
    state parser_dp13 {
        pkt.extract(hdr.dp_13);
        transition parse_dp14;}
    state parser_dp14 {
        pkt.extract(hdr.dp_14);
        transition parse_dp15;}
    state parser_dp15 {
        pkt.extract(hdr.dp_15);
        transition parse_dp16;}
    state parser_dp16 {
        pkt.extract(hdr.dp_16);
        transition parse_dp17;}
    state parser_dp17 {
        pkt.extract(hdr.dp_17);
        transition parse_dp18;}
    state parser_dp18 {
        pkt.extract(hdr.dp_18);
        transition parse_dp19;}
    state parser_dp19 {
        pkt.extract(hdr.dp_19);
        transition parse_dp20;}
    state parser_dp20 {
        pkt.extract(hdr.dp_20);
        transition parse_dp21;}
    state parser_dp21 {
        pkt.extract(hdr.dp_21);
        transition parse_dp22;}
    state parser_dp22 {
        pkt.extract(hdr.dp_22);
        transition parse_dp23;}
    state parser_dp23 {
        pkt.extract(hdr.dp_23);
        transition parse_dp24;}
    state parser_dp24 {
        pkt.extract(hdr.dp_24);
        transition parse_dp25;}
    state parser_dp25 {
        pkt.extract(hdr.dp_25);
        transition parse_dp26;}
    state parser_dp26 {
        pkt.extract(hdr.dp_26);
        transition parse_dp27;}
    state parser_dp27 {
        pkt.extract(hdr.dp_27);
        transition parse_dp28;}
    state parser_dp28 {
        pkt.extract(hdr.dp_28);
        transition parse_dp29;}
    state parser_dp29 {
        pkt.extract(hdr.dp_29);
        transition parse_dp30;}
    state parser_dp30 {
        pkt.extract(hdr.dp_30);
        transition parse_dp31;}
    state parser_dp31 {
        pkt.extract(hdr.dp_31);
        transition accept;}
*/
}