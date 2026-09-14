// Select ordinary waveform output or AM output for the DAC.
module output_mode_mux(
    input             [11:0] normal_data,
    input             [11:0] am_data,
    input                    am_enable,
    output            [11:0] output_data
);

    assign output_data = am_enable ? am_data : normal_data;

endmodule
