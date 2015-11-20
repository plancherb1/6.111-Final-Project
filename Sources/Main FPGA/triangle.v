`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        MIT 6.111 Final Project
// Engineer:       Brian Plancher
// 
// Module Name:    Triangle
// Project Name:   FPGA Phone Home
//
// Notes: Based off of Blob from Lab3
//////////////////////////////////////////////////////////////////////////////////
module triangle
	#(parameter WIDTH = 64,HEIGHT = 64,COLOR = 24'hFF_FF_FF,
	  BLANK_COLOR=24'h00_00_00,INDICATOR_COLOR = 24'h00_FF_00)
    (input signed [11:0] center_x,
     input signed [11:0] x_value,
     input signed [11:0] center_y,
     input signed [11:0] y_value,
	  input [4:0] orientation,
     output reg [23:0] pixel);
	 
	 // parameters needed to define lines and directions every 15 degrees
	 parameter WIDTH_D2 = WIDTH/2;
	 parameter WIDTH_D3 = WIDTH/3;
	 parameter WIDTH_D6 = WIDTH/6;
	 parameter HEIGHT_D2 = HEIGHT/2;
	 parameter HEIGHT_D3 = HEIGHT/3;
	 parameter HEIGHT_D6 = HEIGHT/6;
	 
	 wire in_square;
	 assign in_square = (x_value >= (center_x-WIDTH_D2) && x_value < (center_x+WIDTH_D2)) && (y_value >= (center_y-HEIGHT_D2) && y_value < (center_y+HEIGHT_D2)); 
	 
	 // find if we have pixels on the right angle
	 wire on_00;
	 wire on_15;
	 wire on_30;
	 wire on_45;
	 wire on_60;
	 wire on_75;
	 wire on_90;
	 wire signed [11:0] delta_x;
	 wire signed [11:0] delta_y;
	 wire signed [11:0] abs_delta_x;
	 wire signed [11:0] abs_delta_y;
	 assign delta_x = x_value - center_x;
	 assign delta_y = y_value - center_y;
	 assign abs_delta_x = (center_x > x_value) ? (center_x - x_value) : (x_value - center_x);
	 assign abs_delta_y = (center_y > y_value) ? (center_y - y_value) : (y_value - center_y);
	 
	 // while we are solving for 00 to 90 we are really solving for 00 to 90 + 90n to get
	 // all for directions and then using a quadrant test later
	 // for 00 and 90 need some x or y and 0 of the other
	 assign on_00 = (!(abs_delta_x == 0)) && (abs_delta_y == 0);
	 assign on_90 = (abs_delta_x == 0) && (!(abs_delta_y == 0));
	 // for 45 we need delta x = delta y
	 assign on_45 = abs_delta_x == abs_delta_y;
	 // for the rest we need to calc tangents
	 wire signed [31:0] test_on_15; // large bit size to multiply and shift
	 wire signed [31:0] test_on_30; // large bit size to multiply and shift
	 wire signed [31:0] test_on_60; // large bit size to multiply and shift
	 wire signed [31:0] test_on_75; // large bit size to multiply and shift
	 assign test_on_15 = ((abs_delta_x*17) >>> 6) - abs_delta_y;  // tan 15 is about 17/64
	 assign test_on_30 = ((abs_delta_x*37) >>> 6) - abs_delta_y; // tan 75 is about 37/64
	 assign test_on_60 = ((abs_delta_x*111) >>> 6) - abs_delta_y; // tan 75 is about 111/64
	 assign test_on_75 = ((abs_delta_x*240) >>> 6) - abs_delta_y; // tan 75 is about 240/64
	 // we need to apply a ROUNDING factor for the bit shift rounding
	 parameter ROUNDING_FACTOR = 0;
	 parameter ROUNDING_FACTOR_2 = 2 * ROUNDING_FACTOR;
	 assign on_15 = 	(test_on_15 - ROUNDING_FACTOR <= 0) && 
							(test_on_15 + ROUNDING_FACTOR >= 0);
	 assign on_30 = 	(test_on_30 - ROUNDING_FACTOR <= 0) && 
							(test_on_30 + ROUNDING_FACTOR >= 0);
	 assign on_60 = 	(test_on_60 - ROUNDING_FACTOR <= 0) && 
							(test_on_60 + ROUNDING_FACTOR >= 0);
	 assign on_75 = 	(test_on_75 - ROUNDING_FACTOR <= 0) && 
							(test_on_75 + ROUNDING_FACTOR_2 >= 0);
	 
	 // determine the quadrant that we are in for orientation
	 // orientation 0 = 0, 1 = 15 ... 24 = 90 so orientation / 6 == quadrant 
	 wire [31:0] quadrant; // large bit size to multiply and shift
	 assign quadrant = (orientation * 117) >> 10;// 1/6 is about 117/1024
	 
	 always @(*) begin
		if (in_square) begin
			if (on_00 | on_15 | on_30 | on_45 | on_60 | on_75 | on_90) begin
				pixel = INDICATOR_COLOR;
			end
			else begin
				pixel = COLOR;
			end
		end
		else begin
			pixel = BLANK_COLOR;
		end
	 end

endmodule
