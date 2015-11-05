`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        MIT 6.111 Final Project
// Engineer:       Brian Plancher
// 
// Module Name:    Triangle
// Project Name:   FPGA Phone Home
//
// Notes: Based off of Blob from Lab3
//////////////////////////////////////////////////////////////////////////////////
module triangle
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
