// Fixed 1 kHz sine modulation source for the AM extension.
module modulation_signal_gen(
    input             clk,
    input             rst,
    output     [11:0] mod_data
);

    localparam [31:0] MOD_PHASE_INC = 32'd85899; // approximately 1 kHz at 50 MHz

    wire [31:0] mod_phase;

    phase_accumulator mod_phase_accumulator_u (
        .clk       (clk),
        .rst       (rst),
        .phase_inc (MOD_PHASE_INC),
        .phase     (mod_phase)
    );

    sine_wave_gen mod_sine_wave_gen_u (
        .phase     (mod_phase),
        .wave_data (mod_data)
    );

endmodule
