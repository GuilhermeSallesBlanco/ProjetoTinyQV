module top (
input wire clk ,
output reg led
) ;

reg [31:0] counter ;

initial begin
    counter = 32'h0 ;
    led = 1'b0 ;
end

always @ ( posedge clk ) begin
    if ( counter < 32'd12500000 ) begin
        counter <= counter + 1'b1 ;
    end else begin
        counter <= 32'h0 ;
        led <= ~ led ;
    end
end

endmodule