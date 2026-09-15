// ASK/OOK data path.
// A zero bit outputs the DAC midpoint, which represents a zero AC carrier.
module ask_modulator(
    input             [11:0] carrier_data,
    input                    data_bit,
    output            [11:0] ask_data
);

    assign ask_data = data_bit ? carrier_data : 12'd2048;

endmodule
