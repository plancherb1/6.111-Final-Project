`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   12:11:05 11/24/2015
// Design Name:   abs_val_8
// Module Name:   /afs/athena.mit.edu/user/p/l/plancher/Desktop/6.111-Final-Project/Test Fixtures/Main FPGA//abs_val_8_tb.v
// Project Name:  Main_FPGA
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: abs_val_8
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module abs_val_8_tb;

	// Inputs
	reg [8:0] v;

	// Outputs
	wire [7:0] absv;

	// Instantiate the Unit Under Test (UUT)
	abs_val_8 uut (
		.v(v), 
		.absv(absv)
	);

	initial begin
		// Initialize Inputs
		v = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		v = -1;
		#10;
		v = 1;
		#10;
		v = 0;
		#10;
		v = -11;
		#10
		v = 0;

	end
      
endmodule

