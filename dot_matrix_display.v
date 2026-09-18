// 16x16 dot-matrix scanner.
// The row and column polarities follow the official KXMS65P example.
// Four characters are multiplexed in sequence: Hang, Zhou, Kang, Xin.
module dot_matrix_display(
    input             clk,
    input             rst,
    input             show_enable,
    output reg [15:0] dataout,
    output reg [15:0] en
);

    reg [15:0] scan_count;
    reg [1:0]  char_index;
    reg [24:0] char_count;
    reg [3:0]  row_index;

    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            scan_count <= 16'd0;
            char_index <= 2'd0;
            char_count <= 25'd0;
        end else begin
            scan_count <= scan_count + 1'b1;

            if (char_count == 25'd9_999_999) begin
                char_count <= 25'd0;
                char_index <= char_index + 1'b1;
            end else begin
                char_count <= char_count + 1'b1;
            end
        end
    end

    always @(*) begin
        row_index = scan_count[15:12];

        case (row_index)
            4'd0:  en = 16'b1111_1111_1111_1110;
            4'd1:  en = 16'b1111_1111_1111_1101;
            4'd2:  en = 16'b1111_1111_1111_1011;
            4'd3:  en = 16'b1111_1111_1111_0111;
            4'd4:  en = 16'b1111_1111_1110_1111;
            4'd5:  en = 16'b1111_1111_1101_1111;
            4'd6:  en = 16'b1111_1111_1011_1111;
            4'd7:  en = 16'b1111_1111_0111_1111;
            4'd8:  en = 16'b1111_1110_1111_1111;
            4'd9:  en = 16'b1111_1101_1111_1111;
            4'd10: en = 16'b1111_1011_1111_1111;
            4'd11: en = 16'b1111_0111_1111_1111;
            4'd12: en = 16'b1110_1111_1111_1111;
            4'd13: en = 16'b1101_1111_1111_1111;
            4'd14: en = 16'b1011_1111_1111_1111;
            4'd15: en = 16'b0111_1111_1111_1111;
            default: en = 16'b1111_1111_1111_1111;
        endcase

        if (!show_enable)
            dataout = 16'h0000;
        else begin
            case (char_index)
                2'd0: dataout = hang_row(row_index);
                2'd1: dataout = zhou_row(row_index);
                2'd2: dataout = kang_row(row_index);
                2'd3: dataout = xin_row(row_index);
                default: dataout = 16'h0000;
            endcase
        end
    end

    function [15:0] hang_row;
        input [3:0] row;
        begin
            case (row)
                4'd0:  hang_row = 16'h0410;
                4'd1:  hang_row = 16'h0310;
                4'd2:  hang_row = 16'h00d0;
                4'd3:  hang_row = 16'hffff;
                4'd4:  hang_row = 16'h0090;
                4'd5:  hang_row = 16'h8310;
                4'd6:  hang_row = 16'h6008;
                4'd7:  hang_row = 16'h1fc8;
                4'd8:  hang_row = 16'h0049;
                4'd9:  hang_row = 16'h004e;
                4'd10: hang_row = 16'h0048;
                4'd11: hang_row = 16'h3fc8;
                4'd12: hang_row = 16'h4008;
                4'd13: hang_row = 16'h4008;
                4'd14: hang_row = 16'h7800;
                4'd15: hang_row = 16'h0000;
                default: hang_row = 16'h0000;
            endcase
        end
    endfunction

    function [15:0] zhou_row;
        input [3:0] row;
        begin
            case (row)
                4'd0:  zhou_row = 16'h8100;
                4'd1:  zhou_row = 16'h40e0;
                4'd2:  zhou_row = 16'h3000;
                4'd3:  zhou_row = 16'h0fff;
                4'd4:  zhou_row = 16'h0000;
                4'd5:  zhou_row = 16'h0020;
                4'd6:  zhou_row = 16'h00c0;
                4'd7:  zhou_row = 16'h0000;
                4'd8:  zhou_row = 16'h3ffe;
                4'd9:  zhou_row = 16'h0000;
                4'd10: zhou_row = 16'h0020;
                4'd11: zhou_row = 16'h00c0;
                4'd12: zhou_row = 16'h0000;
                4'd13: zhou_row = 16'hffff;
                4'd14: zhou_row = 16'h0000;
                4'd15: zhou_row = 16'h0000;
                default: zhou_row = 16'h0000;
            endcase
        end
    endfunction

    function [15:0] kang_row;
        input [3:0] row;
        begin
            case (row)
                4'd0:  kang_row = 16'h4000;
                4'd1:  kang_row = 16'h3000;
                4'd2:  kang_row = 16'h0ffc;
                4'd3:  kang_row = 16'h4044;
                4'd4:  kang_row = 16'h2354;
                4'd5:  kang_row = 16'h5415;
                4'd6:  kang_row = 16'h4954;
                4'd7:  kang_row = 16'h8155;
                4'd8:  kang_row = 16'h7ffe;
                4'd9:  kang_row = 16'h0554;
                4'd10: kang_row = 16'h0954;
                4'd11: kang_row = 16'h1154;
                4'd12: kang_row = 16'h29f4;
                4'd13: kang_row = 16'h4444;
                4'd14: kang_row = 16'h4044;
                4'd15: kang_row = 16'h0000;
                default: kang_row = 16'h0000;
            endcase
        end
    endfunction

    function [15:0] xin_row;
        input [3:0] row;
        begin
            case (row)
                4'd0:  xin_row = 16'h1004;
                4'd1:  xin_row = 16'h0804;
                4'd2:  xin_row = 16'h0604;
                4'd3:  xin_row = 16'h0004;
                4'd4:  xin_row = 16'h001f;
                4'd5:  xin_row = 16'h3f04;
                4'd6:  xin_row = 16'h4024;
                4'd7:  xin_row = 16'h4044;
                4'd8:  xin_row = 16'h4084;
                4'd9:  xin_row = 16'h4004;
                4'd10: xin_row = 16'h401f;
                4'd11: xin_row = 16'h7004;
                4'd12: xin_row = 16'h0104;
                4'd13: xin_row = 16'h0204;
                4'd14: xin_row = 16'h0c04;
                4'd15: xin_row = 16'h0000;
                default: xin_row = 16'h0000;
            endcase
        end
    endfunction

endmodule
