`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   19:07:56 12/05/2015
// Design Name:   path_math
// Module Name:   /afs/athena.mit.edu/user/p/l/plancher/Desktop/6.111-Final-Project/Test Fixtures/Main FPGA//path_math_tb.v
// Project Name:  Main_FPGA
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: path_math
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module path_math_tb;

	// Inputs
	reg [11:0] location;
	reg [11:0] target;
	reg [4:0] current_orientation;
	reg [4:0] needed_orientation;
	reg clock;
	reg enable;
	reg reset;

	// Outputs
	wire done;
	wire [11:0] move_command;

	// Instantiate the Unit Under Test (UUT)
	path_math uut (
		.location(location), 
		.target(target), 
		.current_orientation(current_orientation), 
		.needed_orientation(needed_orientation), 
		.clock(clock), 
		.enable(enable), 
		.reset(reset), 
		.done(done), 
		.move_command(move_command)
	);
	
	always #5 clock = !clock;
	initial begin
		// Initialize Inputs
		location = 0;
		target = 0;
		current_orientation = 0;
		needed_orientation = 0;
		clock = 0;
		enable = 0;
		reset = 0;

		// Wait 100 ns for global reset to finish
		#100;
		reset = 1;
		#10;
		reset = 0;
        
		// Add stimulus here
		target = {4'h7,8'h30};//105 degrees 48 inches out
		location = {4'h1,8'h20}; //15 degrees 32 inches out
		current_orientation = 5'h01;
		needed_orientation = 5'h09;
		enable = 1;
		#10;
		enable = 0;

	end
      
endmodule

