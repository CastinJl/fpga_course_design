`timescale 1ns/1ps

module vga_wave_display_tb;
    reg         clk;
    reg         reset_n;
    reg  [11:0] wave_data;
    reg         pm_enable;
    reg         fm_enable;
    wire        vga_hsync;
    wire        vga_vsync;
    wire [11:0] vga_d;
    integer failures;

    vga_wave_display dut (
        .clk       (clk),
        .reset_n   (reset_n),
        .wave_data (wave_data),
        .pm_enable (pm_enable),
        .fm_enable (fm_enable),
        .VGA_HSYNC (vga_hsync),
        .VGA_VSYNC (vga_vsync),
        .VGA_D     (vga_d)
    );

    always #10 clk = ~clk;

    initial begin
        failures = 0;
        clk = 1'b0;
        reset_n = 1'b0;
        wave_data = 12'd1000;
        pm_enable = 1'b0;
        fm_enable = 1'b0;
        #25;
        reset_n = 1'b1;

        // The module must wait while the input remains below the trigger level.
        repeat (20) @(posedge dut.clk25M);
        if (dut.capture_active !== 1'b0) begin
            $display("FAIL capture started without a trigger");
            failures = failures + 1;
        end

        // Create one rising crossing of the 2048 trigger level.
        wave_data = 12'd3000;
        @(posedge dut.clk25M);
        #1;
        if (dut.capture_active !== 1'b1 || dut.capture_idx !== 10'd1) begin
            $display("FAIL capture did not start at rising crossing");
            failures = failures + 1;
        end

        // Keep the signal high and verify that exactly 639 further samples are taken.
        repeat (639) @(posedge dut.clk25M);
        #1;
        if (dut.capture_done !== 1'b1 || dut.capture_active !== 1'b0) begin
            $display("FAIL capture did not complete after 640 samples");
            failures = failures + 1;
        end

        // PM/FM mode must latch the longer display timebase at the trigger.
        reset_n = 1'b0;
        #25;
        pm_enable = 1'b1;
        wave_data = 12'd1000;
        reset_n = 1'b1;
        repeat (20) @(posedge dut.clk25M);
        wave_data = 12'd3000;
        @(posedge dut.clk25M);
        #1;
        if (dut.capture_step !== 4'd8) begin
            $display("FAIL PM mode did not select 8x display timebase");
            failures = failures + 1;
        end
        if (dut.capture_length !== 10'd480) begin
            $display("FAIL PM mode did not select 480-sample display window");
            failures = failures + 1;
        end

        if (failures == 0)
            $display("VGA_TRIGGER_TEST_PASS");
        else
            $display("VGA_TRIGGER_TEST_FAIL count=%0d", failures);
        $finish;
    end

endmodule
