// Shared DDS phase accumulator.
module phase_accumulator(
    input              clk,
    input              rst,
    input      [31:0]  phase_inc,
    output reg [31:0]  phase
);

    always @(posedge clk or negedge rst) begin
        if (!rst) phase <= 32'd0;
        else      phase <= phase + phase_inc;
    end

endmodule
