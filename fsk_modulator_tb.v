`timescale 1ns/1ps

module fsk_modulator_tb;
    reg  clk;
    reg  rst;
    reg  [31:0] carrier_phase_inc;
    reg         data_bit;
    wire [11:0] fsk_data;
    integer failures;

    fsk_modulator dut (
        .clk               (clk),
        .rst               (rst),
        .carrier_phase_inc (carrier_phase_inc),
        .data_bit          (data_bit),
        .fsk_data          (fsk_data)
    );

    always #5 clk = ~clk;

    initial begin
        failures = 0;
        clk = 1'b0;
        rst = 1'b0;
        carrier_phase_inc = 32'd8589934; // approximately 100 kHz
        data_bit = 1'b0;
        #1;

        if (dut.fsk_phase_inc != 32'd4294967) begin
            $display("FAIL low frequency increment got %0d", dut.fsk_phase_inc);
            failures = failures + 1;
        end

        data_bit = 1'b1;
        #1;
        if (dut.fsk_phase_inc != 32'd12884901) begin
            $display("FAIL high frequency increment got %0d", dut.fsk_phase_inc);
            failures = failures + 1;
        end

        rst = 1'b1;
        #10;
        if (fsk_data === 12'bx) begin
            $display("FAIL FSK output is unknown");
            failures = failures + 1;
        end

        if (failures == 0)
            $display("FSK_MODULATOR_TEST_PASS");
        else
            $display("FSK_MODULATOR_TEST_FAIL count=%0d", failures);
        $finish;
    end

endmodule
