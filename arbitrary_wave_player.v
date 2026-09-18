// DDS address generator for a 512-point arbitrary waveform.
// phase_inc is calculated from the requested output frequency by the
// download controller. The upper nine phase bits select one sample.
module arbitrary_wave_player(
    input             clk,
    input             rst,
    input             enable,
    input      [31:0] phase_inc,
    input      [11:0] sample_in,
    output     [8:0]  sample_addr,
    output     [11:0] wave_data
);

    reg [31:0] phase;

    assign sample_addr = phase[31:23];
    assign wave_data = sample_in;

    always @(posedge clk or negedge rst) begin
        if (!rst)
            phase <= 32'd0;
        else if (!enable)
            phase <= 32'd0;
        else
            phase <= phase + phase_inc;
    end

endmodule
