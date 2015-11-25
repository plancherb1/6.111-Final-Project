`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        MIT 6.111 Final Project
// Engineer:       Brian Plancher
// 
// Module Name:    Calculate Abs Difference of Two numbers
// Project Name:   FPGA Phone Home
//////////////////////////////////////////////////////////////////////////////////

module abs_diff_9(
    input [9:0] x,
    input [9:0] y,
    output [9:0] absdiff
    );
	 
	 assign absdiff = (x>y) ? x-y : y-x;


endmodule
