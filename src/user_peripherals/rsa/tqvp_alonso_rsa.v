/*
 * Copyright (c) 2025 Caio Alonso da Costa
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

// Change the name of this module to something that reflects its functionality and includes your name for uniqueness
// For example tqvp_yourname_spi for an SPI peripheral.
// Then edit tt_wrapper.v line 38 and change tqvp_example to your chosen module name.
module tqvp_alonso_rsa (
  input         clk,          // Clock - the TinyQV project clock is normally set to 64MHz.
  input         rst_n,        // Reset_n - low to reset.

  input  [7:0]  ui_in,        // The input PMOD, always available.  Note that ui_in[7] is normally used for UART RX.
                              // The inputs are synchronized to the clock, note this will introduce 2 cycles of delay on the inputs.

  output [7:0]  uo_out,       // The output PMOD.  Each wire is only connected if this peripheral is selected.
                              // Note that uo_out[0] is normally used for UART TX.

  input [3:0]   address,      // Address within this peripheral's address space

  input         data_write,   // Data write request from the TinyQV core.
  input [7:0]   data_in,      // Data in to the peripheral, valid when data_write is high.

  output [7:0]  data_out      // Data out from the peripheral, set this in accordance with the supplied address
);

  // Address 0 - Test register - RW
  reg [7:0] test_reg;
  // Address 1 - Command register - RW - Start (Bit[0]) and Stop (Bit[1])
  reg [7:0] cmd_reg;
  // Address 2 - Plain Text register - RW
  reg [7:0] plain_text_reg;
  // Address 3 - Private key (Exponent) register - RW
  reg [7:0] private_key_exp_reg;
  // Address 4 - Private key (Modulus) register - RW
  reg [7:0] private_key_mod_reg;
  // Address 5 - Montgomery Constant register - RW
  reg [7:0] montgomery_const_reg;

  // Address 6 - Encrypted data registers - RO
  wire [7:0] encrypt_data;
  // Address 7 - Encryption machine status - R0 - Completed (Bit[0])
  wire [7:0] encrypt_status;

  // Implemente registers
  always @(posedge clk) begin
    if (!rst_n) begin
      test_reg <= 0;
      cmd_reg  <= 0;
      plain_text_reg <= 0;
      private_key_exp_reg <= 0;
      private_key_mod_reg <= 0;
      montgomery_const_reg <= 0;
    end else begin
      if (address == 4'h0) begin
        if (data_write) begin
          test_reg <= data_in;
        end
      end
      if (address == 4'h1) begin
        if (data_write) begin
          cmd_reg <= data_in;
        end
      end
      if (address == 4'h2) begin
        if (data_write) begin
          plain_text_reg <= data_in;
        end
      end
      if (address == 4'h3) begin
        if (data_write) begin
          private_key_exp_reg <= data_in;
        end
      end
      if (address == 4'h4) begin
        if (data_write) begin
          private_key_mod_reg <= data_in;
        end
      end
      if (address == 4'h5) begin
        if (data_write) begin
          montgomery_const_reg <= data_in;
        end
      end
    end
  end

  // Tie low extra bits of encrypt_status
  assign encrypt_status[7:1] = '0;

  // Drive 7-seg Display with data from test register.
  assign uo_out  = test_reg;

  // Data out address muxes logic
  assign data_out = (address == 4'h0) ? test_reg :
                    (address == 4'h1) ? cmd_reg  :
                    (address == 4'h2) ? plain_text_reg  :
                    (address == 4'h3) ? private_key_exp_reg  :
                    (address == 4'h4) ? private_key_mod_reg  :
                    (address == 4'h5) ? montgomery_const_reg :
                    (address == 4'h6) ? encrypt_data :
                    (address == 4'h7) ? encrypt_status :
                    8'h0;

  // Assign unused inputs
  wire _unused = &{ui_in, 1'b0};

  // Aux
  wire ena_rsa, clear_rsa, eoc_rsa;

  // RSA core controller
  rsa_en_logic rsa_en_logic_i (.rstb(rst_n), .clk(clk), .ena(1'b1), .start(cmd_reg[0]), .stop(cmd_reg[1]),
                               .en_rsa(ena_rsa), .clear_rsa(clear_rsa), .eoc_rsa(eoc_rsa), .irq(encrypt_status[0]));

  // RSA Instance
  rsa_unit #(.WIDTH(8)) rsa_unit_i (.rstb(rst_n), .clk(clk), .ena(ena_rsa), .clear(clear_rsa),  .P(plain_text_reg), .E(private_key_exp_reg),
                                            .M(private_key_mod_reg), .Const(montgomery_const_reg),
                                            .eoc(eoc_rsa), .C(encrypt_data));

endmodule
