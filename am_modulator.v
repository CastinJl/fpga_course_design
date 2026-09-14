// AM data-path arithmetic.
// The carrier is scaled before modulation so the 12-bit DAC does not clip.
module am_modulator(
    input             [11:0] carrier_data,
    input             [11:0] mod_data,
    output reg        [11:0] am_data
);

    reg signed [12:0] carrier_signed;
    reg signed [12:0] mod_signed;
    reg signed [12:0] carrier_scaled;
    reg signed [12:0] envelope;
    reg signed [25:0] product;
    reg signed [26:0] output_signed;

    always @(*) begin
        carrier_signed = $signed({1'b0, carrier_data}) - 13'sd2048;
        mod_signed     = $signed({1'b0, mod_data}) - 13'sd2048;

        // Carrier amplitude is 1/2 of full scale; modulation depth is 50%.
        carrier_scaled = carrier_signed >>> 1;
        envelope       = 13'sd2048 + (mod_signed >>> 1);

        product       = carrier_scaled * envelope;
        output_signed = 27'sd2048 + (product >>> 11);

        // Keep the module well-defined even if the input range changes later.
        if (output_signed < 27'sd0)
            am_data = 12'd0;
        else if (output_signed > 27'sd4095)
            am_data = 12'd4095;
        else
            am_data = output_signed[11:0];
    end

endmodule
