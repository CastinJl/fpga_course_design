// Frequency control for the waveform generator.
// KEY3 decreases and KEY4 increases the frequency by 10 kHz per press.
module frequency_ctrl(
    input             clk,
    input             rst,
    input      [7:0]  key_press,
    output reg [31:0] phase_inc
);

    localparam [31:0] PHASE_INC_BASE = 32'd8589934;  // approximately 100 kHz
    localparam [31:0] PHASE_INC_STEP = 32'd858993;   // approximately 10 kHz
    localparam [31:0] PHASE_INC_MIN  = 32'd858993;   // approximately 10 kHz
    localparam [31:0] PHASE_INC_MAX  = 32'd42949654; // approximately 500 kHz

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            phase_inc <= PHASE_INC_BASE;
        end
        else begin
            case ({key_press[4], key_press[3]})
                2'b01: begin
                    if (phase_inc <= PHASE_INC_MIN + PHASE_INC_STEP - 1'b1)
                        phase_inc <= PHASE_INC_MIN;
                    else
                        phase_inc <= phase_inc - PHASE_INC_STEP;
                end
                2'b10: begin
                    if (phase_inc >= PHASE_INC_MAX - PHASE_INC_STEP + 1'b1)
                        phase_inc <= PHASE_INC_MAX;
                    else
                        phase_inc <= phase_inc + PHASE_INC_STEP;
                end
                default: phase_inc <= phase_inc;
            endcase
        end
    end

endmodule
