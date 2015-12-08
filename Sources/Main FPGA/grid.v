`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        MIT 6.111 Final Project
// Engineer:       Brian Plancher
// 
// Module Name:    Grid
// Project Name:   FPGA Radar Guidance
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
     input clock,
     output reg [23:0] pixel);
	
   // helpers for BORDERS and E Values
   reg on_border;
	reg out_of_border;
	parameter BORDER_WIDTH = 3; // give border width of BORDER_WIDTH extending out
	// get our effective y and x and r values
	reg signed [11:0] y_value_e;
   reg signed [11:0] x_value_e;
   
   // parameters and helpers for test values and get radius
	reg signed [31:0] test_15deg; // large bit size to multiply and shift
	reg signed [31:0] test_45deg; // large bit size to multiply and shift
	reg signed [31:0] test_75deg; // large bit size to multiply and shift
	reg [31:0] r_e; // large bit size to multiply
   // keep passign the current y_e and borders
	reg signed [11:0] y_value_e2;
	reg on_border2;
	reg out_of_border2;
   
   // parameters and helpers for on radial line and on arc
	reg on_arc;
	parameter R_7 = 224*224;
	parameter R_6 = 192*192;
	parameter R_5 = 160*160;
	parameter R_4 = 128*128;
	parameter R_3 = 96*96;
	parameter R_2 = 64*64;
	parameter R_1 = 32*32;
   // note: tan 105 = -tan 75, tan 135 = -tan 45, tan 165 = -tan 15
	reg on_15_pos;
	reg on_15_neg;
	reg on_45_pos;
	reg on_45_neg;
	reg on_75_pos;
	reg on_75_neg;
	// note from experimentation I have found that I need larger widths to account for 
	// rounding as the angle gets steeper adn width bigger
	parameter ROUNDING_FACTOR = 64;
	parameter ROUNDING_FACTOR_2 = 2*ROUNDING_FACTOR;
	parameter ROUNDING_FACTOR_4 = 4*ROUNDING_FACTOR;
	parameter RADIAL_ROUNDING_FACTOR = 3;
   // keep passing borders
	reg on_border3;
	reg out_of_border3;
   
   // this all needs to be pipelined as it won't complete in one clock cycle
   always @(posedge clock) begin
   
      // phase 1: borders and E values
      y_value_e <= y_value - BOTTOM_BORDER;
      x_value_e <= x_value;
      on_border <=(x_value - RIGHT_BORDER >= 0) | (x_value - LEFT_BORDER <= 0) |
                  (y_value - TOP_BORDER >= 0) | (y_value - BOTTOM_BORDER <= 0);
      out_of_border <=  (x_value > RIGHT_BORDER + BORDER_WIDTH) 	| (x_value < LEFT_BORDER - BORDER_WIDTH) |
                        (y_value > TOP_BORDER + BORDER_WIDTH) 	| (y_value < BOTTOM_BORDER - BORDER_WIDTH);
         
      // phase 2 get TEST_VALUES and get radius
      test_15deg <= (x_value_e*17) >>> 6;  // tan 15 is about 17/64
      test_45deg <= x_value_e;             // tan 45 = 1
      test_75deg <= (x_value_e*240) >>> 6; // tan 75 is about 240/64
      r_e <= x_value_e*x_value_e + y_value_e*y_value_e;
		// keep y and the borders
      y_value_e2 <= y_value_e;
      on_border2 <= on_border;
      out_of_border2 <= out_of_border;
   
      // phase 3 ON_RADIAL and ON_ARC
      on_15_pos <= 	((test_15deg - y_value_e2) - LINE_WIDTH <= 0) && 
                     ((test_15deg - y_value_e2) + LINE_WIDTH >= 0);
      on_15_neg <= 	((test_15deg + y_value_e2) - LINE_WIDTH <= 0) && 
                     ((test_15deg + y_value_e2) + LINE_WIDTH >= 0);
      on_45_pos <= 	((test_45deg - y_value_e2) - LINE_WIDTH <= 0) && 
                     ((test_45deg - y_value_e2) + LINE_WIDTH >= 0);
      on_45_neg <= 	((test_45deg + y_value_e2) - LINE_WIDTH <= 0) && 
                     ((test_45deg + y_value_e2) + LINE_WIDTH >= 0);
      on_75_pos <= 	((test_75deg - y_value_e2) - (LINE_WIDTH*RADIAL_ROUNDING_FACTOR) <= 0) && 
                     ((test_75deg - y_value_e2) + (LINE_WIDTH*RADIAL_ROUNDING_FACTOR) >= 0);
      on_75_neg <= 	((test_75deg + y_value_e2) - (LINE_WIDTH*RADIAL_ROUNDING_FACTOR) <= 0) && 
                     ((test_75deg + y_value_e2) + (LINE_WIDTH*RADIAL_ROUNDING_FACTOR) >= 0);
      on_arc <= ((r_e - R_1 - (LINE_WIDTH*ROUNDING_FACTOR) <= 0) && (r_e - R_1 + (LINE_WIDTH*ROUNDING_FACTOR) >= 0)) |
                ((r_e - R_2 - (LINE_WIDTH*ROUNDING_FACTOR_2) <= 0) && (r_e - R_2 + (LINE_WIDTH*ROUNDING_FACTOR_2) >= 0)) |
                ((r_e - R_3 - (LINE_WIDTH*ROUNDING_FACTOR_2) <= 0) && (r_e - R_3 + (LINE_WIDTH*ROUNDING_FACTOR_2) >= 0)) |
                ((r_e - R_4 - (LINE_WIDTH*ROUNDING_FACTOR_2) <= 0) && (r_e - R_4 + (LINE_WIDTH*ROUNDING_FACTOR_2) >= 0)) |
                ((r_e - R_5 - (LINE_WIDTH*ROUNDING_FACTOR_4) <= 0) && (r_e - R_5 + (LINE_WIDTH*ROUNDING_FACTOR_4) >= 0)) |
                ((r_e - R_6 - (LINE_WIDTH*ROUNDING_FACTOR_4) <= 0) && (r_e - R_6 + (LINE_WIDTH*ROUNDING_FACTOR_4) >= 0)) |
                ((r_e - R_7 - (LINE_WIDTH*ROUNDING_FACTOR_4) <= 0) && (r_e - R_7 + (LINE_WIDTH*ROUNDING_FACTOR_4) >= 0));
      on_border3 <= on_border2;
      out_of_border3 <= out_of_border2;               
      
      // phase 4 Report out the value
      // test to see if not out of border and on a border, radial line, or arc
      if ((!out_of_border3) && (on_border3 | on_arc | on_15_pos | on_15_neg | 
                                 on_45_pos | on_45_neg | on_75_pos | on_75_neg)) begin
         pixel <= GRID_COLOR;
      end
      else begin
         pixel <= BLANK_COLOR;
      end

   end
endmodule
