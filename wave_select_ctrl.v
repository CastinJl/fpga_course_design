// Store the selected waveform after a debounced key press.
// KEY0 selects sine, KEY1 selects triangle, and KEY2 selects square.
module wave_select_ctrl #(
    parameter [1:0] DEFAULT_WAVE = 2'b00
)(
    input             clk,
    input             rst,
    input      [7:0]  key_press,
    output reg [1:0]  wave_sel
);

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            wave_sel <= DEFAULT_WAVE;
        end
        else if (key_press[0]) begin
            wave_sel <= 2'b00;
        end
        else if (key_press[1]) begin
            wave_sel <= 2'b10;
        end
        else if (key_press[2]) begin
            wave_sel <= 2'b01;
        end
    end

endmodule
