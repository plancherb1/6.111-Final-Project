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
    reg test_on_00;
    reg test_on_45;
    reg test_on_90;
    reg signed [31:0] test_on_15; // large bit size to multiply and shift
	 reg signed [31:0] test_on_30; // large bit size to multiply and shift
	 reg signed [31:0] test_on_60; // large bit size to multiply and shift
	 reg signed [31:0] test_on_75; // large bit size to multiply and shift
    reg [1:0] orientation_quadrant2;
    reg signed [11:0] delta_x2;
    reg signed [11:0] delta_y2;
    reg in_square2;
    reg orientation3;
    
    // Phase 3 helpers
    // we need to apply a ROUNDING factor for the bit shift rounding
	 parameter ROUNDING_FACTOR = 2;
	 parameter ROUNDING_FACTOR_2 = 2 * ROUNDING_FACTOR;
    reg on_00;
	 reg on_15;
	 reg on_30;
	 reg on_45;
	 reg on_60;
	 reg on_75;
	 reg on_90;
    // keep the quadrant and orientation and in square around
    reg right_quadrant;
    reg [2:0] orientation_angle;
	 reg in_square3;
    
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
      test_on_00 <= (!(abs_delta_x == 0)) && (abs_delta_y == 0); // change in x but none in y
      test_on_90 <= (abs_delta_x == 0) && (!(abs_delta_y == 0)); // change in y but none in x
      test_on_45 <= abs_delta_x == abs_delta_y; // for 45 we need delta x = delta y
      test_on_15 <= ((abs_delta_x*17) >>> 6) - abs_delta_y;  // tan 15 is about 17/64
      test_on_30 <= ((abs_delta_x*37) >>> 6) - abs_delta_y; // tan 75 is about 37/64
      test_on_60 <= ((abs_delta_x*111) >>> 6) - abs_delta_y; // tan 75 is about 111/64
      test_on_75 <= ((abs_delta_x*240) >>> 6) - abs_delta_y; // tan 75 is about 240/64
      // save values for next phase
      orientation_quadrant2 <= orientation_quadrant[1:0];
      in_square2 <= in_square;
      orientation3 <= orientation2;
      delta_x2 <= delta_x;
      delta_y2 <= delta_y;
      
      // phase 3 find if we are on the lines and in the right quadrant and get the angle
      on_00 <= test_on_00;
      on_90 <= test_on_90;
      on_45 <= test_on_45;
      on_15 <= (test_on_15 - ROUNDING_FACTOR <= 0) && 
					(test_on_15 + ROUNDING_FACTOR >= 0);
      on_30 <= (test_on_30 - ROUNDING_FACTOR <= 0) && 
					(test_on_30 + ROUNDING_FACTOR >= 0);
      on_60 <= (test_on_60 - ROUNDING_FACTOR <= 0) && 
					(test_on_60 + ROUNDING_FACTOR >= 0);
      on_75 <= (test_on_75 - ROUNDING_FACTOR_2 <= 0) && 
					(test_on_75 + ROUNDING_FACTOR_2 >= 0);
      case (orientation_quadrant2)         
         // base 0 so 1 is 2nd quadrant
         1: begin
            right_quadrant <= (delta_x2 <= 0) && (delta_y2 >=0) && in_square2;
            orientation_angle <= D180 - orientation3; // 12 is 180 which is 0 (0), 7 is 105 which is 75 (5)
         end
         // base 0 so 2 is 3nd quadrant
         2: begin
            right_quadrant <= (delta_x2 <= 0) && (delta_y2 <=0) && in_square2;
            orientation_angle <= orientation3 - D180; // 18 is 270 which is 90 (6), 13 is 195 which is 15 (1)
         end
         // base 0 so 3 is 4th quadrant
         3: begin
            right_quadrant <= (delta_x2 >= 0) && (delta_y2 <=0) && in_square2;
            orientation_angle <= D360 - orientation3; // 24 is 360 which is 0 (0), 23 is 345 which is 15 (1)
         end
         // default to 1st quadrant
         default: begin
            right_quadrant <= (delta_x2 >= 0) && (delta_y2 >=0) && in_square2;
            orientation_angle <= orientation3;
         end
      endcase
		in_square3 <= in_square2;
      
      // Phase 4 is output the result based on angle
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
			// if in square but not right quadrant then COLOR else BLANK
			if (in_square3) begin
				pixel <= COLOR;
			end
			else begin
				pixel <= BLANK_COLOR;
			end
      end
    end
endmodule
