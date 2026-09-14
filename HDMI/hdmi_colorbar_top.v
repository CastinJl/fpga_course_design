module  hdmi_colorbar_top(
    input        sys_clk,
    input        sys_rst_n,

    output       tmdX_clk_p,    // TMDS 时钟通道
    output       tmdX_clk_n,
    output [2:0] tmdX_data_p,   // TMDS 数据通道
    output [2:0] tmdX_data_n,	

	
    output       tmds_clk_p,    // TMDS 时钟通道
    output       tmds_clk_n,
    output [2:0] tmds_data_p,   // TMDS 数据通道
    output [2:0] tmds_data_n
);

//wire define
wire          pixel_clk;
wire          pixel_clk_5x;
wire          clk_locked;

wire  [10:0]  pixel_xpos_w;
wire  [10:0]  pixel_ypos_w;
wire  [23:0]  pixel_data_w;

wire          video_hs;
wire          video_vs;
wire          video_de;
wire  [23:0]  video_rgb;

//*****************************************************
//**                    main code
//*****************************************************

//例化PLL IP核
PLL  u_PLL(
    .areset    (~sys_rst_n),
    .inclk0    (sys_clk),
	 .c0        (),      //像素时钟
    .c1        (),   //5倍像素时钟
    .c2        (pixel_clk),      //像素时钟
    .c3        (pixel_clk_5x),   //5倍像素时钟
    .locked    (clk_locked)
);

//例化视频显示驱动模块
video_driver u_video_driver(
    .pixel_clk      (pixel_clk),
    .sys_rst_n      (sys_rst_n & clk_locked),

    .video_hs       (video_hs),
    .video_vs       (video_vs),
    .video_de       (video_de),
    .video_rgb      (video_rgb),
    .data_req       (),
    
    .pixel_xpos     (pixel_xpos_w),
    .pixel_ypos     (pixel_ypos_w),
    .pixel_data     (pixel_data_w)
    );

//例化视频显示模块
video_display  u_video_display(
    .pixel_clk      (pixel_clk),
    .sys_rst_n      (sys_rst_n & clk_locked),

    .pixel_xpos     (pixel_xpos_w),
    .pixel_ypos     (pixel_ypos_w),
    .pixel_data     (pixel_data_w)
    );

//例化HDMI驱动模块
dvi_transmitter_top u_rgb2dvi_0(
    .pclk           (pixel_clk),
    .pclk_x5        (pixel_clk_5x),
    .reset_n        (sys_rst_n & clk_locked),
                
    .video_din      (video_rgb),
    .video_hsync    (video_hs), 
    .video_vsync    (video_vs),
    .video_de       (video_de),
                
    .tmds_clk_p     (tmds_clk_p),
    .tmds_clk_n     (tmds_clk_n),
    .tmds_data_p    (tmds_data_p),
    .tmds_data_n    (tmds_data_n),

    .tmdX_clk_p     (tmdX_clk_p),
    .tmdX_clk_n     (tmdX_clk_n),
    .tmdX_data_p    (tmdX_data_p),
    .tmdX_data_n    (tmdX_data_n)	 
	 
	 
	 
    );



	 

	 
endmodule 
