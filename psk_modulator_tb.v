`timescale 1ns/1ps

module psk_modulator_tb;
    reg  [31:0] carrier_phase;
    reg         data_bit;
    wire [11:0] psk_data;
    integer failures;

    psk_modulator dut (
        .carrier_phase (carrier_phase),
        .data_bit      (data_bit),
        .psk_data      (psk_data)
    );

    initial begin
        failures = 0;
        carrier_phase = 32'd0;
        data_bit = 1'b0;
        #1;

        if (dut.psk_phase !== 32'd0) begin
            $display("FAIL PSK data 0 did not keep carrier phase");
            failures = failures + 1;
        end

        data_bit = 1'b1;
        #1;
        if (dut.psk_phase !== 32'h8000_0000) begin
            $display("FAIL PSK data 1 did not add 180 degrees");
            failures = failures + 1;
        end

        carrier_phase = 32'hd234_5678;
        #1;
        if (dut.psk_phase !== 32'h5234_5678) begin
            $display("FAIL PSK phase inversion/wraparound");
            failures = failures + 1;
        end

        if (failures == 0)
            $display("PSK_MODULATOR_TEST_PASS");
        else
            $display("PSK_MODULATOR_TEST_FAIL count=%0d", failures);
        $finish;
    end

endmodule
