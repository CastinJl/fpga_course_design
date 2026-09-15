// PM data path: add a modulation-dependent phase offset to the carrier.
// The peak phase deviation is pi/2 when mod_data reaches either extreme.
module pm_modulator(
    input             [31:0] carrier_phase,
    input             [11:0] mod_data,
    output            [11:0] pm_data
);

    reg signed [12:0] mod_signed;
    reg signed [31:0] mod_signed_ext;
    reg signed [31:0] phase_offset;
    reg        [31:0] phase_modulated;

    always @(*) begin
        mod_signed      = $signed({1'b0, mod_data}) - 13'sd2048;
        mod_signed_ext  = {{19{mod_signed[12]}}, mod_signed};

        // 2^32 is one full cycle; 2^30 is pi/2.
        // The modulation range is +/-2048, hence the 19-bit shift.
        phase_offset    = mod_signed_ext <<< 19;
        phase_modulated = carrier_phase + phase_offset;
    end

    sine_wave_gen pm_sine_wave_gen_u (
        .phase     (phase_modulated),
        .wave_data (pm_data)
    );

endmodule
