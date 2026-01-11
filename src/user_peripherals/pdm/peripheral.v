/*
 * Copyright (c) 2025 Jon Nordby, Martin Stensgård
 * SPDX-License-Identifier: ISC
 */

`default_nettype none

module tqvp_jnms_pdm (
    input         clk,          // Clock - the TinyQV project clock is normally set to 64MHz.
    input         rst_n,        // Reset_n - low to reset.

    input  [7:0]  ui_in,        // The input PMOD, always available.  Note that ui_in[7] is normally used for UART RX.
                                // The inputs are synchronized to the clock, note this will introduce 2 cycles of delay on the inputs.

    output [7:0]  uo_out,       // The output PMOD.  Each wire is only connected if this peripheral is selected.
                                // Note that uo_out[0] is normally used for UART TX.

    input [5:0]   address,      // Address within this peripheral's address space
    input [31:0]  data_in,      // Data in to the peripheral, bottom 8, 16 or all 32 bits are valid on write.

    // Data read and write requests from the TinyQV core.
    input [1:0]   data_write_n, // 11 = no write, 00 = 8-bits, 01 = 16-bits, 10 = 32-bits
    input [1:0]   data_read_n,  // 11 = no read,  00 = 8-bits, 01 = 16-bits, 10 = 32-bits
    
    output [31:0] data_out,     // Data out from the peripheral, bottom 8, 16 or all 32 bits are valid on read when data_ready is high.
    output        data_ready,

    output        user_interrupt  // Dedicated interrupt request for this peripheral
);
    wire rst = !rst_n;

    reg [0:0] pdm_enable;
    reg [7:0] pdm_period;
    reg [2:0] pdm_select;

    reg [7:0] pdm_phase;
    reg       pdm_clk;
    (* keep *) reg       pdm_int;

    reg [15:0] pcm;
    wire        pcm_valid;
    wire [15:0] pcm_from_filter;

    wire pdm_clk_out = pdm_enable[0] & pdm_clk;
    wire pdm_dat_in = ui_in[pdm_select];

    cic3_pdm  cic(pdm_clk, rst, pdm_dat_in, pcm_from_filter, pcm_valid);

    always @(posedge clk) begin
        if (!rst_n) begin
            pdm_enable <= 0;
            pdm_period <= 0;
            pdm_select <= 0;
            pdm_phase <= 0;
            pdm_clk <= 0;
        end else begin
            if (data_write_n != 2'b11) begin
                if (address == 6'h0) pdm_enable[0]   <= data_in[0];
                if (address == 6'h4) pdm_period[7:0] <= data_in[7:0];
                if (address == 6'h8) pdm_select[2:0] <= data_in[2:0];
            end
            pdm_clk   <= pdm_phase   < (pdm_period >> 1);
            pdm_phase <= pdm_phase+1 < pdm_period ? pdm_phase+1 : 0;
        end
    end

    assign uo_out = {pdm_clk_out, pdm_clk_out, pdm_clk_out, pdm_clk_out, pdm_clk_out, pdm_clk_out, pdm_clk_out, pdm_clk_out};

    assign data_out = (address == 6'h0) ? {31'h0, pdm_enable} :
                      (address == 6'h4) ? {24'h0, pdm_period} :
                      (address == 6'h8) ? {29'h0, pdm_select} :
                      (address == 6'hc) ? {16'h0, pcm} :
                      32'h0;

    assign data_ready = 1;

    always @(posedge clk) begin
        if (!rst_n) begin
            pdm_int <= 0;
            pcm <= 0;
        end else begin
            if (pdm_enable[0] & pcm_valid) begin
                pcm <= pcm_from_filter;
                pdm_int <= 1;
            end else if (address == 6'hc && data_read_n != 2'b11) begin
                pdm_int <= 0;
            end else begin
                // Hold current values
                pdm_int <= pdm_int;
                pcm <= pcm;
            end
        end
    end

    assign user_interrupt = pdm_int;

    wire _unused = &{data_read_n, 1'b0};

endmodule
