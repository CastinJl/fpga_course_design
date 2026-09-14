// Shared DDS phase accumulator.
module phase_accumulator #(
    parameter [31:0] PHASE_INC = 32'd8589934
)(
    input              clk,
    input              rst,
    output reg [31:0]  phase
);

    always @(posedge clk or negedge rst) begin
        if (!rst) phase <= 32'd0;
        else      phase <= phase + PHASE_INC;
    end

endmodule
