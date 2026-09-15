// Select ordinary waveform, AM, or PM output for the DAC.
module output_mode_mux(
    input             [11:0] normal_data,
    input             [11:0] am_data,
    input             [11:0] pm_data,
    input                    am_enable,
    input                    pm_enable,
    output            [11:0] output_data
);

    assign output_data = pm_enable ? pm_data :
                         am_enable ? am_data : normal_data;

endmodule
