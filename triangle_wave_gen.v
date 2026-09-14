// Triangle waveform conversion from a shared DDS phase.
// The waveform ramps from 0 to 4095 and back once per phase cycle.
module triangle_wave_gen(
    input      [31:0] phase,
    output     [11:0] wave_data
);

    wire [11:0] ramp = phase[30:19];

    assign wave_data = phase[31] ? ~ramp : ramp;

endmodule
