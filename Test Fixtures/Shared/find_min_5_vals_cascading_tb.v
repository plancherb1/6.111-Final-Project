`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        MIT 6.111 Final Project
// Engineer:       Brian Plancher
// 
// Module Name:    find_min_5_vals_cascading_tb
// Project Name:   FPGA Phone Home
//
//////////////////////////////////////////////////////////////////////////////////

module find_min_5_vals_cascading_tb;

	// Inputs
	reg [7:0] input1;
	reg [7:0] input2;
	reg [7:0] input3;
	reg [7:0] input4;
	reg [7:0] input5;

	// Outputs
	wire [2:0] output_index;

	// Instantiate the Unit Under Test (UUT)
	find_min_5_vals_cascading uut (
		.input1(input1), 
		.input2(input2), 
		.input3(input3), 
		.input4(input4), 
		.input5(input5), 
		.output_index(output_index)
	);

	initial begin
		// Initialize Inputs
		input1 = 0;
		input2 = 0;
		input3 = 0;
		input4 = 0;
		input5 = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		input1 = 1;
		input2 = 2;
		input3 = 3;
		input4 = 4;
		input5 = 5;
		#10; // shoudl be 1
		
		input1 = 5;
		input2 = 4;
		input3 = 3;
		input4 = 2;
		input5 = 1;
		#10; // shoudl be 5
		
		input1 = 7;
		input2 = 5;
		input3 = 3;
		input4 = 6;
		input5 = 7;
		#10; // shoudl be 3
		
		input1 = 9;
		input2 = 8;
		input3 = 7;
		input4 = 2;
		input5 = 3;
		#10; // shoudl be 4
		
		input1 = 22;
		input2 = 2;
		input3 = 5;
		input4 = 11;
		input5 = 19;
		#10; // shoudl be 2

	end
      
endmodule

