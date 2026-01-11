/*
 * Copyright (c) 2025 Michael Bell
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

// Wrapper for all TinyQV peripherals
//
// Address space:
// 0x800_0000 - 03f: Reserved by project wrapper (time, debug, etc)
// 0x800_0040 - 07f: GPIO configuration
// 0x800_0080 - 0bf: UART TX
// 0x800_00c0 - 0ff: UART RX
// 0x800_0100 - 3ff: 12 user peripherals (64 bytes each, word and halfword access supported, each has an interrupt)
// 0x800_0400 - 4ff: 16 simple peripherals (16 bytes each, byte access only)
module peripherals_min #(parameter CLOCK_MHZ=64) (
    input wire        clk,
    input wire        rst_n,

    input wire [7:0]  ui_in,        // The input PMOD, always available
    output wire [7:0]  uo_out,       // The output PMOD.  Each wire is only connected if this peripheral is selected

    input wire [10:0]  addr_in,
    input wire [31:0]  data_in,      // Data in to the peripheral, bottom 8, 16 or all 32 bits are valid on write.

    // Data read and write requests from the TinyQV core.
    input wire [1:0]   data_write_n, // 11 = no write, 00 = 8-bits, 01 = 16-bits, 10 = 32-bits
    input wire [1:0]   data_read_n,  // 11 = no read,  00 = 8-bits, 01 = 16-bits, 10 = 32-bits

    output wire[31:0] data_out,     // Data out from the peripheral, bottom 8, 16 or all 32 bits are valid on read when data_ready is high.
    output wire       data_ready,

    input wire        data_read_complete,  // Set by TinyQV when a read is complete

    output wire [15:2] user_interrupts  // User peripherals get interrupts 2-15
);

    // Registered data out to TinyQV
    reg  [31:0] data_out_r;
    reg         data_out_hold;
    reg         data_ready_r;

    wire        read_req = data_read_n != 2'b11;

    // Muxed data out direct from selected peripheral
    reg [31:0] data_from_peri;
    reg        data_ready_from_peri;

    // Must mask the data_read_n to avoid extra read while
    // buffering the result
    wire [1:0] data_read_n_peri;
    assign data_read_n_peri = data_read_n | {2{data_ready_r}};

    wire [31:0] data_from_user_peri   [0:15];
    wire [7:0]  data_from_simple_peri [0:15];
    wire        data_ready_from_user_peri   [0:15];

    wire [7:0]  uo_out_from_user_peri   [0:15];
    wire [7:0]  uo_out_from_simple_peri [0:15];
    reg [7:0] uo_out_comb;
    assign uo_out = uo_out_comb;

    // Register the data output from the peripheral.  This improves timing and
    // also simplifies the peripheral interface (no need for the peripheral to care
    // about holding data_out until data_read_complete - it looks like it is read
    // synchronously).
    always @(posedge clk) begin
        if (!rst_n) begin
            data_out_hold <= 0;
        end else begin
            if (data_read_complete) data_out_hold <= 0;

            if (!data_out_hold && data_ready_from_peri && data_read_n != 2'b11) begin
                data_out_hold <= 1;
                data_out_r <= data_from_peri;
            end

            // Data ready must be registered because data_out is.
            data_ready_r <= read_req && data_ready_from_peri;
        end
    end

    assign data_out = data_out_r;
    assign data_ready = data_ready_r || data_write_n != 2'b11;

    // --------------------------------------------------------------------- //
    // Decode the address to select the active peripheral

    localparam PERI_GPIO = 1;
    localparam PERI_UART = 2;
	localparam PERI_LED = 8; // Antigo, usando o template full de periférico
	localparam SIMPLE_LED = 0; // Novo template, mais simples
	
	// Periféricos simples ocupam 0x800_0400 -> 0x800_04FF
	// Periféricos completos ocupam 0x800_0100 -> 0x800_03FF

    reg [15:0] peri_user;
    reg [15:0] peri_simple;

    always @(*) begin
        peri_user = 0;
        peri_simple = 0;

        if (addr_in[10]) begin
            peri_simple[addr_in[7:4]] = 1;
            data_from_peri = {24'h0, data_from_simple_peri[addr_in[7:4]]};
            data_ready_from_peri = 1;
        end else begin
            peri_user[addr_in[9:6]] = 1;
            data_from_peri = data_from_user_peri[addr_in[9:6]];
            data_ready_from_peri = data_ready_from_user_peri[addr_in[9:6]];
        end
    end

    assign data_from_user_peri[0] = 32'h0;
    assign data_ready_from_user_peri[0] = 0;
    assign uo_out_from_user_peri[0] = 8'h0;

    // --------------------------------------------------------------------- //
    // GPIO

    reg [4:0] gpio_out_func_sel [0:7];
    reg [7:0] gpio_out;

    always @(posedge clk) begin
        if (!rst_n) begin
            gpio_out <= 0;
        end else if (peri_user[PERI_GPIO]) begin
            if (addr_in[5:0] == 6'h0) begin
                if (data_write_n != 2'b11) gpio_out <= data_in[7:0];
            end
        end
    end

    assign data_from_user_peri[PERI_GPIO] = (addr_in[5:0] == 6'h0) ? {24'h0, gpio_out} :
                                            (addr_in[5:0] == 6'h4) ? {24'h0, ui_in}    :
                                            ({addr_in[5], addr_in[1:0]} == 3'b100) ? {27'h0, gpio_out_func_sel[addr_in[4:2]]} :
                                            32'h0;
    assign data_ready_from_user_peri[PERI_GPIO] = 1;
    assign uo_out_from_user_peri[PERI_GPIO] = gpio_out;

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin
            always @(posedge clk) begin
                if (!rst_n) begin
                    gpio_out_func_sel[i] <= (i == 0 || i == 1) ? PERI_UART : PERI_GPIO;
                end else if (peri_user[PERI_GPIO]) begin
                    if ({addr_in[5], addr_in[1:0]} == 3'b100 && addr_in[4:2] == i) begin
                        if (data_write_n != 2'b11) gpio_out_func_sel[i] <= data_in[4:0];
                    end
                end
            end

            always @(*) begin
                uo_out_comb[i] = 0;

                if (gpio_out_func_sel[i][4]) begin
                    uo_out_comb[i] = uo_out_from_simple_peri[gpio_out_func_sel[i][3:0]][i];
                end else begin
                    uo_out_comb[i] = uo_out_from_user_peri[gpio_out_func_sel[i][3:0]][i];
                end
            end
        end
    endgenerate

    // --------------------------------------------------------------------- //
    // UART

 //   tqvp_uart_wrapper #(.CLOCK_MHZ(CLOCK_MHZ)) i_uart (
 //       .clk(clk),
 //       .rst_n(rst_n),

 //       .ui_in(ui_in),
 //       .uo_out(uo_out_from_user_peri[PERI_UART]),

 //       .address(addr_in[5:0]),
 //       .data_in(data_in),

 //       .data_write_n(data_write_n    | {2{~peri_user[PERI_UART]}}),
 //       .data_read_n(data_read_n_peri | {2{~peri_user[PERI_UART]}}),

 //      .data_out(data_from_user_peri[PERI_UART]),
 //       .data_ready(data_ready_from_user_peri[PERI_UART]),

 //       .user_interrupt(user_interrupts[PERI_UART+1:PERI_UART])
 //   );
 
 
	wire [1:0] uart_write_n = peri_user[PERI_UART] ? data_write_n     : 2'b11;
	wire [1:0] uart_read_n  = peri_user[PERI_UART] ? data_read_n_peri : 2'b11;

	tqvp_uart_wrapper #(.CLOCK_MHZ(CLOCK_MHZ)) i_uart (
		.clk(clk),
		.rst_n(rst_n),
		.ui_in(ui_in),
		.uo_out(uo_out_from_user_peri[PERI_UART]),
		.address(addr_in[5:0]),
		.data_in(data_in),
		.data_write_n(uart_write_n),     // <-- usa o wire
		.data_read_n(uart_read_n),       // <-- usa o wire
		.data_out(data_from_user_peri[PERI_UART]),
		.data_ready(data_ready_from_user_peri[PERI_UART]),
		.user_interrupt(user_interrupts[PERI_UART+1:PERI_UART])
	);


    // There is no peripheral 3, UART uses its interrupt.
    assign uo_out_from_user_peri[3] = 8'h0;
    assign data_from_user_peri[3] = 32'h0;
    assign data_ready_from_user_peri[3] = 1;

    // --------------------------------------------------------------------- //
    
	// Integracao do periferico COMPLETO de LED
	// Seu endereco é supostamente 0x800_0200
	//wire 		 led_out;
	//wire [31:0] led_data_out;
	
	//led i_led (
		//.clk(clk),
		//.rst_n(rst_n),

		//.address(addr_in[3:0]),
		//.write_en(peri_user[PERI_LED] && data_write_n != 2'b11),
		//.read_en (peri_user[PERI_LED] && data_read_n  != 2'b11),

		//.data_in(data_in),
		//.data_out(led_data_out),

		//.led(led_out)
	//);
	
	//assign data_from_user_peri[PERI_LED] = led_data_out;
	//assign data_ready_from_user_peri[PERI_LED] = 1'b1;
	//assign uo_out_from_user_peri[PERI_LED] = {7'b0, ~led_out};
	
	//assign data_from_user_peri[PERI_LED+1] = 32'h0;
	//assign data_ready_from_user_peri[PERI_LED+1] = 1'b0;
	//assign uo_out_from_user_peri[PERI_LED+1] = 8'h0;
	
	
	// --------------------------------------------------------------------- //
	// LED - Periférico simples

	wire [7:0] led_simple_uo_out;
	wire [7:0] led_simple_data_out;

	tqvp_led_byte i_led_byte (
		.clk       (clk),
		.rst_n     (rst_n),

		.ui_in     (ui_in),
		.uo_out    (led_simple_uo_out),

		.address   (addr_in[3:0]),

		// Simple peripheral: write é somente quando largura = 8 bits (00)
		.data_write(peri_simple[SIMPLE_LED] && (data_write_n == 2'b00)),
		.data_in   (data_in[7:0]),

		.data_out  (led_simple_data_out)
	);

	// Amarra as saídas do periférico simples ao barramento de simples
	assign data_from_simple_peri[SIMPLE_LED]   = led_simple_data_out;
	assign uo_out_from_simple_peri[SIMPLE_LED] = led_simple_uo_out;


endmodule