// Synchronize, debounce, and edge-detect the eight push buttons.
// The existing experiment-box key example treats a pressed key as logic 1.
module key_frontend #(
    parameter KEY_ACTIVE_HIGH = 1'b1,
    parameter integer DEBOUNCE_CYCLES = 1000000
)(
    input             clk,
    input             rst,
    input      [7:0]  key_raw,
    output     [7:0]  key_press
);

    wire [7:0] key_level;
    reg  [7:0] key_meta;
    reg  [7:0] key_sync;
    reg  [7:0] key_stable;
    reg  [7:0] key_stable_d;
    reg  [19:0] debounce_cnt [0:7];
    integer i;
    localparam [7:0] KEY_IDLE_RAW = KEY_ACTIVE_HIGH ? 8'd0 : 8'hff;

    assign key_level = KEY_ACTIVE_HIGH ? key_sync : ~key_sync;
    assign key_press = key_stable & ~key_stable_d;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            key_meta <= KEY_IDLE_RAW;
            key_sync <= KEY_IDLE_RAW;
        end
        else begin
            key_meta <= key_raw;
            key_sync <= key_meta;
        end
    end

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            key_stable   <= 8'd0;
            key_stable_d <= 8'd0;
            for (i = 0; i < 8; i = i + 1)
                debounce_cnt[i] <= 20'd0;
        end
        else begin
            key_stable_d <= key_stable;
            for (i = 0; i < 8; i = i + 1) begin
                if (key_level[i] == key_stable[i]) begin
                    debounce_cnt[i] <= 20'd0;
                end
                else if (debounce_cnt[i] == DEBOUNCE_CYCLES - 1) begin
                    key_stable[i]   <= key_level[i];
                    debounce_cnt[i] <= 20'd0;
                end
                else begin
                    debounce_cnt[i] <= debounce_cnt[i] + 1'b1;
                end
            end
        end
    end

endmodule
