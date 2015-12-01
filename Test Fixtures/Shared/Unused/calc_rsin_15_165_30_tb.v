`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   21:24:47 11/16/2015
// Design Name:   calc_rsin_15_165_30
// Module Name:   /afs/athena.mit.edu/user/p/l/plancher/Desktop/6.111-Final-Project/Test Fixtures/Main FPGA//calc_rsin_15_165_30_tb.v
// Project Name:  Main_FPGA
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: calc_rsin_15_165_30
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module calc_rsin_15_165_30_tb;

	// Inputs
	reg [7:0] r;

	// Outputs
	wire [7:0] rsin_15;
	wire [7:0] rsin_45;
	wire [7:0] rsin_75;

	// Instantiate the Unit Under Test (UUT)
	calc_rsin_15_165_30 uut (
		.r(r), 
		.rsin_15(rsin_15), 
		.rsin_45(rsin_45), 
		.rsin_75(rsin_75)
	);

	initial begin
		// Initialize Inputs
		r = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		r = 100; // shoudl be 70,26,99

	end
      
endmodule

