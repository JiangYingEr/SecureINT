#include <core.p4>
#if __TARGET_TOFINO__ == 2
#include <t2na.p4>
#else
#include <tna.p4>
#endif

#include "common_p4/headers.p4"
#include "common_p4/util.p4"
#include "common_p4/parser.p4"
#define ETHERTYPE_TO_CPU 0xBF01
#define ETHERTYPE_TO_CPU 0xBF01

typedef bit<9>  egressSpec_t;
typedef bit<48> macAddr_t;
    
const PortId_t CPU_PORT = 192; // tofino with pipeline 2
// const PortId_t CPU_PORT = 320; // tofino with pipeline 4

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
        transition select(hdr.ethernet.ether_type) {
            ETHERTYPE_IPV4: parse_ipv4;
            default: accept;
        }
    }

    state parse_ipv4 {
        pkt.extract(hdr.ipv4);
        transition accept;
    }
    /*
    state parse_data {
        pkt.extract(hdr.plaintext);
        transition  accept;
    }
    */
}

control SwitchIngress(
        inout header_t hdr,
        inout metadata_t ig_md,
        in ingress_intrinsic_metadata_t ig_intr_md,
        in ingress_intrinsic_metadata_from_parser_t ig_prsr_md,
        inout ingress_intrinsic_metadata_for_deparser_t ig_dprsr_md,
        inout ingress_intrinsic_metadata_for_tm_t ig_tm_md) {

        action drop() {
            ig_dprsr_md.drop_ctl = 0x001;
        }

        action init_data(){
            hdr.data1.setValid();
            hdr.data1.data = 0x123;
        }

        table tb_init_data {
            key = {}
            actions = {
                init_data;
            }
        }

        action port_forward(egressSpec_t out_port){
            ig_tm_md.ucast_egress_port = out_port;
            //hdr.ethernet.src_addr = src_mac;
            //hdr.ethernet.dst_addr = dst_mac;
            
        }

        table tb_port_forward {
            key = {
                ig_intr_md.ingress_port : exact;
            }
            actions = {
                port_forward;
            }
        }


        apply{
           // tb_port_forward.apply();
            
            
            if (ig_intr_md.ingress_port == 56) {
                ig_tm_md.ucast_egress_port = 4;
                tb_init_data.apply();
            }
            else {
                ig_tm_md.ucast_egress_port = 56;
            }

            
        }
    
}


control SwitchIngressDeparser(packet_out pkt,
                              inout header_t hdr,
                              in metadata_t ig_md,
                              in ingress_intrinsic_metadata_for_deparser_t 
                                ig_intr_dprsr_md
                              ) {

    apply {
        pkt.emit(hdr);
    }
}

/********  G L O B A L   E G R E S S   M E T A D A T A  *********/

parser EgressParser(packet_in        pkt,
    /* User */
    out header_t          hdr,
    out metadata_t         eg_md,
    /* Intrinsic */
    out egress_intrinsic_metadata_t  eg_intr_md)
{
    /* This is a mandatory state, required by Tofino Architecture */

    state start {
        pkt.extract(eg_intr_md);
        transition parse_ethernet;
    }

    state parse_ethernet {
        pkt.extract(hdr.ethernet);
        transition select(hdr.ethernet.ether_type) {
            ETHERTYPE_IPV4: parse_ipv4;
            default: accept;
        }
    }

    state parse_ipv4 {
        pkt.extract(hdr.ipv4);
        transition parse_data;
    }
    
    state parse_data {
        pkt.extract(hdr.data1);
        transition  accept;
    }
    

}


control SwitchEgress(
        inout header_t hdr,
        inout metadata_t eg_md,
        in egress_intrinsic_metadata_t eg_intr_md,
        in egress_intrinsic_metadata_from_parser_t eg_intr_md_from_prsr,
        inout egress_intrinsic_metadata_for_deparser_t ig_intr_dprs_md,
        inout egress_intrinsic_metadata_for_output_port_t eg_intr_oport_md) {
    
    

    action ap0() {
    hdr.c0.pos0= hdr.data1.data[0:0];
    }
    action ap1() {
    hdr.c0.pos1= hdr.data1.data[1:1];
    }
    action ap2() {
    hdr.c0.pos2= hdr.data1.data[2:2];
    }
    action ap3() {
    hdr.c0.pos3= hdr.data1.data[3:3];
    }
    action ap4() {
    hdr.c0.pos4= hdr.data1.data[4:4];
    }
    action ap5() {
    hdr.c0.pos5= hdr.data1.data[5:5];
    }
    action ap6() {
    hdr.c0.pos6= hdr.data1.data[6:6];
    }
    action ap7() {
    hdr.c0.pos7= hdr.data1.data[7:7];
    }
    action ap8() {
    hdr.c1.pos0= hdr.data1.data[8:8];
    }
    action ap9() {
    hdr.c1.pos1= hdr.data1.data[9:9];
    }
    action ap10() {
    hdr.c1.pos2= hdr.data1.data[10:10];
    }
    action ap11() {
    hdr.c1.pos3= hdr.data1.data[11:11];
    }
    action ap12() {
    hdr.c1.pos4= hdr.data1.data[12:12];
    }
    action ap13() {
    hdr.c1.pos5= hdr.data1.data[13:13];
    }
    action ap14() {
    hdr.c1.pos6= hdr.data1.data[14:14];
    }
    action ap15() {
    hdr.c1.pos7= hdr.data1.data[15:15];
    }
    action ap16() {
    hdr.c2.pos0= hdr.data1.data[16:16];
    }
    action ap17() {
    hdr.c2.pos1= hdr.data1.data[17:17];
    }
    action ap18() {
    hdr.c2.pos2= hdr.data1.data[18:18];
    }
    action ap19() {
    hdr.c2.pos3= hdr.data1.data[19:19];
    }
    action ap20() {
    hdr.c2.pos4= hdr.data1.data[20:20];
    }
    action ap21() {
    hdr.c2.pos5= hdr.data1.data[21:21];
    }
    action ap22() {
    hdr.c2.pos6= hdr.data1.data[22:22];
    }
    action ap23() {
    hdr.c2.pos7= hdr.data1.data[23:23];
    }
    action ap24() {
    hdr.c3.pos0= hdr.data1.data[24:24];
    }
    action ap25() {
    hdr.c3.pos1= hdr.data1.data[25:25];
    }
    action ap26() {
    hdr.c3.pos2= hdr.data1.data[26:26];
    }
    action ap27() {
    hdr.c3.pos3= hdr.data1.data[27:27];
    }
    action ap28() {
    hdr.c3.pos4= hdr.data1.data[28:28];
    }
    action ap29() {
    hdr.c3.pos5= hdr.data1.data[29:29];
    }
    action ap30() {
    hdr.c3.pos6= hdr.data1.data[30:30];
    }
    action ap31() {
    hdr.c3.pos7= hdr.data1.data[31:31];
    }
    action ap32() {
    hdr.c4.pos0= hdr.data1.data[32:32];
    }
    action ap33() {
    hdr.c4.pos1= hdr.data1.data[33:33];
    }
    action ap34() {
    hdr.c4.pos2= hdr.data1.data[34:34];
    }
    action ap35() {
    hdr.c4.pos3= hdr.data1.data[35:35];
    }
    action ap36() {
    hdr.c4.pos4= hdr.data1.data[36:36];
    }
    action ap37() {
    hdr.c4.pos5= hdr.data1.data[37:37];
    }
    action ap38() {
    hdr.c4.pos6= hdr.data1.data[38:38];
    }
    action ap39() {
    hdr.c4.pos7= hdr.data1.data[39:39];
    }
    action ap40() {
    hdr.c5.pos0= hdr.data1.data[40:40];
    }
    action ap41() {
    hdr.c5.pos1= hdr.data1.data[41:41];
    }
    action ap42() {
    hdr.c5.pos2= hdr.data1.data[42:42];
    }
    action ap43() {
    hdr.c5.pos3= hdr.data1.data[43:43];
    }
    action ap44() {
    hdr.c5.pos4= hdr.data1.data[44:44];
    }
    action ap45() {
    hdr.c5.pos5= hdr.data1.data[45:45];
    }
    action ap46() {
    hdr.c5.pos6= hdr.data1.data[46:46];
    }
    action ap47() {
    hdr.c5.pos7= hdr.data1.data[47:47];
    }
    action ap48() {
    hdr.c6.pos0= hdr.data1.data[48:48];
    }
    action ap49() {
    hdr.c6.pos1= hdr.data1.data[49:49];
    }
    action ap50() {
    hdr.c6.pos2= hdr.data1.data[50:50];
    }
    action ap51() {
    hdr.c6.pos3= hdr.data1.data[51:51];
    }
    action ap52() {
    hdr.c6.pos4= hdr.data1.data[52:52];
    }
    action ap53() {
    hdr.c6.pos5= hdr.data1.data[53:53];
    }
    action ap54() {
    hdr.c6.pos6= hdr.data1.data[54:54];
    }
    action ap55() {
    hdr.c6.pos7= hdr.data1.data[55:55];
    }
    action ap56() {
    hdr.c7.pos0= hdr.data1.data[56:56];
    }
    action ap57() {
    hdr.c7.pos1= hdr.data1.data[57:57];
    }
    action ap58() {
    hdr.c7.pos2= hdr.data1.data[58:58];
    }
    action ap59() {
    hdr.c7.pos3= hdr.data1.data[59:59];
    }
    action ap60() {
    hdr.c7.pos4= hdr.data1.data[60:60];
    }
    action ap61() {
    hdr.c7.pos5= hdr.data1.data[61:61];
    }
    action ap62() {
    hdr.c7.pos6= hdr.data1.data[62:62];
    }
    action ap63() {
    hdr.c7.pos7= hdr.data1.data[63:63];
    }
    action ap64() {
    hdr.c8.pos0= hdr.data1.data[64:64];
    }
    action ap65() {
    hdr.c8.pos1= hdr.data1.data[65:65];
    }
    action ap66() {
    hdr.c8.pos2= hdr.data1.data[66:66];
    }
    action ap67() {
    hdr.c8.pos3= hdr.data1.data[67:67];
    }
    action ap68() {
    hdr.c8.pos4= hdr.data1.data[68:68];
    }
    action ap69() {
    hdr.c8.pos5= hdr.data1.data[69:69];
    }
    action ap70() {
    hdr.c8.pos6= hdr.data1.data[70:70];
    }
    action ap71() {
    hdr.c8.pos7= hdr.data1.data[71:71];
    }
    action ap72() {
    hdr.c9.pos0= hdr.data1.data[72:72];
    }
    action ap73() {
    hdr.c9.pos1= hdr.data1.data[73:73];
    }
    action ap74() {
    hdr.c9.pos2= hdr.data1.data[74:74];
    }
    action ap75() {
    hdr.c9.pos3= hdr.data1.data[75:75];
    }
    action ap76() {
    hdr.c9.pos4= hdr.data1.data[76:76];
    }
    action ap77() {
    hdr.c9.pos5= hdr.data1.data[77:77];
    }
    action ap78() {
    hdr.c9.pos6= hdr.data1.data[78:78];
    }
    action ap79() {
    hdr.c9.pos7= hdr.data1.data[79:79];
    }
    action ap80() {
    hdr.c10.pos0= hdr.data1.data[80:80];
    }
    action ap81() {
    hdr.c10.pos1= hdr.data1.data[81:81];
    }
    action ap82() {
    hdr.c10.pos2= hdr.data1.data[82:82];
    }
    action ap83() {
    hdr.c10.pos3= hdr.data1.data[83:83];
    }
    action ap84() {
    hdr.c10.pos4= hdr.data1.data[84:84];
    }
    action ap85() {
    hdr.c10.pos5= hdr.data1.data[85:85];
    }
    action ap86() {
    hdr.c10.pos6= hdr.data1.data[86:86];
    }
    action ap87() {
    hdr.c10.pos7= hdr.data1.data[87:87];
    }
    action ap88() {
    hdr.c11.pos0= hdr.data1.data[88:88];
    }
    action ap89() {
    hdr.c11.pos1= hdr.data1.data[89:89];
    }
    action ap90() {
    hdr.c11.pos2= hdr.data1.data[90:90];
    }
    action ap91() {
    hdr.c11.pos3= hdr.data1.data[91:91];
    }
    action ap92() {
    hdr.c11.pos4= hdr.data1.data[92:92];
    }
    action ap93() {
    hdr.c11.pos5= hdr.data1.data[93:93];
    }
    action ap94() {
    hdr.c11.pos6= hdr.data1.data[94:94];
    }
    action ap95() {
    hdr.c11.pos7= hdr.data1.data[95:95];
    }
    action ap96() {
    hdr.c12.pos0= hdr.data1.data[96:96];
    }
    action ap97() {
    hdr.c12.pos1= hdr.data1.data[97:97];
    }
    action ap98() {
    hdr.c12.pos2= hdr.data1.data[98:98];
    }
    action ap99() {
    hdr.c12.pos3= hdr.data1.data[99:99];
    }
    action ap100() {
    hdr.c12.pos4= hdr.data1.data[100:100];
    }
    action ap101() {
    hdr.c12.pos5= hdr.data1.data[101:101];
    }
    action ap102() {
    hdr.c12.pos6= hdr.data1.data[102:102];
    }
    action ap103() {
    hdr.c12.pos7= hdr.data1.data[103:103];
    }
    action ap104() {
    hdr.c13.pos0= hdr.data1.data[104:104];
    }
    action ap105() {
    hdr.c13.pos1= hdr.data1.data[105:105];
    }
    action ap106() {
    hdr.c13.pos2= hdr.data1.data[106:106];
    }
    action ap107() {
    hdr.c13.pos3= hdr.data1.data[107:107];
    }
    action ap108() {
    hdr.c13.pos4= hdr.data1.data[108:108];
    }
    action ap109() {
    hdr.c13.pos5= hdr.data1.data[109:109];
    }
    action ap110() {
    hdr.c13.pos6= hdr.data1.data[110:110];
    }
    action ap111() {
    hdr.c13.pos7= hdr.data1.data[111:111];
    }
    action ap112() {
    hdr.c14.pos0= hdr.data1.data[112:112];
    }
    action ap113() {
    hdr.c14.pos1= hdr.data1.data[113:113];
    }
    action ap114() {
    hdr.c14.pos2= hdr.data1.data[114:114];
    }
    action ap115() {
    hdr.c14.pos3= hdr.data1.data[115:115];
    }
    action ap116() {
    hdr.c14.pos4= hdr.data1.data[116:116];
    }
    action ap117() {
    hdr.c14.pos5= hdr.data1.data[117:117];
    }
    action ap118() {
    hdr.c14.pos6= hdr.data1.data[118:118];
    }
    action ap119() {
    hdr.c14.pos7= hdr.data1.data[119:119];
    }
    action ap120() {
    hdr.c15.pos0= hdr.data1.data[120:120];
    }
    action ap121() {
    hdr.c15.pos1= hdr.data1.data[121:121];
    }
    action ap122() {
    hdr.c15.pos2= hdr.data1.data[122:122];
    }
    action ap123() {
    hdr.c15.pos3= hdr.data1.data[123:123];
    }
    action ap124() {
    hdr.c15.pos4= hdr.data1.data[124:124];
    }
    action ap125() {
    hdr.c15.pos5= hdr.data1.data[125:125];
    }
    action ap126() {
    hdr.c15.pos6= hdr.data1.data[126:126];
    }
    action ap127() {
    hdr.c15.pos7= hdr.data1.data[127:127];
    }


    
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
        hdr.siphash_internal_state.v0 = hdr.siphash_a.v2 ^ hdr.data1.data[31:0];
        hdr.siphash_internal_state.v1 = hdr.siphash_a.v0 ^ hdr.siphash_a.v1;
        hdr.siphash_internal_state.v2 = hdr.siphash_a.v0[15:0] ++ hdr.siphash_a.v0[31:16];
        hdr.siphash_internal_state.v3 = hdr.siphash_a.v2 ^ hdr.siphash_a.v3;
        
    }
    

    action read_SipRound_keys(bit<32> i_0, bit<32> i_1, bit<32> i_2, bit<32> i_3) {
        hdr.siphash_internal_state.setValid();
        hdr.siphash_internal_state.v0 = 0x1234;
        hdr.siphash_internal_state.v1 = 0x1234;
        hdr.siphash_internal_state.v2 = 0x1234;
        hdr.siphash_internal_state.v3 = 0x1234;
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


    apply {
        if (hdr.data1.isValid()){

            tb_read_SipRound_keys.apply();

            ap0();
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
            ap32();
            ap33();
            ap34();
            ap35();
            ap36();
            ap37();
            ap38();
            ap39();
            ap40();
            ap41();
            ap42();
            ap43();
            ap44();
            ap45();
            ap46();
            ap47();
            ap48();
            ap49();
            ap50();
            ap51();
            ap52();
            ap53();
            ap54();
            ap55();
            ap56();
            ap57();
            ap58();
            ap59();
            ap60();
            ap61();
            ap62();
            ap63();
            ap64();
            ap65();
            ap66();
            ap67();
            ap68();
            ap69();
            ap70();
            ap71();
            ap72();
            ap73();
            ap74();
            ap75();
            ap76();
            ap77();
            ap78();
            ap79();
            ap80();
            ap81();
            ap82();
            ap83();
            ap84();
            ap85();
            ap86();
            ap87();
            ap88();
            ap89();
            ap90();
            ap91();
            ap92();
            ap93();
            ap94();
            ap95();
            ap96();
            ap97();
            ap98();
            ap99();
            ap100();
            ap101();
            ap102();
            ap103();
            ap104();
            ap105();
            ap106();
            ap107();
            ap108();
            ap109();
            ap110();
            ap111();
            ap112();
            ap113();
            ap114();
            ap115();
            ap116();
            ap117();
            ap118();
            ap119();
            ap120();
            ap121();
            ap122();
            ap123();
            ap124();
            ap125();
            ap126();
            ap127();

            
            //p1();



            //c round
            hdr.siphash_internal_state.v3 = hdr.siphash_internal_state.v3 ^ hdr.data1.data[31:0];
            SipRound_1();
            SipRound_2();
            SipRound_3();
            SipRound_4();
            

            //d round
            
            //hdr.siphash_internal_state.v2 = hdr.siphash_internal_state.v2 ^ 0xff;
            //SipRound_1();
            //SipRound_2();
            //SipRound_3();
            //SipRound_4();
            


            //hdr.ethernet.src_addr = 0;
            xor_1();
            xor_res();
/*
            hdr.data1.setInvalid();
*/
        }     
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
        pkt.emit(hdr);
        //pkt.emit(hdr.ethernet);
        //pkt.emit(hdr.ipv4);
        /*
        pkt.emit(hdr.c0);
        pkt.emit(hdr.c1);
        pkt.emit(hdr.c2);
        pkt.emit(hdr.c3);
        */
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

