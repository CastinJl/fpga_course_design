// Binary phase-shift keying (BPSK) modulator.
// Data 0 keeps the carrier phase; data 1 adds 180 degrees.
module psk_modulator(
    input             [31:0] carrier_phase,
    input                    data_bit,
    output            [11:0] psk_data
);

    wire [31:0] psk_phase;

    assign psk_phase = data_bit ?
                       (carrier_phase + 32'h8000_0000) : carrier_phase;

    sine_wave_gen psk_sine_wave_gen_u (
        .phase     (psk_phase),
        .wave_data (psk_data)
    );

endmodule
