`timescale 1ns/1ps

module am_modulator_tb;
    reg  [11:0] carrier_data;
    reg  [11:0] mod_data;
    wire [11:0] am_data;
    integer failures;

    am_modulator dut (
        .carrier_data (carrier_data),
        .mod_data     (mod_data),
        .am_data      (am_data)
    );

    task check;
        input [11:0] carrier_value;
        input [11:0] mod_value;
        begin
            carrier_data = carrier_value;
            mod_data     = mod_value;
            #1;
            if (am_data > 12'd4095) begin
                $display("FAIL range carrier=%0d mod=%0d am=%0d", carrier_value, mod_value, am_data);
                failures = failures + 1;
            end
        end
    endtask

    initial begin
        failures = 0;

        check(12'd0,    12'd0);
        check(12'd0,    12'd2048);
        check(12'd0,    12'd4095);
        check(12'd2048, 12'd0);
        check(12'd2048, 12'd2048);
        check(12'd2048, 12'd4095);
        check(12'd4095, 12'd0);
        check(12'd4095, 12'd2048);
        check(12'd4095, 12'd4095);

        carrier_data = 12'd4095;
        mod_data     = 12'd0;
        #1;
        if (am_data != 12'd2048) begin
            $display("FAIL positive carrier low envelope expected 2048 got %0d", am_data);
            failures = failures + 1;
        end

        mod_data = 12'd4095;
        #1;
        if (am_data != 12'd4093) begin
            $display("FAIL high envelope expected 4093 got %0d", am_data);
            failures = failures + 1;
        end

        carrier_data = 12'd0;
        #1;
        if (am_data != 12'd0) begin
            $display("FAIL negative carrier high envelope expected 0 got %0d", am_data);
            failures = failures + 1;
        end

        if (failures == 0)
            $display("AM_MODULATOR_TEST_PASS");
        else
            $display("AM_MODULATOR_TEST_FAIL count=%0d", failures);
        $finish;
    end

endmodule
