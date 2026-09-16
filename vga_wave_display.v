// 640x480 VGA waveform display with oscilloscope-style rising-edge trigger.
// A completed 640-sample block is displayed while the other block is filled,
// so the waveform does not change halfway through a video frame.
module vga_wave_display(
    input             clk,
    input             reset_n,
    input      [11:0] wave_data,
    input             pm_enable,
    input             fm_enable,
    output            VGA_HSYNC,
    output            VGA_VSYNC,
    output reg [11:0] VGA_D
);

    localparam integer H_ACTIVE = 640;
    localparam integer PMFM_CAPTURE = 480; // PM/FM use 3/4 of the previous time window.
    localparam integer H_TOTAL  = 801; // Keep the timing of the verified vgaV module.
    localparam integer V_ACTIVE = 480;
    localparam integer V_TOTAL  = 526;

    reg        clk25M;
    reg [9:0]  hcnt;
    reg [9:0]  vcnt;
    reg        hs;
    reg        vs;

    reg [11:0] sample_mem0 [0:639];
    reg [11:0] sample_mem1 [0:639];
    reg [9:0]  capture_idx;
    reg        capture_bank;
    reg        capture_active;
    reg        capture_done;
    reg        display_bank;
    reg        display_valid;
    reg [11:0] previous_wave_data;
    reg [3:0]  capture_step;
    reg [3:0]  sample_skip_count;
    reg [9:0]  capture_length;

    wire display_enable = (hcnt < H_ACTIVE) && (vcnt < V_ACTIVE);
    wire frame_start = (hcnt == 10'd0) && (vcnt == 10'd0);
    wire [10:0] display_scaled_addr = {1'b0, hcnt} + ({1'b0, hcnt} << 1);
    wire [9:0] display_addr = (hcnt < H_ACTIVE) ?
                              ((pm_enable || fm_enable) ?
                               (display_scaled_addr >> 2) : hcnt) : 10'd0;
    wire [11:0] display_sample;
    wire [21:0] sample_ext;
    wire [31:0] scaled_product;
    wire [9:0]  waveform_y;
    wire trigger_event;
    wire [3:0] requested_capture_step = (pm_enable || fm_enable) ? 4'd8 : 4'd1;
    wire [9:0] requested_capture_length = (pm_enable || fm_enable) ?
                                          PMFM_CAPTURE : H_ACTIVE;

    assign VGA_HSYNC = hs;
    assign VGA_VSYNC = vs;

    assign display_sample = display_bank ? sample_mem1[display_addr] : sample_mem0[display_addr];
    assign sample_ext = {10'd0, display_sample};
    assign scaled_product = sample_ext * 32'd400;
    assign waveform_y = 10'd440 - scaled_product[21:12];
    assign trigger_event = (previous_wave_data < 12'd2048) &&
                           (wave_data >= 12'd2048);

    // Divide the 50 MHz system clock by two for the 25 MHz VGA pixel clock.
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            clk25M <= 1'b0;
        else
            clk25M <= ~clk25M;
    end

    always @(posedge clk25M or negedge reset_n) begin
        if (!reset_n) begin
            hcnt <= 10'd0;
            vcnt <= 10'd0;
        end
        else begin
            if (hcnt < H_TOTAL - 1)
                hcnt <= hcnt + 1'b1;
            else
                hcnt <= 10'd0;

            if (hcnt == H_TOTAL - 1) begin
                if (vcnt < V_TOTAL - 1)
                    vcnt <= vcnt + 1'b1;
                else
                    vcnt <= 10'd0;
            end
        end
    end

    always @(posedge clk25M or negedge reset_n) begin
        if (!reset_n) begin
            hs <= 1'b1;
            vs <= 1'b1;
        end
        else begin
            if ((hcnt >= 10'd656) && (hcnt < 10'd752))
                hs <= 1'b0;
            else
                hs <= 1'b1;

            if ((vcnt >= 10'd490) && (vcnt < 10'd492))
                vs <= 1'b0;
            else
                vs <= 1'b1;
        end
    end

    // Track the incoming waveform and capture only after a rising mid-level
    // crossing, which fixes the horizontal phase of periodic waveforms.
    always @(posedge clk25M or negedge reset_n) begin
        if (!reset_n) begin
            capture_idx    <= 10'd0;
            capture_bank   <= 1'b0;
            capture_active <= 1'b0;
            capture_done   <= 1'b0;
            display_bank   <= 1'b1;
            display_valid <= 1'b0;
            previous_wave_data <= 12'd2048;
            capture_step <= 4'd1;
            sample_skip_count <= 4'd0;
            capture_length <= H_ACTIVE;
        end
        else begin
            previous_wave_data <= wave_data;

            if (capture_done) begin
                if (frame_start) begin
                    display_bank  <= capture_bank;
                    display_valid <= 1'b1;
                    capture_bank  <= ~capture_bank;
                    capture_idx   <= 10'd0;
                    capture_active <= 1'b0;
                    capture_done  <= 1'b0;
                    sample_skip_count <= 4'd0;
                end
            end
            else if (!capture_active) begin
                if (trigger_event) begin
                    if (capture_bank)
                        sample_mem1[0] <= wave_data;
                    else
                        sample_mem0[0] <= wave_data;

                    capture_step    <= requested_capture_step;
                    capture_length  <= requested_capture_length;
                    capture_idx    <= 10'd1;
                    capture_active <= 1'b1;
                    sample_skip_count <= 4'd0;
                end
            end
            else begin
                if (sample_skip_count == capture_step - 1'b1) begin
                    if (capture_bank)
                        sample_mem1[capture_idx] <= wave_data;
                    else
                        sample_mem0[capture_idx] <= wave_data;

                    sample_skip_count <= 4'd0;
                    if (capture_idx == capture_length - 1'b1) begin
                        capture_idx    <= 10'd0;
                        capture_active <= 1'b0;
                        capture_done   <= 1'b1;
                    end
                    else begin
                        capture_idx <= capture_idx + 1'b1;
                    end
                end
                else begin
                    sample_skip_count <= sample_skip_count + 1'b1;
                end
            end
        end
    end

    // Draw a green waveform on a black background with a white center axis.
    always @(posedge clk25M or negedge reset_n) begin
        if (!reset_n)
            VGA_D <= 12'h000;
        else if (!display_enable || !display_valid)
            VGA_D <= 12'h000;
        else if ((vcnt >= waveform_y - 10'd1) && (vcnt <= waveform_y + 10'd1))
            VGA_D <= 12'h0f0;
        else if (vcnt == 10'd240)
            VGA_D <= 12'hfff;
        else
            VGA_D <= 12'h000;
    end

endmodule
