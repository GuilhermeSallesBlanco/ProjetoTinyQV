module peripherals_min #(
    parameter CLOCK_MHZ = 50
)(
    input  wire clk,
    input  wire rst_n,

    // GPIO
    input  wire [7:0] ui_in,
    output reg  [7:0] uo_out,

    // Bus interface from tinyQV core
    input  wire [10:0] addr_in,
    input  wire [31:0] data_in,
    input  wire [1:0]  data_write_n,
    input  wire [1:0]  data_read_n,

    output reg  [31:0] data_out,
    output reg         data_ready,
    input  wire        data_read_complete,

    output wire [15:2] user_interrupts
);

    //------------------------------------------------------------
    // Address decoding (full 32-bit MMIO)
    //------------------------------------------------------------
    localparam UART_TX_ADDR  = 32'h4000_0000;
    localparam UART_RX_ADDR  = 32'h4000_0004;
    localparam UART_ST_ADDR  = 32'h4000_0008;
    localparam GPIO_OUT_ADDR = 32'h4000_0010;
    localparam GPIO_IN_ADDR  = 32'h4000_0014;

    wire write_en = (data_write_n == 2'b10); // tinyQV: write = 10b
    wire read_en  = (data_read_n  == 2'b10); // tinyQV: read  = 10b

    // Expand 11-bit addr to 32-bit region
    wire [31:0] full_addr = {21'b0, addr_in};

    //------------------------------------------------------------
    // UART wires
    //------------------------------------------------------------
    wire uart_tx_busy;
    reg  uart_tx_en;
    reg  [7:0] uart_tx_data;

    wire uart_rx_valid;
    wire [7:0] uart_rx_data;
    reg  uart_rx_read;

    //------------------------------------------------------------
    // UART TX instance
    //------------------------------------------------------------
    uart_tx #(
        .CLK_HZ(CLOCK_MHZ * 1_000_000),
        .BIT_RATE(9600)
    ) UART_TX_I (
        .clk(clk),
        .resetn(rst_n),
        .uart_txd(),            // top level connects elsewhere
        .uart_tx_busy(uart_tx_busy),
        .uart_tx_en(uart_tx_en),
        .uart_tx_data(uart_tx_data)
    );

    //------------------------------------------------------------
    // UART RX instance
    //------------------------------------------------------------
    uart_rx #(
        .CLK_HZ(CLOCK_MHZ * 1_000_000),
        .BIT_RATE(9600)
    ) UART_RX_I (
        .clk(clk),
        .resetn(rst_n),
        .uart_rxd(ui_in[0]),   // assume GPIO0 = RX input pin
        .uart_rts(),           // not used
        .uart_rx_read(uart_rx_read),
        .uart_rx_valid(uart_rx_valid),
        .uart_rx_data(uart_rx_data)
    );

    //------------------------------------------------------------
    // GPIO OUT register
    //------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            uo_out <= 8'd0;
        else if (write_en && full_addr == GPIO_OUT_ADDR)
            uo_out <= data_in[7:0];
    end

    //------------------------------------------------------------
    // UART TX write
    //------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            uart_tx_en   <= 1'b0;
            uart_tx_data <= 8'd0;
        end else begin
            uart_tx_en <= 1'b0;

            if (write_en && full_addr == UART_TX_ADDR && !uart_tx_busy) begin
                uart_tx_en   <= 1'b1;
                uart_tx_data <= data_in[7:0];
            end
        end
    end

    //------------------------------------------------------------
    // UART RX read acknowledge
    //------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            uart_rx_read <= 1'b0;
        else
            uart_rx_read <= (read_en && full_addr == UART_RX_ADDR);
    end

    //------------------------------------------------------------
    // Read logic
    //------------------------------------------------------------
    always @(*) begin
        data_out = 32'd0;

        case (full_addr)
            UART_RX_ADDR:  data_out = {24'd0, uart_rx_data};
            UART_ST_ADDR:  data_out = {30'd0, uart_tx_busy, uart_rx_valid};
            GPIO_IN_ADDR:  data_out = {24'd0, ui_in};
            default:       data_out = 32'd0;
        endcase
    end

    //------------------------------------------------------------
    // Immediate read-ready
    //------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            data_ready <= 1'b0;
        else
            data_ready <= read_en;
    end

    //------------------------------------------------------------
    // No interrupts
    //------------------------------------------------------------
    assign user_interrupts = 0;

endmodule
