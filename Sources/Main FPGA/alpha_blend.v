`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        MIT 6.111 Final Project
// Engineer:       Brian Plancher
// 
// Module Name:    Alpha Blend
// Project Name:   FPGA Phone Home
//
//////////////////////////////////////////////////////////////////////////////////   
   
module alpha_blend 
   #(parameter ALPHA_M = 2,ALPHA_N = 4,ALPHA_N_LOG_2 = 2)
   (input [23:0] pixel_1,
    input [23:0] pixel_2,
    output [23:0] overlap_pixel);
     
   // compute the alpha blend of the rover and the target
   wire [7:0] alpha_blend_R;
   wire [7:0] alpha_blend_G;
   wire [7:0] alpha_blend_B;
   wire [23:0] alpha_blend_pixel;
	assign alpha_blend_R = ((pixel_1[23:16]*ALPHA_M)>>ALPHA_N_LOG_2) + 
	                           ((pixel_2[23:16]*(ALPHA_N-ALPHA_M))>>ALPHA_N_LOG_2);
	assign alpha_blend_G = ((pixel_1[15:8]*ALPHA_M)>>ALPHA_N_LOG_2) + 
	                           ((pixel_2[15:8]*(ALPHA_N-ALPHA_M))>>ALPHA_N_LOG_2);
	assign alpha_blend_B = ((pixel_1[7:0]*ALPHA_M)>>ALPHA_N_LOG_2) +
	                           ((pixel_2[7:0]*(ALPHA_N-ALPHA_M))>>ALPHA_N_LOG_2);
   assign alpha_blend_pixel = {alpha_blend_R, alpha_blend_G, alpha_blend_B};
   
   // show either the alpha blend or the one that exists if they don't overlap
	assign overlap_pixel = ((pixel_1 & pixel_2) > 0) ? alpha_blend_pixel : (pixel_1 | pixel_2);
   
endmodule