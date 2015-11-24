`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// Engineer:  Brian Plancher
//
// Module Name:  Grid_TB
//
// Additional Comments: Updated by Brian Plancher 11/3/15 to use my custom geometry
//                      and to pull location as the center of the square
//
//////////////////////////////////////////////////////////////////////////////////

module grid_tb;

	// Inputs
	reg [11:0] x_value;
	reg [11:0] y_value;
	reg clock;

	// Outputs
	wire [23:0] pixel;

	// Instantiate the Unit Under Test (UUT)
	grid uut (
		.x_value(x_value), 
		.y_value(y_value),
		.clock(clock),
		.pixel(pixel)
	);
	
	always #5 clock = !clock;
	initial begin
		// Initialize Inputs
		x_value = 0;
		y_value = 0;
		clock = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		// test border
		y_value = 128;
		#10;
		// test arc;
		y_value = 254;
		x_value = 23;
		#10;
		// test line;
		y_value = 178;
		x_value = 50;
		#10;
		y_value = 0;
		x_value = 0;

	end
      
endmodule

