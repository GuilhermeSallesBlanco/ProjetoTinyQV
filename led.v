// Periférico para fazer com que o LED da FPGA pisque.
// O periférico é chamado por peripherals_min, que manda para top.v.

module led (
	input wire clk,
	input wire rst_n,
	
	input wire [3:0] address,
	input wire write_en,
	input wire read_en,
	
	input wire [31:0] data_in,
	output reg [31:0] data_out,
	
	output reg led
);

always @(posedge clk or negedge rst_n) begin
	if(!rst_n)
		led<=1'b1;
	else if (write_en && address == 4'h0)
		led <= data_in[0];
end

always @(*) begin
	if(read_en && address == 4'h0)
		data_out = {31'b0, led};
	else
		data_out = 32'h0;
end

endmodule