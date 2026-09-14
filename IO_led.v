module IO_led(clk50,PI,PIO);
      input        clk50;  
		input  [7:0] PI;
		output reg [7:0] PIO; 


  always@(posedge clk50)
	  PIO = PI;


endmodule 