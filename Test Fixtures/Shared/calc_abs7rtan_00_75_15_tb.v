`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   12:23:33 11/24/2015
// Design Name:   calc_abs7rtan_00_75_15
// Module Name:   /afs/athena.mit.edu/user/p/l/plancher/Desktop/6.111-Final-Project/Test Fixtures/Main FPGA//calc_abs7rtan_00_75_15_tb.v
// Project Name:  Main_FPGA
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: calc_abs7rtan_00_75_15
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module calc_abs7rtan_00_75_15_tb;

	// Inputs
	reg [7:0] r;

	// Outputs
	wire [7:0] abs7rtan_15;
	wire [7:0] abs7rtan_30;
	wire [7:0] abs7rtan_45;
	wire [9:0] abs7rtan_60;
	wire [9:0] abs7rtan_75;

	// Instantiate the Unit Under Test (UUT)
	calc_abs7rtan_00_75_15 uut (
		.r(r), 
		.abs7rtan_15(abs7rtan_15), 
		.abs7rtan_30(abs7rtan_30), 
		.abs7rtan_45(abs7rtan_45), 
		.abs7rtan_60(abs7rtan_60), 
		.abs7rtan_75(abs7rtan_75)
	);

	initial begin
		// Initialize Inputs
		r = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		r = 0;
		#10;
		r = 10;
		#10;
		r = 7;
		#10;
		r = 111;
		#10;

	end
      
endmodule

