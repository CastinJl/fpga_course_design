`timescale 1ns/1ps

module ask_modulator_tb;
    reg  [11:0] carrier_data;
    reg         data_bit;
    wire [11:0] ask_data;
    integer failures;

    ask_modulator dut (
        .carrier_data (carrier_data),
        .data_bit     (data_bit),
        .ask_data     (ask_data)
    );

    initial begin
        failures = 0;

        data_bit = 1'b0;
        carrier_data = 12'd0;
        #1;
        if (ask_data != 12'd2048) begin
            $display("FAIL zero bit expected midpoint got %0d", ask_data);
            failures = failures + 1;
        end

        data_bit = 1'b1;
        carrier_data = 12'd4095;
        #1;
        if (ask_data != 12'd4095) begin
            $display("FAIL one bit expected carrier got %0d", ask_data);
            failures = failures + 1;
        end

        if (failures == 0)
            $display("ASK_MODULATOR_TEST_PASS");
        else
            $display("ASK_MODULATOR_TEST_FAIL count=%0d", failures);
        $finish;
    end

endmodule
