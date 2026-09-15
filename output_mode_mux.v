// Select ordinary waveform, AM, PM, FM, ASK, or FSK output for the DAC.
module output_mode_mux(
    input             [11:0] normal_data,
    input             [11:0] am_data,
    input             [11:0] pm_data,
    input             [11:0] fm_data,
    input             [11:0] ask_data,
    input             [11:0] fsk_data,
    input                    am_enable,
    input                    pm_enable,
    input                    fm_enable,
    input                    ask_enable,
    input                    fsk_enable,
    output            [11:0] output_data
);

    assign output_data = fsk_enable ? fsk_data :
                         ask_enable ? ask_data :
                         fm_enable ? fm_data :
                         pm_enable ? pm_data :
                         am_enable ? am_data : normal_data;

endmodule
