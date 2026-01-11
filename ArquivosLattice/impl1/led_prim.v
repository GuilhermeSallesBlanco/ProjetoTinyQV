// Verilog netlist produced by program LSE :  version Diamond (64-bit) 3.14.0.75.2
// Netlist written on Wed Jan 07 18:31:31 2026
//
// Verilog Description of module led
//

module led (clk, rst_n, address, write_en, read_en, data_in, data_out, 
            led) /* synthesis syn_module_defined=1 */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(4[8:11])
    input clk;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(5[13:16])
    input rst_n;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(6[13:18])
    input [3:0]address;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(8[19:26])
    input write_en;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(9[13:21])
    input read_en;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(10[13:20])
    input [31:0]data_in;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(12[20:27])
    output [31:0]data_out;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(13[20:28])
    output led;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(15[13:16])
    
    wire clk_c /* synthesis is_clock=1, SET_AS_NETWORK=clk_c */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(5[13:16])
    
    wire GND_net, rst_n_c, address_c_3, address_c_2, address_c_1, 
        address_c_0, write_en_c, read_en_c, data_in_c_0, clk_c_enable_1, 
        n51, data_out_0_0, led_c, VCC_net, n106;
    
    VHI i36 (.Z(VCC_net));
    GSR GSR_INST (.GSR(VCC_net));
    OB data_out_pad_31 (.I(GND_net), .O(data_out[31]));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(13[20:28])
    OB data_out_pad_27 (.I(GND_net), .O(data_out[27]));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(13[20:28])
    FD1P3IX led_13 (.D(data_in_c_0), .SP(clk_c_enable_1), .CD(n51), .CK(clk_c), 
            .Q(led_c));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(18[8] 23[4])
    defparam led_13.GSR = "ENABLED";
    OB data_out_pad_28 (.I(GND_net), .O(data_out[28]));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(13[20:28])
    OB data_out_pad_29 (.I(GND_net), .O(data_out[29]));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(13[20:28])
    OB data_out_pad_30 (.I(GND_net), .O(data_out[30]));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(13[20:28])
    PUR PUR_INST (.PUR(VCC_net));
    defparam PUR_INST.RST_PULSE = 1;
    VLO i1 (.Z(GND_net));
    OB data_out_pad_26 (.I(GND_net), .O(data_out[26]));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(13[20:28])
    OB data_out_pad_25 (.I(GND_net), .O(data_out[25]));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(13[20:28])
    OB data_out_pad_24 (.I(GND_net), .O(data_out[24]));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(13[20:28])
    OB data_out_pad_23 (.I(GND_net), .O(data_out[23]));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(13[20:28])
    OB data_out_pad_22 (.I(GND_net), .O(data_out[22]));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(13[20:28])
    OB data_out_pad_21 (.I(GND_net), .O(data_out[21]));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(13[20:28])
    OB data_out_pad_20 (.I(GND_net), .O(data_out[20]));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(13[20:28])
    OB data_out_pad_19 (.I(GND_net), .O(data_out[19]));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(13[20:28])
    OB data_out_pad_18 (.I(GND_net), .O(data_out[18]));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(13[20:28])
    OB data_out_pad_17 (.I(GND_net), .O(data_out[17]));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(13[20:28])
    OB data_out_pad_16 (.I(GND_net), .O(data_out[16]));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(13[20:28])
    OB data_out_pad_15 (.I(GND_net), .O(data_out[15]));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(13[20:28])
    OB data_out_pad_14 (.I(GND_net), .O(data_out[14]));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(13[20:28])
    OB data_out_pad_13 (.I(GND_net), .O(data_out[13]));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(13[20:28])
    OB data_out_pad_12 (.I(GND_net), .O(data_out[12]));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(13[20:28])
    OB data_out_pad_11 (.I(GND_net), .O(data_out[11]));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(13[20:28])
    OB data_out_pad_10 (.I(GND_net), .O(data_out[10]));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(13[20:28])
    OB data_out_pad_9 (.I(GND_net), .O(data_out[9]));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(13[20:28])
    OB data_out_pad_8 (.I(GND_net), .O(data_out[8]));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(13[20:28])
    OB data_out_pad_7 (.I(GND_net), .O(data_out[7]));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(13[20:28])
    OB data_out_pad_6 (.I(GND_net), .O(data_out[6]));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(13[20:28])
    OB data_out_pad_5 (.I(GND_net), .O(data_out[5]));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(13[20:28])
    OB data_out_pad_4 (.I(GND_net), .O(data_out[4]));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(13[20:28])
    OB data_out_pad_3 (.I(GND_net), .O(data_out[3]));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(13[20:28])
    OB data_out_pad_2 (.I(GND_net), .O(data_out[2]));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(13[20:28])
    OB data_out_pad_1 (.I(GND_net), .O(data_out[1]));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(13[20:28])
    OB data_out_pad_0 (.I(data_out_0_0), .O(data_out[0]));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(13[20:28])
    OB led_pad (.I(led_c), .O(led));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(15[13:16])
    IB clk_pad (.I(clk), .O(clk_c));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(5[13:16])
    IB rst_n_pad (.I(rst_n), .O(rst_n_c));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(6[13:18])
    IB address_pad_3 (.I(address[3]), .O(address_c_3));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(8[19:26])
    IB address_pad_2 (.I(address[2]), .O(address_c_2));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(8[19:26])
    IB address_pad_1 (.I(address[1]), .O(address_c_1));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(8[19:26])
    IB address_pad_0 (.I(address[0]), .O(address_c_0));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(8[19:26])
    IB write_en_pad (.I(write_en), .O(write_en_c));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(9[13:21])
    IB read_en_pad (.I(read_en), .O(read_en_c));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(10[13:20])
    IB data_in_pad_0 (.I(data_in[0]), .O(data_in_c_0));   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(12[20:27])
    LUT4 i3_4_lut (.A(address_c_0), .B(address_c_3), .C(address_c_2), 
         .D(address_c_1), .Z(n106)) /* synthesis lut_function=(A+(B+(C+(D)))) */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(26[16:31])
    defparam i3_4_lut.init = 16'hfffe;
    LUT4 i2_3_lut (.A(read_en_c), .B(n106), .C(led_c), .Z(data_out_0_0)) /* synthesis lut_function=(!((B+!(C))+!A)) */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(29[3:20])
    defparam i2_3_lut.init = 16'h2020;
    LUT4 i23_1_lut (.A(rst_n_c), .Z(n51)) /* synthesis lut_function=(!(A)) */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(6[13:18])
    defparam i23_1_lut.init = 16'h5555;
    LUT4 i24_3_lut (.A(rst_n_c), .B(write_en_c), .C(n106), .Z(clk_c_enable_1)) /* synthesis lut_function=(!(A ((C)+!B))) */ ;   // c:/users/guilherme blanco/desktop/college/embarcatechfase3/projetotinyqv/projetotinyqv/led.v(18[8] 23[4])
    defparam i24_3_lut.init = 16'h5d5d;
    
endmodule
//
// Verilog Description of module PUR
// module not written out since it is a black-box. 
//

