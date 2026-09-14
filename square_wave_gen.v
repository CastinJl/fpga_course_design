// Square waveform conversion from a shared DDS phase.
// The two levels are centered around 2048 and span the usable DAC range.
module square_wave_gen(
    input      [31:0] phase,
    output     [11:0] wave_data
);

    assign wave_data = phase[31] ? 12'd4095 : 12'd1;

endmodule
