`timescale 1ns/1ps

module vga_wave_display_tb;
    reg         clk;
    reg         reset_n;
    reg  [11:0] wave_data;
    wire        vga_hsync;
    wire        vga_vsync;
    wire [11:0] vga_d;
    integer failures;

    vga_wave_display dut (
        .clk       (clk),
        .reset_n   (reset_n),
        .wave_data (wave_data),
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

        if (failures == 0)
            $display("VGA_TRIGGER_TEST_PASS");
        else
            $display("VGA_TRIGGER_TEST_FAIL count=%0d", failures);
        $finish;
    end

endmodule
