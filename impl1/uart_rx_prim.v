// Verilog netlist produced by program LSE :  version Diamond (64-bit) 3.14.0.75.2
// Netlist written on Thu Jan 08 20:19:37 2026
//
// Verilog Description of module uart_rx
//

module uart_rx (clk, resetn, uart_rxd, uart_rts, uart_rx_read, uart_rx_valid, 
            uart_rx_data) /* synthesis syn_module_defined=1 */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(14[8:15])
    input clk;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(20[23:26])
    input resetn;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(21[23:29])
    input uart_rxd;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(22[23:31])
    output uart_rts;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(23[23:31])
    input uart_rx_read;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(24[23:35])
    output uart_rx_valid;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(25[23:36])
    output [7:0]uart_rx_data;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(26[36:48])
    
    wire clk_c /* synthesis SET_AS_NETWORK=clk_c, is_clock=1 */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(20[23:26])
    
    wire GND_net, VCC_net, resetn_c, uart_rts_c, uart_rx_read_c, uart_rx_valid_c, 
        uart_rx_data_c_7, uart_rx_data_c_6, uart_rx_data_c_5, uart_rx_data_c_4, 
        uart_rx_data_c_3, uart_rx_data_c_2, uart_rx_data_c_1, uart_rx_data_c_0;
    wire [13:0]cycle_counter;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(51[25:38])
    
    wire bit_sample;
    wire [3:0]fsm_state;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(59[11:20])
    wire [3:0]next_fsm_state;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(83[11:25])
    
    wire n438, n869, next_fsm_state_3__N_47_c_3, n819;
    wire [3:0]next_fsm_state_3__N_35;
    
    wire n362, n867, n793, n813;
    wire [31:0]next_fsm_state_3__N_51;
    
    wire n747, uart_rx_data_7__N_83, n653, n432, n318, n514, n783, 
        n364, n360, n513, n512, n511, n861, n490, n510, n885, 
        n509, n508, n1002, n1001, n799, n853, n62, n63, n64, 
        n65, n66, n67, n68, n69, n70, n71, n72, n73, n74, 
        n75, n1000, n775, clk_c_enable_1, n999, n467, n998, n851, 
        n773, n591, n997, n897, n847, n765, n761, n996, n839, 
        n883, n995, n889, n877, n831, n741, n636, n755, n1008, 
        n1007, n1006, n1005, n1004, n1003;
    
    VHI i2 (.Z(VCC_net));
    LUT4 i1_4_lut (.A(n847), .B(n999), .C(n765), .D(n761), .Z(n438)) /* synthesis lut_function=(((C+(D))+!B)+!A) */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(79[21:75])
    defparam i1_4_lut.init = 16'hfff7;
    FD1P3IX bit_sample_45 (.D(next_fsm_state_3__N_47_c_3), .SP(clk_c_enable_1), 
            .CD(n998), .CK(clk_c), .Q(bit_sample));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(124[8] 130[4])
    defparam bit_sample_45.GSR = "ENABLED";
    FD1P3AX recieved_data_i0_i7 (.D(uart_rx_data_c_7), .SP(uart_rx_data_7__N_83), 
            .CK(clk_c), .Q(uart_rx_data_c_6));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(116[8] 120[4])
    defparam recieved_data_i0_i7.GSR = "ENABLED";
    FD1P3AX recieved_data_i0_i6 (.D(uart_rx_data_c_6), .SP(uart_rx_data_7__N_83), 
            .CK(clk_c), .Q(uart_rx_data_c_5));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(116[8] 120[4])
    defparam recieved_data_i0_i6.GSR = "ENABLED";
    FD1P3AX recieved_data_i0_i5 (.D(uart_rx_data_c_5), .SP(uart_rx_data_7__N_83), 
            .CK(clk_c), .Q(uart_rx_data_c_4));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(116[8] 120[4])
    defparam recieved_data_i0_i5.GSR = "ENABLED";
    FD1P3AX recieved_data_i0_i4 (.D(uart_rx_data_c_4), .SP(uart_rx_data_7__N_83), 
            .CK(clk_c), .Q(uart_rx_data_c_3));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(116[8] 120[4])
    defparam recieved_data_i0_i4.GSR = "ENABLED";
    FD1S3IX cycle_counter_107__i0 (.D(n75), .CK(clk_c), .CD(n318), .Q(cycle_counter[0])) /* synthesis syn_use_carry_chain=1 */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(141[26:46])
    defparam cycle_counter_107__i0.GSR = "ENABLED";
    FD1P3AX recieved_data_i0_i3 (.D(uart_rx_data_c_3), .SP(uart_rx_data_7__N_83), 
            .CK(clk_c), .Q(uart_rx_data_c_2));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(116[8] 120[4])
    defparam recieved_data_i0_i3.GSR = "ENABLED";
    FD1P3AX recieved_data_i0_i2 (.D(uart_rx_data_c_2), .SP(uart_rx_data_7__N_83), 
            .CK(clk_c), .Q(uart_rx_data_c_1));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(116[8] 120[4])
    defparam recieved_data_i0_i2.GSR = "ENABLED";
    FD1S3JX uart_rts_48 (.D(n1003), .CK(clk_c), .PD(n998), .Q(uart_rts_c));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(157[8] 163[4])
    defparam uart_rts_48.GSR = "ENABLED";
    OB uart_rx_valid_pad (.I(uart_rx_valid_c), .O(uart_rx_valid));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(25[23:36])
    FD1S3IX fsm_state__i3 (.D(next_fsm_state[3]), .CK(clk_c), .CD(n998), 
            .Q(fsm_state[3]));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(148[8] 154[4])
    defparam fsm_state__i3.GSR = "ENABLED";
    FD1S3IX fsm_state__i2 (.D(next_fsm_state_3__N_51[2]), .CK(clk_c), .CD(n432), 
            .Q(fsm_state[2]));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(148[8] 154[4])
    defparam fsm_state__i2.GSR = "ENABLED";
    FD1S3IX fsm_state__i0 (.D(next_fsm_state[0]), .CK(clk_c), .CD(n998), 
            .Q(fsm_state[0]));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(148[8] 154[4])
    defparam fsm_state__i0.GSR = "ENABLED";
    FD1S3IX fsm_state__i1 (.D(next_fsm_state[1]), .CK(clk_c), .CD(n998), 
            .Q(fsm_state[1]));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(148[8] 154[4])
    defparam fsm_state__i1.GSR = "ENABLED";
    FD1P3AX recieved_data_i0_i1 (.D(uart_rx_data_c_1), .SP(uart_rx_data_7__N_83), 
            .CK(clk_c), .Q(uart_rx_data_c_0));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(116[8] 120[4])
    defparam recieved_data_i0_i1.GSR = "ENABLED";
    LUT4 i2_2_lut_rep_41 (.A(cycle_counter[4]), .B(cycle_counter[6]), .Z(n1007)) /* synthesis lut_function=(A+(B)) */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(79[21:75])
    defparam i2_2_lut_rep_41.init = 16'heeee;
    OB uart_rts_pad (.I(uart_rts_c), .O(uart_rts));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(23[23:31])
    FD1P3AX recieved_data_i0_i8 (.D(bit_sample), .SP(uart_rx_data_7__N_83), 
            .CK(clk_c), .Q(uart_rx_data_c_7));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(116[8] 120[4])
    defparam recieved_data_i0_i8.GSR = "ENABLED";
    LUT4 i1_3_lut_4_lut (.A(cycle_counter[13]), .B(n999), .C(n1002), .D(n813), 
         .Z(n819)) /* synthesis lut_function=(!(A+!(B (C (D))))) */ ;
    defparam i1_3_lut_4_lut.init = 16'h4000;
    FD1S3IX cycle_counter_107__i13 (.D(n62), .CK(clk_c), .CD(n318), .Q(cycle_counter[13])) /* synthesis syn_use_carry_chain=1 */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(141[26:46])
    defparam cycle_counter_107__i13.GSR = "ENABLED";
    FD1S3IX cycle_counter_107__i12 (.D(n63), .CK(clk_c), .CD(n318), .Q(cycle_counter[12])) /* synthesis syn_use_carry_chain=1 */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(141[26:46])
    defparam cycle_counter_107__i12.GSR = "ENABLED";
    FD1S3IX cycle_counter_107__i11 (.D(n64), .CK(clk_c), .CD(n318), .Q(cycle_counter[11])) /* synthesis syn_use_carry_chain=1 */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(141[26:46])
    defparam cycle_counter_107__i11.GSR = "ENABLED";
    FD1S3IX cycle_counter_107__i10 (.D(n65), .CK(clk_c), .CD(n318), .Q(cycle_counter[10])) /* synthesis syn_use_carry_chain=1 */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(141[26:46])
    defparam cycle_counter_107__i10.GSR = "ENABLED";
    FD1S3IX cycle_counter_107__i9 (.D(n66), .CK(clk_c), .CD(n318), .Q(cycle_counter[9])) /* synthesis syn_use_carry_chain=1 */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(141[26:46])
    defparam cycle_counter_107__i9.GSR = "ENABLED";
    FD1S3IX cycle_counter_107__i8 (.D(n67), .CK(clk_c), .CD(n318), .Q(cycle_counter[8])) /* synthesis syn_use_carry_chain=1 */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(141[26:46])
    defparam cycle_counter_107__i8.GSR = "ENABLED";
    FD1S3IX cycle_counter_107__i7 (.D(n68), .CK(clk_c), .CD(n318), .Q(cycle_counter[7])) /* synthesis syn_use_carry_chain=1 */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(141[26:46])
    defparam cycle_counter_107__i7.GSR = "ENABLED";
    FD1S3IX cycle_counter_107__i6 (.D(n69), .CK(clk_c), .CD(n318), .Q(cycle_counter[6])) /* synthesis syn_use_carry_chain=1 */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(141[26:46])
    defparam cycle_counter_107__i6.GSR = "ENABLED";
    LUT4 i1_2_lut_3_lut (.A(cycle_counter[8]), .B(cycle_counter[0]), .C(cycle_counter[5]), 
         .Z(n775)) /* synthesis lut_function=(A+(B+!(C))) */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(79[21:75])
    defparam i1_2_lut_3_lut.init = 16'hefef;
    PFUMX mux_96_i1 (.BLUT(n360), .ALUT(n364), .C0(n897), .Z(next_fsm_state[0]));
    CCU2C cycle_counter_107_add_4_15 (.A0(cycle_counter[13]), .B0(GND_net), 
          .C0(GND_net), .D0(VCC_net), .A1(GND_net), .B1(GND_net), .C1(GND_net), 
          .D1(GND_net), .CIN(n514), .S0(n62));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(141[26:46])
    defparam cycle_counter_107_add_4_15.INIT0 = 16'haaa0;
    defparam cycle_counter_107_add_4_15.INIT1 = 16'h0000;
    defparam cycle_counter_107_add_4_15.INJECT1_0 = "NO";
    defparam cycle_counter_107_add_4_15.INJECT1_1 = "NO";
    CCU2C cycle_counter_107_add_4_13 (.A0(cycle_counter[11]), .B0(GND_net), 
          .C0(GND_net), .D0(VCC_net), .A1(cycle_counter[12]), .B1(GND_net), 
          .C1(GND_net), .D1(VCC_net), .CIN(n513), .COUT(n514), .S0(n64), 
          .S1(n63));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(141[26:46])
    defparam cycle_counter_107_add_4_13.INIT0 = 16'haaa0;
    defparam cycle_counter_107_add_4_13.INIT1 = 16'haaa0;
    defparam cycle_counter_107_add_4_13.INJECT1_0 = "NO";
    defparam cycle_counter_107_add_4_13.INJECT1_1 = "NO";
    CCU2C cycle_counter_107_add_4_11 (.A0(cycle_counter[9]), .B0(GND_net), 
          .C0(GND_net), .D0(VCC_net), .A1(cycle_counter[10]), .B1(GND_net), 
          .C1(GND_net), .D1(VCC_net), .CIN(n512), .COUT(n513), .S0(n66), 
          .S1(n65));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(141[26:46])
    defparam cycle_counter_107_add_4_11.INIT0 = 16'haaa0;
    defparam cycle_counter_107_add_4_11.INIT1 = 16'haaa0;
    defparam cycle_counter_107_add_4_11.INJECT1_0 = "NO";
    defparam cycle_counter_107_add_4_11.INJECT1_1 = "NO";
    LUT4 i1_2_lut_3_lut_adj_1 (.A(cycle_counter[4]), .B(cycle_counter[6]), 
         .C(cycle_counter[5]), .Z(n831)) /* synthesis lut_function=(A+(B+!(C))) */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(79[21:75])
    defparam i1_2_lut_3_lut_adj_1.init = 16'hefef;
    FD1S3IX cycle_counter_107__i5 (.D(n70), .CK(clk_c), .CD(n318), .Q(cycle_counter[5])) /* synthesis syn_use_carry_chain=1 */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(141[26:46])
    defparam cycle_counter_107__i5.GSR = "ENABLED";
    FD1S3IX cycle_counter_107__i4 (.D(n71), .CK(clk_c), .CD(n318), .Q(cycle_counter[4])) /* synthesis syn_use_carry_chain=1 */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(141[26:46])
    defparam cycle_counter_107__i4.GSR = "ENABLED";
    LUT4 i1_4_lut_rep_42 (.A(fsm_state[2]), .B(fsm_state[0]), .C(fsm_state[1]), 
         .D(fsm_state[3]), .Z(n1008)) /* synthesis lut_function=(!(A+!(B (C (D))+!B (C (D)+!C !(D))))) */ ;
    defparam i1_4_lut_rep_42.init = 16'h5001;
    CCU2C cycle_counter_107_add_4_9 (.A0(cycle_counter[7]), .B0(GND_net), 
          .C0(GND_net), .D0(VCC_net), .A1(cycle_counter[8]), .B1(GND_net), 
          .C1(GND_net), .D1(VCC_net), .CIN(n511), .COUT(n512), .S0(n68), 
          .S1(n67));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(141[26:46])
    defparam cycle_counter_107_add_4_9.INIT0 = 16'haaa0;
    defparam cycle_counter_107_add_4_9.INIT1 = 16'haaa0;
    defparam cycle_counter_107_add_4_9.INJECT1_0 = "NO";
    defparam cycle_counter_107_add_4_9.INJECT1_1 = "NO";
    FD1S3IX cycle_counter_107__i3 (.D(n72), .CK(clk_c), .CD(n318), .Q(cycle_counter[3])) /* synthesis syn_use_carry_chain=1 */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(141[26:46])
    defparam cycle_counter_107__i3.GSR = "ENABLED";
    CCU2C cycle_counter_107_add_4_7 (.A0(cycle_counter[5]), .B0(GND_net), 
          .C0(GND_net), .D0(VCC_net), .A1(cycle_counter[6]), .B1(GND_net), 
          .C1(GND_net), .D1(VCC_net), .CIN(n510), .COUT(n511), .S0(n70), 
          .S1(n69));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(141[26:46])
    defparam cycle_counter_107_add_4_7.INIT0 = 16'haaa0;
    defparam cycle_counter_107_add_4_7.INIT1 = 16'haaa0;
    defparam cycle_counter_107_add_4_7.INJECT1_0 = "NO";
    defparam cycle_counter_107_add_4_7.INJECT1_1 = "NO";
    FD1S3IX cycle_counter_107__i2 (.D(n73), .CK(clk_c), .CD(n318), .Q(cycle_counter[2])) /* synthesis syn_use_carry_chain=1 */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(141[26:46])
    defparam cycle_counter_107__i2.GSR = "ENABLED";
    LUT4 i1_4_lut_adj_2 (.A(n591), .B(n783), .C(n775), .D(n773), .Z(next_fsm_state_3__N_35[3])) /* synthesis lut_function=((B+(C+(D)))+!A) */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(79[21:75])
    defparam i1_4_lut_adj_2.init = 16'hfffd;
    CCU2C cycle_counter_107_add_4_5 (.A0(cycle_counter[3]), .B0(GND_net), 
          .C0(GND_net), .D0(VCC_net), .A1(cycle_counter[4]), .B1(GND_net), 
          .C1(GND_net), .D1(VCC_net), .CIN(n509), .COUT(n510), .S0(n72), 
          .S1(n71));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(141[26:46])
    defparam cycle_counter_107_add_4_5.INIT0 = 16'haaa0;
    defparam cycle_counter_107_add_4_5.INIT1 = 16'haaa0;
    defparam cycle_counter_107_add_4_5.INJECT1_0 = "NO";
    defparam cycle_counter_107_add_4_5.INJECT1_1 = "NO";
    LUT4 i325_2_lut_rep_33 (.A(cycle_counter[12]), .B(cycle_counter[4]), 
         .Z(n999)) /* synthesis lut_function=(A (B)) */ ;
    defparam i325_2_lut_rep_33.init = 16'h8888;
    FD1S3IX cycle_counter_107__i1 (.D(n74), .CK(clk_c), .CD(n318), .Q(cycle_counter[1])) /* synthesis syn_use_carry_chain=1 */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(141[26:46])
    defparam cycle_counter_107__i1.GSR = "ENABLED";
    LUT4 i1_4_lut_adj_3 (.A(n490), .B(n861), .C(n885), .D(fsm_state[3]), 
         .Z(uart_rx_data_7__N_83)) /* synthesis lut_function=(!(A ((C+(D))+!B)+!A ((C)+!B))) */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(117[8:65])
    defparam i1_4_lut_adj_3.init = 16'h040c;
    LUT4 i321_2_lut (.A(cycle_counter[11]), .B(cycle_counter[2]), .Z(n591)) /* synthesis lut_function=(A (B)) */ ;
    defparam i321_2_lut.init = 16'h8888;
    CCU2C cycle_counter_107_add_4_3 (.A0(cycle_counter[1]), .B0(GND_net), 
          .C0(GND_net), .D0(VCC_net), .A1(cycle_counter[2]), .B1(GND_net), 
          .C1(GND_net), .D1(VCC_net), .CIN(n508), .COUT(n509), .S0(n74), 
          .S1(n73));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(141[26:46])
    defparam cycle_counter_107_add_4_3.INIT0 = 16'haaa0;
    defparam cycle_counter_107_add_4_3.INIT1 = 16'haaa0;
    defparam cycle_counter_107_add_4_3.INJECT1_0 = "NO";
    defparam cycle_counter_107_add_4_3.INJECT1_1 = "NO";
    CCU2C cycle_counter_107_add_4_1 (.A0(GND_net), .B0(GND_net), .C0(GND_net), 
          .D0(GND_net), .A1(cycle_counter[0]), .B1(GND_net), .C1(GND_net), 
          .D1(VCC_net), .COUT(n508), .S1(n75));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(141[26:46])
    defparam cycle_counter_107_add_4_1.INIT0 = 16'h0000;
    defparam cycle_counter_107_add_4_1.INIT1 = 16'h555f;
    defparam cycle_counter_107_add_4_1.INJECT1_0 = "NO";
    defparam cycle_counter_107_add_4_1.INJECT1_1 = "NO";
    GSR GSR_INST (.GSR(VCC_net));
    OB uart_rx_data_pad_7 (.I(uart_rx_data_c_7), .O(uart_rx_data[7]));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(26[36:48])
    OB uart_rx_data_pad_6 (.I(uart_rx_data_c_6), .O(uart_rx_data[6]));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(26[36:48])
    OB uart_rx_data_pad_5 (.I(uart_rx_data_c_5), .O(uart_rx_data[5]));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(26[36:48])
    OB uart_rx_data_pad_4 (.I(uart_rx_data_c_4), .O(uart_rx_data[4]));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(26[36:48])
    OB uart_rx_data_pad_3 (.I(uart_rx_data_c_3), .O(uart_rx_data[3]));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(26[36:48])
    OB uart_rx_data_pad_2 (.I(uart_rx_data_c_2), .O(uart_rx_data[2]));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(26[36:48])
    OB uart_rx_data_pad_1 (.I(uart_rx_data_c_1), .O(uart_rx_data[1]));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(26[36:48])
    OB uart_rx_data_pad_0 (.I(uart_rx_data_c_0), .O(uart_rx_data[0]));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(26[36:48])
    IB clk_pad (.I(clk), .O(clk_c));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(20[23:26])
    IB resetn_pad (.I(resetn), .O(resetn_c));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(21[23:29])
    IB next_fsm_state_3__N_47_pad_3 (.I(uart_rxd), .O(next_fsm_state_3__N_47_c_3));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(22[23:31])
    IB uart_rx_read_pad (.I(uart_rx_read), .O(uart_rx_read_c));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(24[23:35])
    LUT4 i132_4_lut (.A(fsm_state[2]), .B(n877), .C(n885), .D(n1000), 
         .Z(next_fsm_state_3__N_51[2])) /* synthesis lut_function=(A ((C+(D))+!B)+!A !((C+(D))+!B)) */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(105[33:48])
    defparam i132_4_lut.init = 16'haaa6;
    LUT4 i626_2_lut_4_lut (.A(fsm_state[2]), .B(fsm_state[0]), .C(fsm_state[1]), 
         .D(fsm_state[3]), .Z(n897)) /* synthesis lut_function=(A+(B+!(C (D)+!C !(D)))) */ ;
    defparam i626_2_lut_4_lut.init = 16'heffe;
    LUT4 i1_4_lut_adj_4 (.A(n1001), .B(n995), .C(n869), .D(n867), .Z(n877)) /* synthesis lut_function=(!(A+!(B (C (D))))) */ ;
    defparam i1_4_lut_adj_4.init = 16'h4000;
    LUT4 i1_3_lut (.A(cycle_counter[6]), .B(fsm_state[1]), .C(cycle_counter[10]), 
         .Z(n869)) /* synthesis lut_function=(A (B (C))) */ ;
    defparam i1_3_lut.init = 16'h8080;
    LUT4 i1_3_lut_4_lut_adj_5 (.A(n1005), .B(cycle_counter[13]), .C(n1000), 
         .D(n1001), .Z(n765)) /* synthesis lut_function=(A+(B+(C+(D)))) */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(79[21:75])
    defparam i1_3_lut_4_lut_adj_5.init = 16'hfffe;
    LUT4 i1_2_lut_rep_35 (.A(cycle_counter[5]), .B(cycle_counter[11]), .Z(n1001)) /* synthesis lut_function=(A+(B)) */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(79[21:75])
    defparam i1_2_lut_rep_35.init = 16'heeee;
    LUT4 i1_2_lut (.A(fsm_state[0]), .B(cycle_counter[3]), .Z(n867)) /* synthesis lut_function=(A (B)) */ ;
    defparam i1_2_lut.init = 16'h8888;
    LUT4 i599_2_lut_3_lut_4_lut (.A(cycle_counter[10]), .B(cycle_counter[12]), 
         .C(cycle_counter[1]), .D(cycle_counter[7]), .Z(n883)) /* synthesis lut_function=(A+(B+(C+(D)))) */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(79[21:75])
    defparam i599_2_lut_3_lut_4_lut.init = 16'hfffe;
    LUT4 i227_2_lut (.A(fsm_state[1]), .B(fsm_state[2]), .Z(n490)) /* synthesis lut_function=(A+(B)) */ ;
    defparam i227_2_lut.init = 16'heeee;
    LUT4 mux_96_i2_4_lut (.A(fsm_state[1]), .B(n362), .C(n1008), .D(n653), 
         .Z(next_fsm_state[1])) /* synthesis lut_function=(A (B (C+!(D))+!B !(C+(D)))+!A (B (C+(D))+!B !(C+!(D)))) */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(85[3] 107[10])
    defparam mux_96_i2_4_lut.init = 16'hc5ca;
    LUT4 i1_4_lut_adj_6 (.A(n1004), .B(n889), .C(n1000), .D(n799), .Z(n653)) /* synthesis lut_function=(!(A+(B+(C+!(D))))) */ ;
    defparam i1_4_lut_adj_6.init = 16'h0100;
    LUT4 i1_2_lut_rep_36 (.A(fsm_state[1]), .B(fsm_state[0]), .Z(n1002)) /* synthesis lut_function=(A (B)) */ ;
    defparam i1_2_lut_rep_36.init = 16'h8888;
    LUT4 i1_4_lut_adj_7 (.A(n999), .B(cycle_counter[13]), .C(n793), .D(n847), 
         .Z(n799)) /* synthesis lut_function=(!((B+!(C (D)))+!A)) */ ;
    defparam i1_4_lut_adj_7.init = 16'h2000;
    LUT4 i624_3_lut_4_lut (.A(fsm_state[1]), .B(fsm_state[0]), .C(fsm_state[2]), 
         .D(fsm_state[3]), .Z(uart_rx_valid_c)) /* synthesis lut_function=(!(((C+!(D))+!B)+!A)) */ ;
    defparam i624_3_lut_4_lut.init = 16'h0800;
    LUT4 i1_2_lut_adj_8 (.A(fsm_state[0]), .B(cycle_counter[6]), .Z(n793)) /* synthesis lut_function=(A (B)) */ ;
    defparam i1_2_lut_adj_8.init = 16'h8888;
    LUT4 i1_3_lut_rep_37 (.A(fsm_state[2]), .B(fsm_state[1]), .C(fsm_state[3]), 
         .Z(n1003)) /* synthesis lut_function=(A+(B+(C))) */ ;
    defparam i1_3_lut_rep_37.init = 16'hfefe;
    LUT4 i621_4_lut (.A(resetn_c), .B(n839), .C(n997), .D(n831), .Z(clk_c_enable_1)) /* synthesis lut_function=(!(A (B+(C+(D))))) */ ;
    defparam i621_4_lut.init = 16'h5557;
    LUT4 i1_2_lut_4_lut (.A(fsm_state[2]), .B(fsm_state[1]), .C(fsm_state[3]), 
         .D(cycle_counter[13]), .Z(n853)) /* synthesis lut_function=(!(A (D)+!A (B (D)+!B ((D)+!C)))) */ ;
    defparam i1_2_lut_4_lut.init = 16'h00fe;
    LUT4 i1_4_lut_adj_9 (.A(n1007), .B(n1000), .C(n747), .D(cycle_counter[13]), 
         .Z(n755)) /* synthesis lut_function=(!(A+(B+((D)+!C)))) */ ;
    defparam i1_4_lut_adj_9.init = 16'h0010;
    LUT4 i1_4_lut_adj_10 (.A(n591), .B(cycle_counter[3]), .C(n741), .D(cycle_counter[9]), 
         .Z(n747)) /* synthesis lut_function=(A (B (C (D)))) */ ;
    defparam i1_4_lut_adj_10.init = 16'h8000;
    LUT4 i1_2_lut_adj_11 (.A(cycle_counter[5]), .B(next_fsm_state_3__N_47_c_3), 
         .Z(n741)) /* synthesis lut_function=(A (B)) */ ;
    defparam i1_2_lut_adj_11.init = 16'h8888;
    LUT4 i1_4_lut_adj_12 (.A(n1001), .B(n1000), .C(n853), .D(n851), 
         .Z(n861)) /* synthesis lut_function=(!(A+(B+!(C (D))))) */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(117[8:65])
    defparam i1_4_lut_adj_12.init = 16'h1000;
    LUT4 i1_2_lut_adj_13 (.A(cycle_counter[3]), .B(cycle_counter[10]), .Z(n847)) /* synthesis lut_function=(A (B)) */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(117[8:65])
    defparam i1_2_lut_adj_13.init = 16'h8888;
    LUT4 i618_4_lut (.A(n467), .B(n438), .C(uart_rx_valid_c), .D(resetn_c), 
         .Z(n318)) /* synthesis lut_function=(((C+!(D))+!B)+!A) */ ;
    defparam i618_4_lut.init = 16'hf7ff;
    LUT4 i1_4_lut_adj_14 (.A(n591), .B(cycle_counter[9]), .C(n996), .D(n1000), 
         .Z(n839)) /* synthesis lut_function=(((C+(D))+!B)+!A) */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(79[21:75])
    defparam i1_4_lut_adj_14.init = 16'hfff7;
    LUT4 i1_3_lut_4_lut_adj_15 (.A(cycle_counter[3]), .B(n1006), .C(cycle_counter[9]), 
         .D(n1007), .Z(n783)) /* synthesis lut_function=((B+((D)+!C))+!A) */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(79[21:75])
    defparam i1_3_lut_4_lut_adj_15.init = 16'hffdf;
    LUT4 i204_2_lut_4_lut (.A(fsm_state[2]), .B(fsm_state[1]), .C(fsm_state[3]), 
         .D(fsm_state[0]), .Z(n467)) /* synthesis lut_function=(A+(B+(C+(D)))) */ ;
    defparam i204_2_lut_4_lut.init = 16'hfffe;
    LUT4 i2_2_lut_rep_38 (.A(cycle_counter[2]), .B(cycle_counter[9]), .Z(n1004)) /* synthesis lut_function=(A+(B)) */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(79[21:75])
    defparam i2_2_lut_rep_38.init = 16'heeee;
    LUT4 mux_100_i1_4_lut (.A(next_fsm_state_3__N_47_c_3), .B(n755), .C(fsm_state[1]), 
         .D(n883), .Z(n360)) /* synthesis lut_function=(!(A (((D)+!C)+!B)+!A (B (C (D))+!B (C)))) */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(85[3] 107[10])
    defparam mux_100_i1_4_lut.init = 16'h05c5;
    LUT4 mux_96_i4_4_lut (.A(fsm_state[3]), .B(n362), .C(n1008), .D(n636), 
         .Z(next_fsm_state[3])) /* synthesis lut_function=(A (B (C+!(D))+!B !(C+(D)))+!A (B (C+(D))+!B !(C+!(D)))) */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(85[3] 107[10])
    defparam mux_96_i4_4_lut.init = 16'hc5ca;
    LUT4 i1_2_lut_3_lut_adj_16 (.A(cycle_counter[2]), .B(cycle_counter[9]), 
         .C(cycle_counter[6]), .Z(n761)) /* synthesis lut_function=(A+(B+!(C))) */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(79[21:75])
    defparam i1_2_lut_3_lut_adj_16.init = 16'hefef;
    LUT4 i1_2_lut_rep_34 (.A(cycle_counter[8]), .B(cycle_counter[0]), .Z(n1000)) /* synthesis lut_function=(A+(B)) */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(79[21:75])
    defparam i1_2_lut_rep_34.init = 16'heeee;
    LUT4 i1_3_lut_4_lut_adj_17 (.A(cycle_counter[12]), .B(cycle_counter[4]), 
         .C(cycle_counter[6]), .D(n847), .Z(n851)) /* synthesis lut_function=(A (B (C (D)))) */ ;
    defparam i1_3_lut_4_lut_adj_17.init = 16'h8000;
    LUT4 i605_2_lut_3_lut_4_lut (.A(cycle_counter[7]), .B(cycle_counter[1]), 
         .C(cycle_counter[11]), .D(cycle_counter[5]), .Z(n889)) /* synthesis lut_function=(A+(B+(C+(D)))) */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(79[21:75])
    defparam i605_2_lut_3_lut_4_lut.init = 16'hfffe;
    LUT4 i1_4_lut_adj_18 (.A(cycle_counter[10]), .B(cycle_counter[3]), .C(fsm_state[2]), 
         .D(cycle_counter[6]), .Z(n813)) /* synthesis lut_function=(A (B (C (D)))) */ ;
    defparam i1_4_lut_adj_18.init = 16'h8000;
    LUT4 i1_3_lut_4_lut_adj_19 (.A(cycle_counter[7]), .B(cycle_counter[1]), 
         .C(next_fsm_state_3__N_47_c_3), .D(cycle_counter[13]), .Z(n773)) /* synthesis lut_function=(A+(B+(C+(D)))) */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(79[21:75])
    defparam i1_3_lut_4_lut_adj_19.init = 16'hfffe;
    LUT4 mux_101_i1_4_lut_4_lut (.A(uart_rx_read_c), .B(n438), .C(n1008), 
         .D(fsm_state[0]), .Z(n364)) /* synthesis lut_function=(!(A (B (C+!(D))+!B (C+(D)))+!A !(B (C+(D))+!B (C+!(D))))) */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(101[22:57])
    defparam mux_101_i1_4_lut_4_lut.init = 16'h5c53;
    LUT4 i169_2_lut_2_lut (.A(resetn_c), .B(n1008), .Z(n432)) /* synthesis lut_function=((B)+!A) */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(21[23:29])
    defparam i169_2_lut_2_lut.init = 16'hdddd;
    LUT4 i3_2_lut_rep_39 (.A(cycle_counter[7]), .B(cycle_counter[1]), .Z(n1005)) /* synthesis lut_function=(A+(B)) */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(79[21:75])
    defparam i3_2_lut_rep_39.init = 16'heeee;
    LUT4 i1_2_lut_rep_40 (.A(cycle_counter[10]), .B(cycle_counter[12]), 
         .Z(n1006)) /* synthesis lut_function=(A+(B)) */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(79[21:75])
    defparam i1_2_lut_rep_40.init = 16'heeee;
    LUT4 i1_2_lut_rep_29_3_lut (.A(cycle_counter[12]), .B(cycle_counter[4]), 
         .C(cycle_counter[13]), .Z(n995)) /* synthesis lut_function=(!(((C)+!B)+!A)) */ ;
    defparam i1_2_lut_rep_29_3_lut.init = 16'h0808;
    LUT4 i1_2_lut_rep_30_3_lut (.A(cycle_counter[7]), .B(cycle_counter[1]), 
         .C(cycle_counter[13]), .Z(n996)) /* synthesis lut_function=(A+(B+(C))) */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(79[21:75])
    defparam i1_2_lut_rep_30_3_lut.init = 16'hfefe;
    LUT4 i601_2_lut_3_lut_4_lut (.A(cycle_counter[7]), .B(cycle_counter[1]), 
         .C(cycle_counter[9]), .D(cycle_counter[2]), .Z(n885)) /* synthesis lut_function=(A+(B+(C+(D)))) */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(79[21:75])
    defparam i601_2_lut_3_lut_4_lut.init = 16'hfffe;
    LUT4 i80_1_lut_rep_32 (.A(resetn_c), .Z(n998)) /* synthesis lut_function=(!(A)) */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(21[23:29])
    defparam i80_1_lut_rep_32.init = 16'h5555;
    LUT4 mux_101_i3_4_lut (.A(next_fsm_state_3__N_35[3]), .B(uart_rx_read_c), 
         .C(fsm_state[0]), .D(fsm_state[1]), .Z(n362)) /* synthesis lut_function=(!(A (B (C+!(D))+!B !(C+(D)))+!A (B+!(C)))) */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(85[3] 107[10])
    defparam mux_101_i3_4_lut.init = 16'h3a30;
    LUT4 i1_2_lut_rep_31_3_lut (.A(cycle_counter[10]), .B(cycle_counter[12]), 
         .C(cycle_counter[3]), .Z(n997)) /* synthesis lut_function=(A+(B+!(C))) */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/impl1/source/uart_rx.v(79[21:75])
    defparam i1_2_lut_rep_31_3_lut.init = 16'hefef;
    PUR PUR_INST (.PUR(VCC_net));
    defparam PUR_INST.RST_PULSE = 1;
    VLO i1 (.Z(GND_net));
    LUT4 i1_4_lut_adj_20 (.A(n1001), .B(n885), .C(n1000), .D(n819), 
         .Z(n636)) /* synthesis lut_function=(!(A+(B+(C+!(D))))) */ ;
    defparam i1_4_lut_adj_20.init = 16'h0100;
    
endmodule
//
// Verilog Description of module PUR
// module not written out since it is a black-box. 
//

