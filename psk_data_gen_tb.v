`timescale 1ns/1ps

module psk_data_gen_tb;
    reg  clk;
    reg  rst;
    wire data_bit;
    integer failures;

    psk_data_gen dut (
        .clk      (clk),
        .rst      (rst),
        .data_bit (data_bit)
    );

    always #1 clk = ~clk;

    task wait_bit;
        begin
            repeat (2500) @(posedge clk);
            #1;
        end
    endtask

    initial begin
        failures = 0;
        clk = 1'b0;
        rst = 1'b0;
        #2;
        rst = 1'b1;

        if (data_bit !== 1'b0) failures = failures + 1;
        wait_bit;
        if (data_bit !== 1'b1) failures = failures + 1;
        wait_bit;
        if (data_bit !== 1'b0) failures = failures + 1;
        wait_bit;
        if (data_bit !== 1'b0) failures = failures + 1;

        if (failures == 0)
            $display("PSK_DATA_TEST_PASS");
        else
            $display("PSK_DATA_TEST_FAIL count=%0d", failures);
        $finish;
    end

endmodule
