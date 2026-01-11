// Periférico para fazer com que o LED da FPGA pisque.
// O periférico é chamado por peripherals_min, que manda para top.v.

// Periférico de LED (Byte interface TinyQV/TinyTapeout template)
// address: 4'h0 -> controle (bit0 = LED ON/OFF)
// address: 4'h1 -> status
module tqvp_led_byte (
    input wire        clk,
    input wire        rst_n,

    input wire [7:0]  ui_in,     // não usado aqui, mas exigido pelo template
    output wire [7:0]  uo_out,    // bit escolhido para LED
    input wire [3:0]  address,
    input wire        data_write,
    input wire [7:0]  data_in,
    output wire [7:0]  data_out
);

    reg led_state;

    // Escrita
    always @(posedge clk) begin
        if (!rst_n) begin
            led_state <= 1'b0;
        end else if (data_write && address == 4'h0) begin
            led_state <= data_in[0];
        end
    end

    // Leitura
    assign data_out = (address == 4'h0) ? {7'b0, led_state} :
                      (address == 4'h1) ? {7'b0, led_state} :
                      8'h00;

    // Saída — escolha um bit, ex.: uo_out[7] = led_state (ou ~led_state se ativo-baixo)
    assign uo_out = {7'b0, ~led_state};  // LED no bit 7

endmodule
