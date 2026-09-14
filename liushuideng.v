module liushuideng(clk,led,rst);  
   input clk;
   input rst;
   output reg [11:0]  led;      //接P1IO口
   reg clk2hz;
   reg [24:0] count;           // 25位计数器（2^25 > 12,500,000）
   
   // 50MHz时钟分频为2Hz（周期500ms）
   always@(posedge clk )
      if(count == 25'd6249999) begin   // 50MHz/2Hz/2 = 12,500,000
         clk2hz = ~clk2hz;
         count = 25'd0;
      end
      else count = count + 1;  
      
   // 2Hz时钟控制LED移位
   always@(posedge clk2hz or negedge rst)
      if(!rst)  
         led = 12'hffe;          //led灯为共阳极，低电平点亮。
      else   
         led[11:0] = { led[10:0], led[11] };  // 循环左移
endmodule