// Dedicated PM modulation source.
// Its 10 kHz period (100 us) makes the PM phase variation easier to observe
// on the oscilloscope while leaving the AM/FM modulation source unchanged.
module pm_modulation_signal_gen(
    input             clk,
    input             rst,
    output     [11:0] mod_data
);

    localparam [31:0] PM_MOD_PHASE_INC = 32'd858993; // approximately 10 kHz at 50 MHz

    wire [31:0] mod_phase;

    phase_accumulator pm_mod_phase_accumulator_u (
        .clk       (clk),
        .rst       (rst),
        .phase_inc (PM_MOD_PHASE_INC),
        .phase     (mod_phase)
    );

    sine_wave_gen pm_mod_sine_wave_gen_u (
        .phase     (mod_phase),
        .wave_data (mod_data)
    );

endmodule
