`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   21:29:31 11/16/2015
// Design Name:   polar_to_cartesian
// Module Name:   /afs/athena.mit.edu/user/p/l/plancher/Desktop/6.111-Final-Project/Test Fixtures/Main FPGA//polar_to_cartesian_tb.v
// Project Name:  Main_FPGA
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: polar_to_cartesian
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module polar_to_cartesian_tb;

	// Inputs
	reg [11:0] r_theta;

	// Outputs
	wire [8:0] x_value;
	wire [8:0] y_value;

	// Instantiate the Unit Under Test (UUT)
	polar_to_cartesian uut (
		.r_theta(r_theta), 
		.x_value(x_value), 
		.y_value(y_value)
	);

	initial begin
		// Initialize Inputs
		r_theta = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		r_theta = 12'h1_64; // angle of 15 radius of 100 should get(97,26)
		#10;
		r_theta = 12'hB_64; // angle of 165 radius of 100 should get(-97,26)

	end
      
endmodule

