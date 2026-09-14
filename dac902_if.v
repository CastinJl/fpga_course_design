// DAC902 interface for the experiment box.
// Data is updated on clk rising edges and the inverted clock is sent to the DAC.
module dac902_if(
    input              clk,
    input              rst,
    input      [11:0]  data_in,
    output             da_clk,
    output reg [11:0]  da_dat
);

    assign da_clk = ~clk;

    always @(posedge clk or negedge rst) begin
        if (!rst) da_dat <= 12'd2048;
        else      da_dat <= data_in;
    end

endmodule
