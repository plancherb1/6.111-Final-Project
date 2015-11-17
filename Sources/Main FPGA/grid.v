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
					 VERTICAL_OFFSET = 64, WIDTH = 4)
    (input signed [11:0] x_value,
     input signed [11:0] y_value,
     output reg [23:0] pixel);
	
   // parameters that define the radius sizes   
	parameter R_6 = 1000*1000;
   parameter R_5 = 800*800;
   parameter R_4 = 600*600;
   parameter R_3 = 400*400;
   parameter R_2 = 200*200;
   parameter R_1 = 100*100;
   
   // pre-calculate always the values we need for the calculations which are easily done
   // within each clock cycle as they are simple multiplies so we are fine
   wire signed [31:0] d_2; // large bit size to handle the square
   wire signed [31:0] test_15deg; // large bit size to multiply and shift
   wire signed [31:0] test_45deg; // large bit size to multiply and shift
   wire signed [31:0] test_75deg; // large bit size to multiply and shift
   assign d_2 = x_value * x_value + y_value * y_value;
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
	assign comp15pos = 	((test_15deg - y_value - VERTICAL_OFFSET) < WIDTH/2) && 
								((test_15deg - y_value - VERTICAL_OFFSET) > WIDTH/2);
	assign comp15neg = 	((test_15deg + y_value - VERTICAL_OFFSET) < WIDTH/2) && 
								((test_15deg + y_value - VERTICAL_OFFSET) > WIDTH/2);
	assign comp45pos = 	((test_45deg - y_value - VERTICAL_OFFSET) < WIDTH/2) && 
								((test_45deg - y_value - VERTICAL_OFFSET) > WIDTH/2);
	assign comp45neg = 	((test_45deg + y_value - VERTICAL_OFFSET) < WIDTH/2) && 
								((test_45deg + y_value - VERTICAL_OFFSET) > WIDTH/2);
	assign comp75pos = 	((test_75deg - y_value - VERTICAL_OFFSET) < WIDTH/2) && 
								((test_75deg - y_value - VERTICAL_OFFSET) > WIDTH/2);
	assign comp75neg = 	((test_75deg + y_value - VERTICAL_OFFSET) < WIDTH/2) && 
								((test_75deg + y_value - VERTICAL_OFFSET) > WIDTH/2);
   assign on_radial_line = comp15pos | comp15neg | comp45pos | comp45neg | comp75pos | comp75neg;
	
   always @(*) begin
		// first make sure to draw our boundary at the bottom
		if (y_value < VERTICAL_OFFSET) begin
			pixel = GRID_COLOR;
		end
      // else test if we are on one of the radial lines or arcs
      else begin
			// first radial lines
			if (on_radial_line) begin
				pixel = GRID_COLOR;
			end
			// if not then arcs or return blank
			else begin
				case (d_2)
					R_1: pixel = GRID_COLOR;
					R_2: pixel = GRID_COLOR;
					R_3: pixel = GRID_COLOR;
					R_4: pixel = GRID_COLOR;
					R_5: pixel = GRID_COLOR;
					R_6: pixel = GRID_COLOR;
					default: pixel = BLANK_COLOR;
				endcase
			end
		end
   end

endmodule
