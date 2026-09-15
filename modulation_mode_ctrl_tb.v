`timescale 1ns/1ps

module modulation_mode_ctrl_tb;
    reg  clk;
    reg  rst;
    reg  am_key_press;
    reg  pm_key_press;
    reg  fm_key_press;
    wire am_enable;
    wire pm_enable;
    wire fm_enable;
    wire ask_enable;
    wire fsk_enable;
    integer failures;

    modulation_mode_ctrl dut (
        .clk          (clk),
        .rst          (rst),
        .am_key_press (am_key_press),
        .pm_key_press (pm_key_press),
        .fm_key_press (fm_key_press),
        .am_enable    (am_enable),
        .pm_enable    (pm_enable),
        .fm_enable    (fm_enable),
        .ask_enable   (ask_enable),
        .fsk_enable   (fsk_enable)
    );

    always #5 clk = ~clk;

    task press_fm_key;
        begin
            fm_key_press = 1'b1;
            @(posedge clk);
            #1 fm_key_press = 1'b0;
            @(posedge clk);
        end
    endtask

    initial begin
        failures = 0;
        clk = 1'b0;
        rst = 1'b0;
        am_key_press = 1'b0;
        pm_key_press = 1'b0;
        fm_key_press = 1'b0;
        #2;
        rst = 1'b1;

        press_fm_key;
        if (!fm_enable || ask_enable || am_enable || pm_enable) begin
            $display("FAIL first KEY7 press did not select FM");
            failures = failures + 1;
        end

        press_fm_key;
        if (!ask_enable || fm_enable || am_enable || pm_enable) begin
            $display("FAIL second KEY7 press did not select ASK");
            failures = failures + 1;
        end

        press_fm_key;
        if (!fsk_enable || ask_enable || fm_enable || am_enable || pm_enable) begin
            $display("FAIL third KEY7 press did not select FSK");
            failures = failures + 1;
        end

        press_fm_key;
        if (fsk_enable || ask_enable || fm_enable || am_enable || pm_enable) begin
            $display("FAIL fourth KEY7 press did not return normal");
            failures = failures + 1;
        end

        if (failures == 0)
            $display("MODULATION_MODE_TEST_PASS");
        else
            $display("MODULATION_MODE_TEST_FAIL count=%0d", failures);
        $finish;
    end

endmodule
