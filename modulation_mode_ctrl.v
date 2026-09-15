// Select normal, AM, or PM output. AM and PM are mutually exclusive.
module modulation_mode_ctrl(
    input             clk,
    input             rst,
    input             am_key_press,
    input             pm_key_press,
    output reg        am_enable,
    output reg        pm_enable
);

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            am_enable <= 1'b0;
            pm_enable <= 1'b0;
        end
        else if (am_key_press) begin
            if (am_enable) begin
                am_enable <= 1'b0;
            end
            else begin
                am_enable <= 1'b1;
                pm_enable <= 1'b0;
            end
        end
        else if (pm_key_press) begin
            if (pm_enable) begin
                pm_enable <= 1'b0;
            end
            else begin
                pm_enable <= 1'b1;
                am_enable <= 1'b0;
            end
        end
    end

endmodule
