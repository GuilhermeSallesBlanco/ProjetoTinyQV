// -------------------------------------------------------------
// Minimal peripheral block for TinyQV
// Provides:
//   - UART RX/TX
//   - 8-bit GPIO register
// -------------------------------------------------------------

module peripherals_min (
    input              clk,
    input              resetn,

    // Bus interface
    input       [31:0] addr,
    input       [31:0] wdata,
    output reg  [31:0] rdata,
    input              we,       // write enable
    input              valid,
    output reg         ready,

    // UART pins
    input              uart_rx_pin,
    output             uart_tx_pin,

    // GPIO (8-bit)
    input       [7:0]  gpio_in,
    output reg  [7:0]  gpio_out
);

    // ---------------------------------------------------------
    // Address map (simplified)
    // ---------------------------------------------------------
    localparam ADDR_UART_TX  = 32'h0000_0000;   // write = send byte
    localparam ADDR_UART_RX  = 32'h0000_0004;   // read = receive byte
    localparam ADDR_UART_STATUS = 32'h0000_0008;// [0]=rx_ready, [1]=tx_busy

    localparam ADDR_GPIO_OUT = 32'h0000_0010;   // write
    localparam ADDR_GPIO_IN  = 32'h0000_0014;   // read

    // ---------------------------------------------------------
    // UART
    // ---------------------------------------------------------
    wire        uart_rx_ready;
    wire [7:0]  uart_rx_data;

    uart_rx uart_rx_inst (
        .clk(clk),
        .resetn(resetn),
        .rx(uart_rx_pin),
        .data(uart_rx_data),
        .valid(uart_rx_ready)
    );

    reg        uart_tx_start = 0;
    reg [7:0]  uart_tx_data  = 0;
    wire       uart_tx_busy;

    uart_tx uart_tx_inst (
        .clk(clk),
        .resetn(resetn),
        .start(uart_tx_start),
        .data(uart_tx_data),
        .tx(uart_tx_pin),
        .busy(uart_tx_busy)
    );

    // ---------------------------------------------------------
    // Peripheral decode
    // ---------------------------------------------------------
    always @(posedge clk) begin
        if (!resetn) begin
            ready    <= 0;
            rdata    <= 0;
            gpio_out <= 0;
            uart_tx_start <= 0;
        end else begin
            ready <= 0;
            uart_tx_start <= 0;

            if (valid && !ready) begin
                ready <= 1;

                // ------------------------------
                // Writes
                // ------------------------------
                if (we) begin
                    case (addr)
                        ADDR_UART_TX: begin
                            if (!uart_tx_busy) begin
                                uart_tx_data  <= wdata[7:0];
                                uart_tx_start <= 1;
                            end
                        end

                        ADDR_GPIO_OUT: begin
                            gpio_out <= wdata[7:0];
                        end
                    endcase
                end

                // ------------------------------
                // Reads
                // ------------------------------
                case (addr)
                    ADDR_UART_RX:
                        rdata <= {24'd0, uart_rx_data};

                    ADDR_UART_STATUS:
                        rdata <= {30'd0, uart_tx_busy, uart_rx_ready};

                    ADDR_GPIO_IN:
                        rdata <= {24'd0, gpio_in};

                    ADDR_GPIO_OUT:
                        rdata <= {24'd0, gpio_out};

                    default:
                        rdata <= 32'd0;
                endcase
            end
        end
    end

endmodule
