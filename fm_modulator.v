// FM data path: vary the DDS phase increment with the modulation signal.
// With the default 100 kHz carrier, the peak frequency deviation is about
// +/-10 kHz for the fixed 1 kHz modulation source.
module fm_modulator(
    input             clk,
    input             rst,
    input             [31:0] carrier_phase_inc,
    input             [11:0] mod_data,
    output            [11:0] fm_data
);

    // A 12-bit centered modulation value is approximately +/-2048.
    // 420 phase-increment counts per code gives about 10 kHz deviation:
    // 10 kHz * 2^32 / 50 MHz ~= 858993 counts.
    localparam signed [31:0] FREQ_DEV_PER_CODE = 32'sd420;

    reg signed [12:0] mod_signed;
    reg signed [22:0] phase_inc_offset;
    reg signed [32:0] phase_inc_sum;
    reg        [31:0] fm_phase_inc;
    wire       [31:0] fm_phase;

    always @(*) begin
        mod_signed      = $signed({1'b0, mod_data}) - 13'sd2048;
        phase_inc_offset = mod_signed * FREQ_DEV_PER_CODE;
        phase_inc_sum   = $signed({1'b0, carrier_phase_inc}) +
                          {{10{phase_inc_offset[22]}}, phase_inc_offset};

        // Prevent an underflow from turning a low carrier setting into a
        // very large wrapped DDS frequency.
        if (phase_inc_sum < 33'sd0)
            fm_phase_inc = 32'd0;
        else if (phase_inc_sum > 33'sd4294967295)
            fm_phase_inc = 32'hffffffff;
        else
            fm_phase_inc = phase_inc_sum[31:0];
    end

    phase_accumulator fm_phase_accumulator_u (
        .clk       (clk),
        .rst       (rst),
        .phase_inc (fm_phase_inc),
        .phase     (fm_phase)
    );

    sine_wave_gen fm_sine_wave_gen_u (
        .phase     (fm_phase),
        .wave_data (fm_data)
    );

endmodule
