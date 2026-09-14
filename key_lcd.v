`timescale 1ns / 1ps
module key_lcd(
    input         CLK,      // 20MHz时钟输入
    input         RST,      // 复位信号（低电平有效）
    input  [7:0]  KEY,      // 8个按键（按下对应一个花样）
    output reg [11:0] LED   // 12个LED输出
);

reg         cnt;           // 计数器，用于产生LED变化的节拍
reg [3:0]  step;          // 用于记录花样的步骤

// 简单的计数器，让LED变化慢下来（也可以通过硬件调节20MHz频率来改变速度）
always @(posedge CLK or negedge RST)
    if(!RST) cnt <= 0;
    else     cnt <= cnt + 1;

// 核心逻辑：根据按键选择花样，在cnt最高位变化时更新LED
always @(posedge CLK or negedge RST) begin
    if(!RST) begin
        LED <= 0;
        step <= 0;
    end else if(cnt == 0) begin  // 每过一段时间更新一次LED
        case(KEY)
            // 按键0：从右向左流水
            8'b00000001: begin
                if(LED == 0 || LED[11]) LED <= 12'b000000000001;
                else LED <= LED << 1;
            end

            // 按键1：从左向右流水
            8'b00000010: begin
                if(LED == 0 || LED[0]) LED <= 12'b100000000000;
                else LED <= LED >> 1;
            end

            // 按键2：两端向中间流动
            8'b00000100: begin
                case(step)
                    0: LED <= 12'b100000000001;
                    1: LED <= 12'b110000000011;
                    2: LED <= 12'b111000000111;
                    3: LED <= 12'b111100001111;
                    4: LED <= 12'b111110011111;
                    5: LED <= 12'b000001100000;
                endcase
                if(step == 5) step <= 0;
                else step <= step + 1;
            end

            // 按键3：中间向两端扩散
            8'b00001000: begin
                case(step)
                    0: LED <= 12'b000001100000;
                    1: LED <= 12'b000011110000;
                    2: LED <= 12'b000111111000;
                    3: LED <= 12'b001111111100;
                    4: LED <= 12'b011111111110;
                    5: LED <= 12'b100000000001;
                endcase
                if(step == 5) step <= 0;
                else step <= step + 1;
            end

            // 按键4：交替闪烁
            8'b00010000: begin
                LED <= ~LED;
                if(LED == 0) LED <= 12'b101010101010;
            end

            // 按键5：跑马灯（3个一组）
            8'b00100000: begin
                if(LED == 0 || LED[0]) LED <= 12'b111000000000;
                else LED <= {1'b0, LED[11:1]};
            end

            // 按键6：全部闪烁
            8'b01000000: begin
                LED <= ~LED;
            end

            // 按键7：累积点亮
            8'b10000000: begin
                case(step)
                    0:  LED <= 12'b000000000001;
                    1:  LED <= 12'b000000000011;
                    2:  LED <= 12'b000000000111;
                    3:  LED <= 12'b000000001111;
                    4:  LED <= 12'b000000011111;
                    5:  LED <= 12'b000000111111;
                    6:  LED <= 12'b000001111111;
                    7:  LED <= 12'b000011111111;
                    8:  LED <= 12'b000111111111;
                    9:  LED <= 12'b001111111111;
                    10: LED <= 12'b011111111111;
                    11: LED <= 12'b111111111111;
                    12: LED <= 12'b000000000000;
                endcase
                if(step == 12) step <= 0;
                else step <= step + 1;
            end

            default: LED <= 0;
        endcase
    end
end

endmodule