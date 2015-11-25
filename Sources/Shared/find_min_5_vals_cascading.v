`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        MIT 6.111 Final Project
// Engineer:       Brian Plancher
// 
// Module Name:    Find Min 5 Vals Cascading
// Project Name:   FPGA Phone Home
//
// note: this works because as long as the input is unifomrally growing
//			then if you approach it in a linear fassion you can exploit the 
//       uniform increase to compare faster
//
// note2: THIS IS INDEX 1 OUTPUT
//
//////////////////////////////////////////////////////////////////////////////////
module find_min_5_vals_cascading(
    input [7:0] input1,
    input [7:0] input2,
    input [7:0] input3,
    input [7:0] input4,
    input [7:0] input5,
    output [2:0] output_index
    );
	
	wire comp1_2;
	wire comp2_3;
	wire comp3_4;
	wire comp4_5;
	assign comp1_2 = input1 >= input2;
	assign comp2_3 = input2 >= input3;
	assign comp3_4 = input3 >= input4;
	assign comp4_5 = input4 >= input5;
	
	wire is1;
	wire is5;
	wire is2;
	wire is4;
	// if they are cascading smaller than 15 is the smallest
	assign is1 = ((!comp1_2) & (!comp2_3) & (!comp3_4) & (!comp4_5));
	// if they are cascading bigger than 75 is the smallest
	assign is5 = (comp1_2 & comp2_3 & comp3_4 & comp4_5);
	// if not 15 or 75 than can do same for cascading smaller for 30
	assign is2 = ((!is1) & (!is5) & (!comp2_3) & (!comp3_4));
	// if not 15 or 75 than can do same for cascading bigger for 60
	assign is4 = ((!is1) & (!is5) & (comp2_3) & (comp3_4));
	
	assign output_index = is1 ? 3'h1 : (is5 ? 3'h5 : (is2 ? 3'h2 : (is4 ? 3'h4 : 3'h3)));

endmodule
