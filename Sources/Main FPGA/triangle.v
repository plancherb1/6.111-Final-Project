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
     input clock,
     output reg [23:0] pixel);
	 
	 // parameters needed to define lines and directions every 15 degrees
	 parameter WIDTH_D2 = WIDTH/2;
	 parameter HEIGHT_D2 = HEIGHT/2;
	 parameter D180 = 12;
    parameter D360 = 24;
    
    // Phase 1 helpers
    reg in_square;
    reg signed [11:0] delta_x;
	 reg signed [11:0] delta_y;
	 reg signed [11:0] abs_delta_x;
	 reg signed [11:0] abs_delta_y;
    reg [31:0] orientation_quadrant; // large bit size to multiply and shift
    reg [4:0] orientation2;
    
    // Phase 2 helpers
    // while we are solving for 00 to 90 we are really solving for 00 to 90 + 90n to get
	 // all for directions and then using a quadrant test later
	 // for 00 and 90 need some x or y and 0 of the other
    reg on_00;
	 reg on_15;
	 reg on_30;
	 reg on_45;
	 reg on_60;
	 reg on_75;
	 reg on_90;
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
    // keep the quadrant and orientation around
    reg right_quadrant;
    reg [2:0] orientation_angle;
    
    // we need to pipeline all of this as it doesn't clear fast enough
    always @(posedge clock) begin
      
      // Phase 1: get in square and abs_deltas and deltas and quadrant
      in_square <= (x_value >= (center_x-WIDTH_D2) && x_value < (center_x+WIDTH_D2)) && 
                   (y_value >= (center_y-HEIGHT_D2) && y_value < (center_y+HEIGHT_D2)); 
      delta_x <= x_value - center_x;
      delta_y <= y_value - center_y;
      abs_delta_x <= (center_x > x_value) ? (center_x - x_value) : (x_value - center_x);
      abs_delta_y <= (center_y > y_value) ? (center_y - y_value) : (y_value - center_y);
      // orientation 0 = 0, 1 = 15 ... 24 = 90 so orientation / 6 == quadrant 
      orientation_quadrant <= (orientation * 170) >> 10;// 1/6 is about 170/1024
      orientation2 <= orientation;
      
      // Phase 2 calc all lines we care about, get angle and make sure we are in right quadrant
      on_00 <= (!(abs_delta_x == 0)) && (abs_delta_y == 0);
      on_90 <= (abs_delta_x == 0) && (!(abs_delta_y == 0));
      // for 45 we need delta x = delta y
      on_45 <= abs_delta_x == abs_delta_y;
      on_15 <= (test_on_15 - ROUNDING_FACTOR <= 0) && 
					(test_on_15 + ROUNDING_FACTOR >= 0);
      on_30 <= (test_on_30 - ROUNDING_FACTOR <= 0) && 
					(test_on_30 + ROUNDING_FACTOR >= 0);
      on_60 <= (test_on_60 - ROUNDING_FACTOR <= 0) && 
					(test_on_60 + ROUNDING_FACTOR >= 0);
      on_75 <= (test_on_75 - ROUNDING_FACTOR <= 0) && 
					(test_on_75 + ROUNDING_FACTOR_2 >= 0);
      // see if we are in the right quadrant of the square and get angle
      case (orientation_quadrant[1:0])         
         // base 0 so 1 is 2nd quadrant
         1: begin
            right_quadrant <= (delta_x <= 0) && (delta_y >=0) && in_square;
            orientation_angle <= D180 - orientation2; // 12 is 180 which is 0 (0), 7 is 105 which is 75 (5)
         end
         // base 0 so 2 is 3nd quadrant
         2: begin
            right_quadrant <= (delta_x <= 0) && (delta_y <=0) && in_square;
            orientation_angle <= orientation2 - D180; // 18 is 270 which is 90 (6), 13 is 195 which is 15 (1)
         end
         // base 0 so 3 is 4th quadrant
         3: begin
            right_quadrant <= (delta_x >= 0) && (delta_y <=0) && in_square;
            orientation_angle <= D360 - orientation2; // 12 is 180 which is 0 (0), 7 is 105 which is 75 (5)
         end
         // default to 1st quadrant
         default: begin
            right_quadrant <= (delta_x >= 0) && (delta_y >=0) && in_square;
            orientation_angle <= orientation2;
         end
      endcase
      
      // Phase 3 is output the result based on angle
      if (right_quadrant) begin
         case (orientation_angle)
            // 1 is 15 degrees
            1: begin
               pixel <= on_15 ? INDICATOR_COLOR : COLOR;
            end
            // 2 is 30 degrees
            2: begin
               pixel <= on_30 ? INDICATOR_COLOR : COLOR;
            end
            // 3 is 45 degrees
            3: begin
               pixel <= on_45 ? INDICATOR_COLOR : COLOR;
            end
            // 4 is 60 degrees
            4: begin
               pixel <= on_60 ? INDICATOR_COLOR : COLOR;
            end
            // 5 is 75 degrees
            5: begin
               pixel <= on_75 ? INDICATOR_COLOR : COLOR;
            end
            // 6 is 90 degrees
            6: begin
               pixel <= on_90 ? INDICATOR_COLOR : COLOR;
            end
            // default to 00 degrees
            default: begin
               pixel <= on_00 ? INDICATOR_COLOR : COLOR;
            end
         endcase
      end
      else begin
         pixel = BLANK_COLOR;
      end
    end
endmodule
