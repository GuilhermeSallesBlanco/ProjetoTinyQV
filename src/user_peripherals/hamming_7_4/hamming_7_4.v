/*
 * Copyright (c) 2025 Enmanuel Rodriguez
 * SPDX-License-Identifier: Apache-2.0
 */
`default_nettype none
module hamming_7_4 (
    input clk,
    input rst_n,
    input [7:0] ui_in,
    output [7:0] uo_out,
    input [3:0] address,
    input data_write,
    input [7:0] data_in,
    output [7:0] data_out
);

// Internal registers
reg [3:0] data_enc_in;
reg [6:0] encoded;
reg [6:0] received;
reg [3:0] decoded;
reg [2:0] syndrome;

// Hamming (7,4) encoder parity calculation
// Bit layout: {d3, d2, d1, p2, d0, p1, p0}
function [2:0] calc_parity;
    input [3:0] data_bits;
    begin
        calc_parity[0] = data_bits[0] ^ data_bits[1] ^ data_bits[3]; // p0
        calc_parity[1] = data_bits[0] ^ data_bits[2] ^ data_bits[3]; // p1
        calc_parity[2] = data_bits[1] ^ data_bits[2] ^ data_bits[3]; // p2
    end
endfunction

// Syndrome calculation for error detection
function [2:0] calc_syndrome;
    input [6:0] recv_data;
    begin
        calc_syndrome[0] = recv_data[0] ^ recv_data[2] ^ recv_data[4] ^ recv_data[6];
        calc_syndrome[1] = recv_data[1] ^ recv_data[2] ^ recv_data[5] ^ recv_data[6];
        calc_syndrome[2] = recv_data[3] ^ recv_data[4] ^ recv_data[5] ^ recv_data[6];
    end
endfunction

// Single-bit error correction
function [6:0] correct_errors;
    input [6:0] recv_data;
    input [2:0] syndrome_val;
    begin
        correct_errors = recv_data;
        case (syndrome_val)
            3'b001: correct_errors[0] = ~recv_data[0];
            3'b010: correct_errors[1] = ~recv_data[1];
            3'b011: correct_errors[2] = ~recv_data[2];
            3'b100: correct_errors[3] = ~recv_data[3];
            3'b101: correct_errors[4] = ~recv_data[4];
            3'b110: correct_errors[5] = ~recv_data[5];
            3'b111: correct_errors[6] = ~recv_data[6];
            default: correct_errors = recv_data;
        endcase
    end
endfunction

// Extract data bits from corrected codeword
function [3:0] extract_data;
    input [6:0] corrected_data;
    begin
        extract_data = {corrected_data[6], corrected_data[5], corrected_data[4], corrected_data[2]};
    end
endfunction

// Combinational calculations
wire [2:0] parity_bits = calc_parity(data_in[3:0]);
wire [2:0] syndrome_calc = calc_syndrome(data_in[6:0]);
wire [6:0] corrected_data = correct_errors(data_in[6:0], syndrome_calc);
wire [3:0] extracted_data = extract_data(corrected_data);

// Register updates
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        data_enc_in <= 4'b0;
        encoded <= 7'b0;
        received <= 7'b0;
        decoded <= 4'b0;
        syndrome <= 3'b0;
    end else begin
        // Encoder operation
        if (data_write && address == 4'h0) begin
            data_enc_in <= data_in[3:0];
            encoded <= {data_in[3], data_in[2], data_in[1], parity_bits[2], 
                       data_in[0], parity_bits[1], parity_bits[0]};
        end
        
        // Decoder operation
        if (data_write && address == 4'h3) begin
            received <= data_in[6:0];
            syndrome <= syndrome_calc;
            decoded <= extracted_data;
        end
    end
end

// Memory-mapped register reads
assign data_out = (address == 4'h0) ? {4'b0, data_enc_in} :
                  (address == 4'h1) ? {1'b0, encoded} :
                  (address == 4'h2) ? {1'b0, received} :
                  (address == 4'h3) ? {4'b0, decoded} :
                  (address == 4'h4) ? {5'b0, syndrome} :
                  8'h0;

assign uo_out = 8'h00;

endmodule