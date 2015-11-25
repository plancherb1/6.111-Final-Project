`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        MIT 6.111 Final Project
// Engineer:       Brian Plancher
// 
// Module Name:    Quadrant Calc
// Project Name:   FPGA Phone Home
//
//////////////////////////////////////////////////////////////////////////////////
module quadrant(
    input signed [8:0] x,
    input signed [8:0] y,
    output [1:0] q
    );
	 
	 wire [1:0] x_p;
	 wire [1:0] x_n;
	 assign x_p = (y >= 0) ? 0 : 3;
	 assign x_n = (y >= 0) ? 1 : 2;
	 assign q = (x >= 0) ? x_p : x_n;

endmodule
