`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// Engineer: Gim Hong and Brian Plancher
//
// Module Name:    blob 
//
// Additional Comments: Updated by Brian Plancher 11/3/15 to use my custom geometry
//                      and to pull location as the center of the square
//
//////////////////////////////////////////////////////////////////////////////////
module blob
	#(parameter WIDTH = 64,HEIGHT = 64,COLOR = 24'hFF_FF_FF,BLANK_COLOR=24'h00_00_00)
    (input signed [11:0] x,
     input signed [11:0] x_value,
     input signed [11:0] y,
     input signed [11:0] y_value,
     output reg [23:0] pixel);
	  
	 always @(*) begin
		if ((x_value >= (x-WIDTH/2) && x_value < (x+WIDTH/2)) && (y_value >= (y-HEIGHT/2) && y_value < (y+HEIGHT/2))) begin
			pixel = COLOR;
		end
		else begin
			pixel = BLANK_COLOR;
		end
	 end

endmodule
