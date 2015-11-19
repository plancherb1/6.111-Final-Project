`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        MIT 6.111 Final Project
// Engineer:       Brian Plancher
// 
// Module Name:    Grid
// Project Name:   FPGA Phone Home
//
// Notes: Display the lines for the various angles (starting at 15 every 30) and
//        6 circles of parameter defined radius that make up the background grid image
//        only involves singular multiplies and bitshift/add/sub which should clear in one
//        clock cycle which is what we need
//////////////////////////////////////////////////////////////////////////////////

module grid
	#(parameter BLANK_COLOR = 24'h00_00_00, GRID_COLOR = 24'hFF_00_00, 
					 LEFT_BORDER = -128, RIGHT_BORDER = 128,
					 TOP_BORDER = 640, BOTTOM_BORDER = 128, LINE_WIDTH = 1)
    (input signed [11:0] x_value,
     input signed [11:0] y_value,
     output reg [23:0] pixel);
	
	wire on_border;
	wire out_of_border;
	// give border width of BORDER_WIDTH extending out
	parameter BORDER_WIDTH = 3;
	assign on_border = 		((x_value - RIGHT_BORDER >= 0) && (x_value - RIGHT_BORDER <= BORDER_WIDTH)) |
									//((RIGHT_BORDER - x_value >= 0) && (RIGHT_BORDER - x_value <= BORDER_WIDTH)) |
									((y_value - TOP_BORDER >= 0) && (y_value - TOP_BORDER <= BORDER_WIDTH)); //|
									//((BOTTOM_BORDER - y_value <= 0) && (BOTTOM_BORDER - y_value <= BORDER_WIDTH));
	assign out_of_border = 	(x_value > RIGHT_BORDER + BORDER_WIDTH) 	| (x_value < LEFT_BORDER - BORDER_WIDTH) |
									(y_value > TOP_BORDER + BORDER_WIDTH) 	| (y_value < BOTTOM_BORDER - BORDER_WIDTH);
	
	/// NEED TO FINISHING FIXING THE ABOVE!!!!!!! the uncommented work so just fix commented
	
	
	// get our effective y (note: effective x is the same)
	wire signed [11:0] y_value_e = y_value - BOTTOM_BORDER;
	
   // parameters that define the radius sizes for arcs
	parameter R_7 = 224*224;
	parameter R_6 = 192*192;
	parameter R_5 = 160*160;
   parameter R_4 = 128*128;
   parameter R_3 = 96*96;
   parameter R_2 = 64*64;
   parameter R_1 = 32*32;
	
	// Then calc the distance and compare to the arcs
	wire signed [31:0] d_2; // large bit size to handle the square
	assign d_2 = (x_value * x_value) + (y_value_e * y_value_e);
	wire on_arc;
	// note from experimentation I have found that I need larger widths to account for
	// rounding as the arcs get bigger
	parameter ROUNDING_FACTOR = 64;
	parameter ROUNDING_FACTOR_2 = 128;
	parameter ROUNDING_FACTOR_4 = 256;
	assign on_arc =  ((d_2 - R_1 - (LINE_WIDTH*ROUNDING_FACTOR) <= 0) && (d_2 - R_1 + (LINE_WIDTH*ROUNDING_FACTOR) >= 0)) |
							((d_2 - R_2 - (LINE_WIDTH*ROUNDING_FACTOR_2) <= 0) && (d_2 - R_2 + (LINE_WIDTH*ROUNDING_FACTOR_2) >= 0)) |
							((d_2 - R_3 - (LINE_WIDTH*ROUNDING_FACTOR_2) <= 0) && (d_2 - R_3 + (LINE_WIDTH*ROUNDING_FACTOR_2) >= 0)) |
							((d_2 - R_4 - (LINE_WIDTH*ROUNDING_FACTOR_2) <= 0) && (d_2 - R_4 + (LINE_WIDTH*ROUNDING_FACTOR_2) >= 0)) |
							((d_2 - R_5 - (LINE_WIDTH*ROUNDING_FACTOR_4) <= 0) && (d_2 - R_5 + (LINE_WIDTH*ROUNDING_FACTOR_4) >= 0)) |
							((d_2 - R_6 - (LINE_WIDTH*ROUNDING_FACTOR_4) <= 0) && (d_2 - R_6 + (LINE_WIDTH*ROUNDING_FACTOR_4) >= 0)) |
							((d_2 - R_7 - (LINE_WIDTH*ROUNDING_FACTOR_4) <= 0) && (d_2 - R_7 + (LINE_WIDTH*ROUNDING_FACTOR_4) >= 0));
   
   // pre-calculate the values we need to test the radial_lines
   wire signed [31:0] test_15deg; // large bit size to multiply and shift
   wire signed [31:0] test_45deg; // large bit size to multiply and shift
   wire signed [31:0] test_75deg; // large bit size to multiply and shift
   assign test_15deg = (x_value*17) >>> 6;  // tan 15 is about 17/64
   assign test_45deg = x_value;             // tan 45 = 1
   assign test_75deg = (x_value*240) >>> 6; // tan 75 is about 240/64
   // note: tan 105 = -tan 75, tan 135 = -tan 45, tan 165 = -tan 15
	wire comp15pos;
	wire comp15neg;
	wire comp45pos;
	wire comp45neg;
	wire comp75pos;
	wire comp75neg;
	wire on_radial_line;
	assign comp15pos = 	((test_15deg - y_value + BOTTOM_BORDER) - LINE_WIDTH <= 0) && 
								((test_15deg - y_value + BOTTOM_BORDER) + LINE_WIDTH >= 0);
	assign comp15neg = 	((test_15deg + y_value - BOTTOM_BORDER) - LINE_WIDTH <= 0) && 
								((test_15deg + y_value - BOTTOM_BORDER) + LINE_WIDTH >= 0);
	assign comp45pos = 	((test_45deg - y_value + BOTTOM_BORDER) - LINE_WIDTH <= 0) && 
								((test_45deg - y_value + BOTTOM_BORDER) + LINE_WIDTH >= 0);
	assign comp45neg = 	((test_45deg + y_value - BOTTOM_BORDER) - LINE_WIDTH <= 0) && 
								((test_45deg + y_value - BOTTOM_BORDER) + LINE_WIDTH >= 0);
	// note from experimentation I have found that I need larger widths to account for 
	// rounding as the angle gets steeper
	parameter RADIAL_ROUNDING_FACTOR = 3;
	assign comp75pos = 	((test_75deg - y_value + BOTTOM_BORDER) - (LINE_WIDTH*RADIAL_ROUNDING_FACTOR) <= 0) && 
								((test_75deg - y_value + BOTTOM_BORDER) + (LINE_WIDTH*RADIAL_ROUNDING_FACTOR) >= 0);
	assign comp75neg = 	((test_75deg + y_value - BOTTOM_BORDER) - (LINE_WIDTH*RADIAL_ROUNDING_FACTOR) <= 0) && 
								((test_75deg + y_value - BOTTOM_BORDER) + (LINE_WIDTH*RADIAL_ROUNDING_FACTOR) >= 0);
	assign on_radial_line = comp15pos | comp15neg | comp45pos | comp45neg | comp75pos | comp75neg;
	
   always @(*) begin
		// test to see if not out of border and on a border, radial line, or arc
		if ((!out_of_border) && (on_border | on_arc | on_radial_line)) begin
			pixel = GRID_COLOR;
		end
      else begin
			pixel = BLANK_COLOR;
		end
   end

endmodule
