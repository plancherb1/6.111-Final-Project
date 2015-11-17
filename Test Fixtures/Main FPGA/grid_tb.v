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

	// Outputs
	wire [23:0] pixel;

	// Instantiate the Unit Under Test (UUT)
	grid uut (
		.x_value(x_value), 
		.y_value(y_value), 
		.pixel(pixel)
	);

	initial begin
		// Initialize Inputs
		x_value = 0;
		y_value = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		// pixel should be "on" as we are below the threshold
		#10;
		y_value = 70;
		#10;
		// pixel shoudl be off
		y_value = 100;
		//pixel shoudl be on
		#10;
		y_value = 70;
		#10;
		//off
		y_value = 26;
		x_value = 79;
		// pixel shoudl be on

	end
      
endmodule

