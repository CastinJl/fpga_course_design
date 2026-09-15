// Fixed binary data source for the ASK/OOK demonstration.
// The pattern is 0,1,0,0,1,1,1,0,0; each bit lasts about 100 us.
module ask_data_gen(
    input             clk,
    input             rst,
    output            data_bit
);

    localparam integer BIT_HOLD_CYCLES = 5000; // 10 kbit/s at 50 MHz
    localparam [8:0] DATA_PATTERN = 9'b010011100;

    reg [12:0] bit_cnt;
    reg [3:0]  bit_index;

    assign data_bit = DATA_PATTERN[8 - bit_index];

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            bit_cnt   <= 13'd0;
            bit_index <= 4'd0;
        end
        else if (bit_cnt == BIT_HOLD_CYCLES - 1) begin
            bit_cnt <= 13'd0;
            if (bit_index == 4'd8)
                bit_index <= 4'd0;
            else
                bit_index <= bit_index + 1'b1;
        end
        else begin
            bit_cnt <= bit_cnt + 1'b1;
        end
    end

endmodule
