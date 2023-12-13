#include <core.p4>
#if __TARGET_TOFINO__ == 2
#include <t2na.p4>
#else
#include <tna.p4>
#endif

#include "headers.p4"
#include "util.p4"
#include "parser.p4"
#define ETHERTYPE_TO_CPU 0xBF01
#define ETHERTYPE_TO_CPU 0xBF01
    
const PortId_t CPU_PORT = 192; // tofino with pipeline 2
// const PortId_t CPU_PORT = 320; // tofino with pipeline 4


control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

action ap0() {
hdr.c0.pos0= hdr.data.data[0:0];
}
action ap1() {
hdr.c0.pos1= hdr.data.data[1:1];
}
action ap2() {
hdr.c0.pos2= hdr.data.data[2:2];
}
action ap3() {
hdr.c0.pos3= hdr.data.data[3:3];
}
action ap4() {
hdr.c0.pos4= hdr.data.data[4:4];
}
action ap5() {
hdr.c0.pos5= hdr.data.data[5:5];
}
action ap6() {
hdr.c0.pos6= hdr.data.data[6:6];
}
action ap7() {
hdr.c0.pos7= hdr.data.data[7:7];
}
action ap8() {
hdr.c1.pos0= hdr.data.data[8:8];
}
action ap9() {
hdr.c1.pos1= hdr.data.data[9:9];
}
action ap10() {
hdr.c1.pos2= hdr.data.data[10:10];
}
action ap11() {
hdr.c1.pos3= hdr.data.data[11:11];
}
action ap12() {
hdr.c1.pos4= hdr.data.data[12:12];
}
action ap13() {
hdr.c1.pos5= hdr.data.data[13:13];
}
action ap14() {
hdr.c1.pos6= hdr.data.data[14:14];
}
action ap15() {
hdr.c1.pos7= hdr.data.data[15:15];
}
action ap16() {
hdr.c2.pos0= hdr.data.data[16:16];
}
action ap17() {
hdr.c2.pos1= hdr.data.data[17:17];
}
action ap18() {
hdr.c2.pos2= hdr.data.data[18:18];
}
action ap19() {
hdr.c2.pos3= hdr.data.data[19:19];
}
action ap20() {
hdr.c2.pos4= hdr.data.data[20:20];
}
action ap21() {
hdr.c2.pos5= hdr.data.data[21:21];
}
action ap22() {
hdr.c2.pos6= hdr.data.data[22:22];
}
action ap23() {
hdr.c2.pos7= hdr.data.data[23:23];
}
action ap24() {
hdr.c3.pos0= hdr.data.data[24:24];
}
action ap25() {
hdr.c3.pos1= hdr.data.data[25:25];
}
action ap26() {
hdr.c3.pos2= hdr.data.data[26:26];
}
action ap27() {
hdr.c3.pos3= hdr.data.data[27:27];
}
action ap28() {
hdr.c3.pos4= hdr.data.data[28:28];
}
action ap29() {
hdr.c3.pos5= hdr.data.data[29:29];
}
action ap30() {
hdr.c3.pos6= hdr.data.data[30:30];
}
action ap31() {
hdr.c3.pos7= hdr.data.data[31:31];
}

    /*
    //newversion
    action SipRound_1() {
        hdr.siphash_a.v0 = hdr.siphash_internal_state.v0 + hdr.siphash_internal_state.v1;
        hdr.siphash_a.v1 = hdr.siphash_internal_state.v1[26:0] ++ hdr.siphash_internal_state.v1[31:27];
        
        hdr.siphash_a.v2 = hdr.siphash_internal_state.v3 + hdr.siphash_internal_state.v2;
        hdr.siphash_a.v3 = hdr.siphash_internal_state.v3[23:0] ++ hdr.siphash_internal_state.v3[31:24];
    }
    

    //newversion
    action SipRound_2() {
        hdr.siphash_internal_state.v0 = hdr.siphash_a.v0[15:0] ++ hdr.siphash_a.v0[31:16];
        hdr.siphash_internal_state.v1 = hdr.siphash_a.v0 ^ hdr.siphash_a.v1;
        hdr.siphash_internal_state.v2 = hdr.siphash_a.v2;
        hdr.siphash_internal_state.v3 = hdr.siphash_a.v2 ^ hdr.siphash_a.v3;
    }

    //newversion
    action SipRound_3() {
        hdr.siphash_a.v0 = hdr.siphash_internal_state.v2 + hdr.siphash_internal_state.v1;
        hdr.siphash_a.v1 = hdr.siphash_internal_state.v1[18:0] ++ hdr.siphash_internal_state.v1[31:19];
        hdr.siphash_a.v2 = hdr.siphash_internal_state.v0 + hdr.siphash_internal_state.v3;
        hdr.siphash_a.v3 = hdr.siphash_internal_state.v3[24:0] ++ hdr.siphash_internal_state.v3[31:25];
    }


    //newversion
    action SipRound_4() {
        hdr.siphash_internal_state.v0 = hdr.siphash_a.v2 ^ hdr.data.data;
        hdr.siphash_internal_state.v1 = hdr.siphash_a.v0 ^ hdr.siphash_a.v1;
        hdr.siphash_internal_state.v2 = hdr.siphash_a.v0[15:0] ++ hdr.siphash_a.v0[31:16];
        hdr.siphash_internal_state.v3 = hdr.siphash_a.v2 ^ hdr.siphash_a.v3;
        
    }
    

    action read_SipRound_keys(bit<32> i_0, bit<32> i_1, bit<32> i_2, bit<32> i_3) {
        hdr.siphash_internal_state.setValid();
        hdr.siphash_internal_state.v0 = i_0;
        hdr.siphash_internal_state.v1 = i_1;
        hdr.siphash_internal_state.v2 = i_2;
        hdr.siphash_internal_state.v3 = i_3;
    }

    bit<32> t1;
    bit<32> t2;
    
    action xor_1(){
	    t1 = hdr.siphash_internal_state.v0 ^ hdr.siphash_internal_state.v1;
        t2 = hdr.siphash_internal_state.v2 ^ hdr.siphash_internal_state.v3;
	}

    action xor_res(){
	    hdr.integrity_checksum.integrity_checksum = t1^t2;
	}

    table tb_read_SipRound_keys {
        key = {
           //metadata.int_meta.switch_id : exact;
        }
        actions = {
            read_SipRound_keys();
        }
    }
    */

    action read_permutation (bit<32> k) {
        hdr.encryption_key.setValid();
        hdr.encryption_key.k = k;
    }



    table tb_read_permutation {
        key = {
            //hdr.int_switch_id.switch_id : exact;
        }
        actions = {
            read_permutation();
            NoAction();
        }
        default_action = NoAction();
    }

    apply {
	

		//tb_read_SipRound_keys.apply();
        //tb_read_permutation.apply();

        //hdr.data.data = hdr.data.data ^ hdr.encryption_key.k;

        ap0();
ap1();
ap2();
ap3();
ap4();
ap5();
ap6();
ap7();
ap8();
ap9();
ap10();
ap11();
ap12();
ap13();
ap14();
ap15();
ap16();
ap17();
ap18();
ap19();
ap20();
ap21();
ap22();
ap23();
ap24();
ap25();
ap26();
ap27();
ap28();
ap29();
ap30();
ap31();
        
        //p1();



        //c round
        //hdr.siphash_internal_state.v3 = hdr.siphash_internal_state.v3 ^ hdr.data.data;
        //SipRound_1();
        //SipRound_2();
        //SipRound_3();
        //SipRound_4();
	    
        //This procedure is added to SipRound_4 to reduce stages used.
        //hdr.siphash_internal_state.v0 = hdr.siphash_internal_state.v0 ^ hdr.data.data;

        //d round
        /*
        hdr.siphash_internal_state.v2 = hdr.siphash_internal_state.v2 ^ 0xff;
	    SipRound_1();
        SipRound_2();
        SipRound_3();
        SipRound_4();
        */



	    //xor_1();
        //xor_res();

        
       }
    
}


    /********  G L O B A L   E G R E S S   M E T A D A T A  *********/




control SwitchEgress(
        inout header_t hdr,
        inout metadata_t eg_md,
        in egress_intrinsic_metadata_t eg_intr_md,
        in egress_intrinsic_metadata_from_parser_t eg_intr_md_from_prsr,
        inout egress_intrinsic_metadata_for_deparser_t ig_intr_dprs_md,
        inout egress_intrinsic_metadata_for_output_port_t eg_intr_oport_md) {
    

    apply {
        
       }
}

control EgressDeparser(packet_out pkt,
    /* User */
    inout header_t hdr,
        in metadata_t eg_md,
    /* Intrinsic */
    in    egress_intrinsic_metadata_for_deparser_t  eg_dprsr_md)
{
    apply {
        pkt.emit(hdr.ethernet);
        
    }
}

Pipeline(
    SwitchIngressParser(),
    SwitchIngress(),
    SwitchIngressDeparser(),
    EgressParser(),
    SwitchEgress(),
    EgressDeparser()
) pipe;

Switch(pipe) main;

