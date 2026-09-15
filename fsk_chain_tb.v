`timescale 1ns/1ps

module fsk_chain_tb;
    reg  clk;
    reg  rst;
    wire data_bit;
    wire [11:0] fsk_data;
    wire [31:0] phase_inc = 32'd8589934;
    integer failures;

    fsk_data_gen data_gen_u (
        .clk      (clk),
        .rst      (rst),
        .data_bit (data_bit)
    );

    fsk_modulator fsk_u (
        .clk               (clk),
        .rst               (rst),
        .carrier_phase_inc (phase_inc),
        .data_bit          (data_bit),
        .fsk_data          (fsk_data)
    );

    always #10 clk = ~clk;

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
        #5;
        rst = 1'b1;

        if (data_bit !== 1'b0 || fsk_u.fsk_phase_inc != 32'd4294967) begin
            $display("FAIL first FSK bit or frequency");
            failures = failures + 1;
        end

        wait_bit;
        if (data_bit !== 1'b1 || fsk_u.fsk_phase_inc != 32'd12884901) begin
            $display("FAIL second FSK bit or frequency");
            failures = failures + 1;
        end

        wait_bit;
        if (data_bit !== 1'b0 || fsk_u.fsk_phase_inc != 32'd4294967) begin
            $display("FAIL third FSK bit or frequency");
            failures = failures + 1;
        end

        if (failures == 0)
            $display("FSK_CHAIN_TEST_PASS");
        else
            $display("FSK_CHAIN_TEST_FAIL count=%0d", failures);
        $finish;
    end

endmodule
