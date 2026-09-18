// UART receiver for the core-board CH340 interface.
// 50 MHz clock, 115200 baud, 8 data bits, no parity, 1 stop bit.
module uart_rx #(
    parameter integer CLKS_PER_BIT = 434
)(
    input             clk,
    input             rst,
    input             rx,
    output reg [7:0]  data,
    output reg        data_valid
);

    localparam [1:0] S_IDLE  = 2'd0;
    localparam [1:0] S_START = 2'd1;
    localparam [1:0] S_DATA  = 2'd2;
    localparam [1:0] S_STOP  = 2'd3;

    reg [1:0] state;
    reg [15:0] clk_count;
    reg [2:0] bit_index;
    reg rx_meta;
    reg rx_sync;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            state      <= S_IDLE;
            clk_count  <= 16'd0;
            bit_index  <= 3'd0;
            data       <= 8'd0;
            data_valid <= 1'b0;
            rx_meta    <= 1'b1;
            rx_sync    <= 1'b1;
        end else begin
            rx_meta    <= rx;
            rx_sync    <= rx_meta;
            data_valid <= 1'b0;

            case (state)
                S_IDLE: begin
                    clk_count <= 16'd0;
                    bit_index <= 3'd0;
                    if (!rx_sync)
                        state <= S_START;
                end

                S_START: begin
                    if (clk_count == (CLKS_PER_BIT / 2)) begin
                        clk_count <= 16'd0;
                        if (!rx_sync)
                            state <= S_DATA;
                        else
                            state <= S_IDLE;
                    end else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                S_DATA: begin
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 16'd0;
                        data[bit_index] <= rx_sync;
                        if (bit_index == 3'd7)
                            state <= S_STOP;
                        else
                            bit_index <= bit_index + 1'b1;
                    end else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                S_STOP: begin
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 16'd0;
                        state <= S_IDLE;
                        if (rx_sync)
                            data_valid <= 1'b1;
                    end else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                default: state <= S_IDLE;
            endcase
        end
    end

endmodule
