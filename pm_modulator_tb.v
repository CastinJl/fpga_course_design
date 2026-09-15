`timescale 1ns/1ps

module pm_modulator_tb;
    reg  [31:0] carrier_phase;
    reg  [11:0] mod_data;
    wire [11:0] pm_data;
    integer failures;

    pm_modulator dut (
        .carrier_phase (carrier_phase),
        .mod_data      (mod_data),
        .pm_data       (pm_data)
    );

    initial begin
        failures = 0;

        // Zero modulation must leave the carrier phase unchanged.
        carrier_phase = 32'h00000000;
        mod_data      = 12'd2048;
        #1;
        if (pm_data != 12'd2048) begin
            $display("FAIL zero phase offset expected 2048 got %0d", pm_data);
            failures = failures + 1;
        end

        // The two modulation extremes produce approximately +/- pi/2.
        mod_data = 12'd4095;
        #1;
        if (pm_data < 12'd4090) begin
            $display("FAIL positive phase deviation expected near 4095 got %0d", pm_data);
            failures = failures + 1;
        end

        mod_data = 12'd0;
        #1;
        if (pm_data > 12'd5) begin
            $display("FAIL negative phase deviation expected near 0 got %0d", pm_data);
            failures = failures + 1;
        end

        if (failures == 0)
            $display("PM_MODULATOR_TEST_PASS");
        else
            $display("PM_MODULATOR_TEST_FAIL count=%0d", failures);
        $finish;
    end

endmodule
