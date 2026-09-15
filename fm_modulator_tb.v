`timescale 1ns/1ps

module fm_modulator_tb;
    reg  clk;
    reg  rst;
    reg  [31:0] carrier_phase_inc;
    reg  [11:0] mod_data;
    wire [11:0] fm_data;
    integer failures;

    fm_modulator dut (
        .clk               (clk),
        .rst               (rst),
        .carrier_phase_inc (carrier_phase_inc),
        .mod_data          (mod_data),
        .fm_data           (fm_data)
    );

    always #5 clk = ~clk;

    initial begin
        failures = 0;
        clk = 1'b0;
        rst = 1'b0;
        carrier_phase_inc = 32'd8589934;
        mod_data = 12'd2048;
        #2;

        // At the modulation midpoint, FM must use the carrier increment.
        if (dut.fm_phase_inc != 32'd8589934) begin
            $display("FAIL center increment got %0d", dut.fm_phase_inc);
            failures = failures + 1;
        end

        // The positive and negative modulation peaks must shift frequency
        // in opposite directions by approximately 10 kHz.
        mod_data = 12'd4095;
        #1;
        if (dut.fm_phase_inc != 32'd9449674) begin
            $display("FAIL positive deviation got %0d", dut.fm_phase_inc);
            failures = failures + 1;
        end

        mod_data = 12'd0;
        #1;
        if (dut.fm_phase_inc != 32'd7729774) begin
            $display("FAIL negative deviation got %0d", dut.fm_phase_inc);
            failures = failures + 1;
        end

        rst = 1'b1;
        #10;
        if (fm_data === 12'bx) begin
            $display("FAIL FM output is unknown");
            failures = failures + 1;
        end

        if (failures == 0)
            $display("FM_MODULATOR_TEST_PASS");
        else
            $display("FM_MODULATOR_TEST_FAIL count=%0d", failures);
        $finish;
    end

endmodule
