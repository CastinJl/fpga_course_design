// Select one waveform for the DAC path.
module wave_mux(
    input      [11:0] sine_data,
    input      [11:0] square_data,
    input      [11:0] triangle_data,
    input      [1:0]  wave_sel,
    output reg [11:0] wave_data
);

    always @(*) begin
        case (wave_sel)
            2'b00:   wave_data = sine_data;
            2'b01:   wave_data = square_data;
            2'b10:   wave_data = triangle_data;
            default: wave_data = sine_data;
        endcase
    end

endmodule
