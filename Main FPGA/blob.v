`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:04:10 09/30/2015 
// Design Name: 
// Module Name:    blob 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module blob
	#(parameter WIDTH = 64,HEIGHT = 64,COLOR = 24'hFF_FF_FF)
    (input [10:0] x,
     input [10:0] hcount,
     input [9:0] y,
     input [9:0] vcount,
     output reg [23:0] pixel);
	  
	 always @(*) begin
		if ((hcount >= x && hcount < (x+WIDTH)) && (vcount >= y && vcount < (y+HEIGHT))) begin
			pixel = COLOR;
		end
		else begin
			pixel = 0;
		end
	 end

endmodule
