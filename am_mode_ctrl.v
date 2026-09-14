// Toggle AM mode on each debounced KEY5 press.
module am_mode_ctrl(
    input             clk,
    input             rst,
    input             key_press,
    output reg        am_enable
);

    always @(posedge clk or negedge rst) begin
        if (!rst)
            am_enable <= 1'b0;
        else if (key_press)
            am_enable <= ~am_enable;
    end

endmodule
