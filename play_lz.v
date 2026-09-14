module play_lz(	
	CLK50MHZ,
	SPK_KX,
	HIGH,
	LED
);
input CLK50MHZ;
output HIGH;
output SPK_KX;
output [3:0] LED;
//reg HIGH;
//reg SPK_XX;
//reg [3:0] LED;

wire c0;
wire c1;
PLL	PLL_inst (
	.areset    (areset),
	.inclk0 ( CLK50MHZ ),
	.locked    (locked),
	.c0 ( c0),
	.c1 ( c1 ),
	.c2 (),      //像素时钟
   .c3 (),   //5倍像素时钟
	);



wire clk4hz;
FDIV fdiv(
	.CLK(c1),
	.PM(clk4hz)
	);

wire [7:0] cnt8;
CNT138T cnt138(
	.CLK(clk4hz),
	.CNT8(cnt8)
	);

wire [3:0] q;
music	music_inst (
	.address ( cnt8 ),
	.clock ( clk4hz ),
	.q ( q )
	);

wire [10:0] TN;
wire [3:0] LED;
wire HIGH;
F_CODE fcode (
	.INX(q),
	.CODE(LED),
	.TO(TN),
	.H(HIGH)
	);

wire spk;
SPKER speker (
	.CLK(c0),
	.TN(TN),
	.SPKS(spk)
);

wire Q;
DFF DFF1(
	.CLK(spk),
	.D(!Q),
	.Q(Q)
);
assign SPK_KX = Q;
endmodule 