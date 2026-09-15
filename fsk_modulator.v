// FSK data path: select one of two carrier frequencies using a binary bit.
// With the default 100 kHz carrier, the two frequencies are approximately
// 50 kHz and 150 kHz, making the FSK sections visible on the oscilloscope.
module fsk_modulator(
    input             clk,
    input             rst,
    input             [31:0] carrier_phase_inc,
    input                    data_bit,
    output            [11:0] fsk_data
);

    // 50 kHz in a 32-bit DDS at a 50 MHz clock.
    localparam signed [31:0] FSK_DEV_INC = 32'sd4294967;

    reg signed [32:0] phase_inc_sum;
    reg        [31:0] fsk_phase_inc;
    wire       [31:0] fsk_phase;

    always @(*) begin
        if (data_bit)
            phase_inc_sum = $signed({1'b0, carrier_phase_inc}) + FSK_DEV_INC;
        else
            phase_inc_sum = $signed({1'b0, carrier_phase_inc}) - FSK_DEV_INC;

        // Avoid wrapping at the legal frequency limits.
        if (phase_inc_sum < 33'sd0)
            fsk_phase_inc = 32'd0;
        else if (phase_inc_sum > 33'sd4294967295)
            fsk_phase_inc = 32'hffffffff;
        else
            fsk_phase_inc = phase_inc_sum[31:0];
    end

    phase_accumulator fsk_phase_accumulator_u (
        .clk       (clk),
        .rst       (rst),
        .phase_inc (fsk_phase_inc),
        .phase     (fsk_phase)
    );

    sine_wave_gen fsk_sine_wave_gen_u (
        .phase     (fsk_phase),
        .wave_data (fsk_data)
    );

endmodule
