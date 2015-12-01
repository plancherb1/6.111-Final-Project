`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   21:56:33 11/24/2015
// Design Name:   triangle
// Module Name:   /afs/athena.mit.edu/user/p/l/plancher/Desktop/6.111-Final-Project/Test Fixtures/Main FPGA//triangle_tb.v
// Project Name:  Main_FPGA
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: triangle
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module triangle_tb;

	// Inputs
	reg [11:0] center_x;
	reg [11:0] x_value;
	reg [11:0] center_y;
	reg [11:0] y_value;
	reg [4:0] orientation;
	reg clock;

	// Outputs
	wire [23:0] pixel;

	// Instantiate the Unit Under Test (UUT)
	triangle 
	 #(	.WIDTH(200),
			.HEIGHT(200),
			.COLOR(24'hFF_FF_FF),
			.BLANK_COLOR(24'h00_00_00),
			.INDICATOR_COLOR(24'h00_FF_00)
	)
    uut(	.center_x(center_x), 
			.x_value(x_value), 
			.center_y(center_y), 
			.y_value(y_value), 
			.orientation(orientation), 
			.clock(clock), 
			.pixel(pixel)
	);
	
	always #5 clock = !clock;
	initial begin
		// Initialize Inputs
		center_x = 0;
		x_value = 0;
		center_y = 0;
		y_value = 0;
		orientation = 0;
		clock = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		center_x = 0;
		center_y = 128;
		#10;
		
		// lets see what a couple angles are
		orientation = 0;
		#10;
		orientation = 1;
		#10;
		orientation = 7;
		#10;
		orientation = 11;
		#10;
		orientation = 13;
		#10;
		orientation = 17;
		#10;
		orientation = 23;
		#10;
		
		// lets test a couple points to see if they are showing up on lines
		orientation = 0;
		center_y = 0;
		x_value = 10;
		y_value = 0;
		#10; // should be on00
		y_value = 26;
		x_value = 97;
		#10; // shoudl be on15
		y_value = 67;
		x_value = 116;
		#10; // shoudl be on30
		y_value = 15;
		x_value = 15;
		#10; // shoudl be on45
		y_value = 116;
		x_value = 67;
		#10; // shoudl be on60
		y_value = 15;
		x_value = 4;
		#10; // shoudl be on 75
		y_value = 116;
		x_value = 0;
		#10; // shoudl be on90
		
		// now given an orientationa and a point lets see if it gets it right
		center_x = 0;
		center_y = 100;
		orientation = 13;
		x_value = 26;
		y_value = 3; // delta y is negative 97
		// we should have on_75 light up and be an output
		#10;
		x_value = 0;
		y_value = 0;
		// we should be on normal color inside shape
		#10;
		y_value = 1000;
		//out of border
		#10;
		x_value = -97;
		y_value = 100-26; // delta y is negative 26
		
		

	end
      
endmodule

