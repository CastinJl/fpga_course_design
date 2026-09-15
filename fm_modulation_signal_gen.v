// Dedicated FM modulation source.
// Its 10 kHz period (100 us) makes the FM frequency variation easier to
// observe while leaving the AM modulation source unchanged.
module fm_modulation_signal_gen(
    input             clk,
    input             rst,
    output     [11:0] mod_data
);

    localparam [31:0] FM_MOD_PHASE_INC = 32'd858993; // approximately 10 kHz at 50 MHz

    wire [31:0] mod_phase;

    phase_accumulator fm_mod_phase_accumulator_u (
        .clk       (clk),
        .rst       (rst),
        .phase_inc (FM_MOD_PHASE_INC),
        .phase     (mod_phase)
    );

    sine_wave_gen fm_mod_sine_wave_gen_u (
        .phase     (mod_phase),
        .wave_data (mod_data)
    );

endmodule
