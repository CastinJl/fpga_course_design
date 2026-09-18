// Receive and store one arbitrary waveform frame from UART.
// Frame format, all fields are sent as hexadecimal bytes:
//   A5 5A 01
//   frequency[31:24] frequency[23:16] frequency[15:8] frequency[7:0]
//   512 samples, each as sample[11:8] followed by sample[7:0]
//   checksum (8-bit XOR of command, frequency bytes, and sample bytes)
//   5A A5
// The frequency field is an unsigned frequency in Hz. The sample count is
// fixed at 512 points for this first arbitrary-waveform implementation.
// A second RAM bank is written while the other bank is being played.
module wave_download_ctrl #(
    parameter integer SAMPLE_COUNT = 512
)(
    input             clk,
    input             rst,
    input      [7:0]  rx_data,
    input             rx_valid,
    input      [8:0]  read_addr,
    output     [11:0] read_data,
    input      [8:0]  vga_addr,
    output     [11:0] vga_data,
    output reg        wave_ready,
    output reg [31:0] phase_inc
);

    localparam [3:0] S_IDLE    = 4'd0;
    localparam [3:0] S_HEADER2 = 4'd1;
    localparam [3:0] S_COMMAND = 4'd2;
    localparam [3:0] S_FREQ0   = 4'd3;
    localparam [3:0] S_FREQ1   = 4'd4;
    localparam [3:0] S_FREQ2   = 4'd5;
    localparam [3:0] S_FREQ3   = 4'd6;
    localparam [3:0] S_SAMPLE_H = 4'd7;
    localparam [3:0] S_SAMPLE_L = 4'd8;
    localparam [3:0] S_CHECKSUM = 4'd9;
    localparam [3:0] S_END1    = 4'd10;
    localparam [3:0] S_END2    = 4'd11;

    reg [3:0]  state;
    reg [8:0]  write_addr;
    reg [3:0]  sample_high;
    reg [31:0] frequency_hz;
    reg [7:0]  checksum;
    reg        active_bank;
    reg [11:0] wave_mem0 [0:SAMPLE_COUNT-1];
    reg [11:0] wave_mem1 [0:SAMPLE_COUNT-1];

    assign read_data = active_bank ? wave_mem1[read_addr] : wave_mem0[read_addr];
    assign vga_data  = active_bank ? wave_mem1[vga_addr] : wave_mem0[vga_addr];

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            state       <= S_IDLE;
            write_addr  <= 9'd0;
            sample_high <= 4'd0;
            frequency_hz <= 32'd100000;
            checksum    <= 8'd0;
            active_bank <= 1'b0;
            wave_ready  <= 1'b0;
            phase_inc   <= 32'd8589934; // 100 kHz at a 50 MHz DAC update rate
        end else if (rx_valid) begin
            case (state)
                S_IDLE: begin
                    if (rx_data == 8'hA5)
                        state <= S_HEADER2;
                end

                S_HEADER2: begin
                    if (rx_data == 8'h5A)
                        state <= S_COMMAND;
                    else if (rx_data == 8'hA5)
                        state <= S_HEADER2;
                    else
                        state <= S_IDLE;
                end

                S_COMMAND: begin
                    if (rx_data == 8'h01) begin
                        write_addr <= 9'd0;
                        checksum <= rx_data;
                        state <= S_FREQ0;
                    end else if (rx_data == 8'hA5) begin
                        state <= S_HEADER2;
                    end else begin
                        state <= S_IDLE;
                    end
                end

                S_FREQ0: begin
                    frequency_hz[31:24] <= rx_data;
                    checksum <= checksum ^ rx_data;
                    state <= S_FREQ1;
                end

                S_FREQ1: begin
                    frequency_hz[23:16] <= rx_data;
                    checksum <= checksum ^ rx_data;
                    state <= S_FREQ2;
                end

                S_FREQ2: begin
                    frequency_hz[15:8] <= rx_data;
                    checksum <= checksum ^ rx_data;
                    state <= S_FREQ3;
                end

                S_FREQ3: begin
                    frequency_hz[7:0] <= rx_data;
                    checksum <= checksum ^ rx_data;
                    state <= S_SAMPLE_H;
                end

                S_SAMPLE_H: begin
                    sample_high <= rx_data[3:0];
                    checksum <= checksum ^ rx_data;
                    state <= S_SAMPLE_L;
                end

                S_SAMPLE_L: begin
                    if (active_bank)
                        wave_mem0[write_addr] <= {sample_high, rx_data};
                    else
                        wave_mem1[write_addr] <= {sample_high, rx_data};

                    checksum <= checksum ^ rx_data;

                    if (write_addr == SAMPLE_COUNT - 1) begin
                        state <= S_CHECKSUM;
                    end else begin
                        write_addr <= write_addr + 1'b1;
                        state <= S_SAMPLE_H;
                    end
                end

                S_CHECKSUM: begin
                    if (rx_data == checksum)
                        state <= S_END1;
                    else
                        state <= S_IDLE;
                end

                S_END1: begin
                    if (rx_data == 8'h5A)
                        state <= S_END2;
                    else
                        state <= S_IDLE;
                end

                S_END2: begin
                    if (rx_data == 8'hA5) begin
                        active_bank <= ~active_bank;
                        wave_ready <= 1'b1;
                        // phase_inc = frequency_hz * 2^32 / 50 MHz.
                        // Use a fixed-point approximation with 1e-4 scale.
                        phase_inc <= (frequency_hz * 64'd858993) /
                                     64'd10000;
                    end
                    state <= S_IDLE;
                end

                default: state <= S_IDLE;
            endcase
        end
    end

endmodule
