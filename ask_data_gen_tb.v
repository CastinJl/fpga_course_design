`timescale 1ns/1ps

module ask_data_gen_tb;
    reg  clk;
    reg  rst;
    wire data_bit;
    integer failures;

    ask_data_gen dut (
        .clk      (clk),
        .rst      (rst),
        .data_bit (data_bit)
    );

    always #1 clk = ~clk;

    task wait_bit;
        begin
            repeat (5000) @(posedge clk);
            #1;
        end
    endtask

    task check_bit;
        input expected;
        begin
            if (data_bit !== expected) begin
                $display("FAIL expected bit %0d got %0d", expected, data_bit);
                failures = failures + 1;
            end
        end
    endtask

    initial begin
        failures = 0;
        clk = 1'b0;
        rst = 1'b0;
        #2;
        rst = 1'b1;

        check_bit(1'b0);
        wait_bit; check_bit(1'b1);
        wait_bit; check_bit(1'b0);
        wait_bit; check_bit(1'b0);
        wait_bit; check_bit(1'b1);

        if (failures == 0)
            $display("ASK_DATA_TEST_PASS");
        else
            $display("ASK_DATA_TEST_FAIL count=%0d", failures);
        $finish;
    end

endmodule
