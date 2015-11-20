`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        MIT 6.111 Final Project
// Engineer:       Brian Plancher
// 
// Module Name:    Orientation Math
// Project Name:   FPGA Phone Home
//
// Notes: this relies on only using 6 angles values of 15deg + 30n up to 165
//        if you want to use more or different angles you need to update the code
//
//////////////////////////////////////////////////////////////////////////////////

module orientation_math
    (input [11:0] r_theta_original, // r is [7:0] theta is [11:8]
     input [11:0] r_theta_final, // r is [7:0] theta is [11:8]
     input clock,
     input enable,
     input reset,
     output reg done,
     output reg [4:0] orientation);
	  
	// We need to pipieline this math as there is a lot of it
	// total timing is cartesian to polar (1 mul, 1 shift, 1 comp) + convert to delta (1 add and cast to 2s compliment so 2 add 1 shift) +
	// calc abs rtan (1 mul, 1 shift + 2 add 1 shift) + quad (2 comp) + comps (1 comp + 1 add) + final (1 add) = (2 mul, 4 shift, 6 add, 6 comp)
	// but the compiler can't do this all in parallel and fan out slows things down
	// use helper module to do the translation for us and then we need to solve
   // tan theta * delta_x = delta_y 	
	
	// FSM states
	reg [3:0] state;
	parameter IDLE 			 	= 4'h0;
	parameter PTC					= 4'h1;
	parameter DELTA_QUAD 		= 4'h2;
	parameter ABS_DELTA 			= 4'h3;
	parameter DX_TAN				= 4'h4;
	parameter ABS_DIFF			= 4'h5;
	parameter REPORT			 	= 4'hF;
   
	// PTC helpers
	wire signed [8:0] x_original;
	wire signed [8:0] y_original;
	wire signed [8:0] x_final;
	wire signed [8:0] y_final;
	wire signed [8:0] x_original_t;
	wire signed [8:0] y_original_t;
	wire signed [8:0] x_final_t;
	wire signed [8:0] y_final_t;
	polar_to_cartesian ptc_original (.r_theta(r_theta_original),.x_value(x_original_t),.y_value(y_original_t));
	polar_to_cartesian ptc_final (.r_theta(r_theta_final),.x_value(x_final_t),.y_value(y_final_t));
	
	// DELTA and ABS_DELTA_QUAD helpers
	wire signed [8:0] delta_y;
	wire signed [8:0] delta_x
	wire [7:0] abs_delta_x_t;
	wire [7:0] abs_delta_y_t;
	wire [7:0] abs_delta_x;
	wire [7:0] abs_delta_y;
	wire [1:0] quadrant;
   abs_val_8 abs1 (.v(delta_y),.absv(absdelta_y_t));
   abs_val_8 abs1 (.v(delta_x),.absv(absdelta_x_t));
	
	// DX_TAN helpers
   wire [7:0] abs_dx_tan15;
   wire [7:0] abs_dx_tan30;
   wire [7:0] abs_dx_tan45;
   wire [7:0] abs_dx_tan60;
   wire [7:0] abs_dx_tan75;
	wire [7:0] abs_dx_tan00_t;
   wire [7:0] abs_dx_tan15_t;
   wire [7:0] abs_dx_tan30_t;
   wire [7:0] abs_dx_tan45_t;
   wire [7:0] abs_dx_tan60_t;
   wire [7:0] abs_dx_tan75_t;
   //use a helper function for the abs(delta x * theta)
   calc_abs7rtan_00_75_15 abstan(.r(abs_delta_x),.abs7rtan_15(abs_dx_tan15),
											 .abs7rtan_30(abs_dx_tan30),.abs7rtan_45(abs_dx_tan45),
											 .absrtan_60(abs_dx_tan60),.abs7rtan_75(abs_dxtan75));
	
	// ABS_DIFF helpers
	wire [7:0] diff_15;
   wire [7:0] diff_30;
   wire [7:0] diff_45;
   wire [7:0] diff_60;
   wire [7:0] diff_75;
	wire [7:0] diff_15_t;
   wire [7:0] diff_30_t;
   wire [7:0] diff_45_t;
   wire [7:0] diff_60_t;
   wire [7:0] diff_75_t;
   abs_diff_7 abdiff15 (.y(abs_delta_y),.x(abs_dxtan_15),.absdiff(diff_15));
   abs_diff_7 abdiff30 (.y(abs_delta_y),.x(abs_dxtan_30),.absdiff(diff_30));
   abs_diff_7 abdiff45 (.y(abs_delta_y),.x(abs_dxtan_45),.absdiff(diff_45));
   abs_diff_7 abdiff60 (.y(abs_delta_y),.x(abs_dxtan_60),.absdiff(diff_60));
   abs_diff_7 abdiff75 (.y(abs_delta_y),.x(abs_dxtan_75),.absdiff(diff_75));

   
   always @(posedge clock) begin
      if (reset) begin
         state <= IDLE;
         done <= 0;
      end
      else begin
         case(state)
				
				// first return immediately if the angle is the same
				SHORTCUT_TEST: begin
					if (r_theta_original[11:8] == r_theta_final[11:8]) begin
						// if we traveled farther than headed on original angle
						// else 180 + angle which is orientaton 12 + angle
						orientation <= r_theta_original[11:8] + (r_theta_original[7:0] > r_theta_final[7:0]) ? 12 : 0;
						state <= REPORT;
					end
					else begin
						state <= PTC;
					end
				end
				
				// then we pipeline the Polar to Cartesian (PTC) calc
				PTC: begin
					x_original <= x_original_t;
					y_original <= y_original_t;
					x_final <= x_final_t;
					y_final <= y_final_t;
					state <= DELTA_QUAD;
				end
				
				// then lets find the deltas in x and y
				DELTAS: begin
					delta_x <= x_final - x_original;
					delta_y <= y_final - y_original;
					state <= ABS_DELTA_QUAD;
				end
				
				// then lets find the quadrant and the abs deltas in x and y
				ABS_DELTA_QUAD: begin
					abs_delta_x <= abs_delta_x_t;
					abs_delta_y <= abs_delta_y_t;
					// we can determine quadrant with the following:
					// if delta y positive and delta x positive then Q1, both negative Q3 --> tan  positive
					// if delta y positive and delta x negative then Q2, inverse Q4 --> tan negative
					quadrant <= ((delta_x > 0) && (delta_y > 0)) ? 1 : ((delta_y > 0) ? 2 : ((delta_x > 0) ? 4 : 3));			
					state <= DX_TAN;
				end
				
				// then we need to find dx * tan(theta)
				// note can also shortcut here for 90 or 0 degree movements
				DX_TAN: begin
					// test for 90 degrees or 0 degree movements and shortcut
					if (abs_delta_y <= ERROR_FACTOR) begin
						// 00 if delta y is 0 and delta x > 0
						// 180 if delta y is 0 and delta x < 0
						orientation <= 0 + (delta_x < 0 ? 12 : 0);
						state <= REPORT;
					end
					else if (abs_delta_x <= ERROR_FACTOR) begin
						// 90 if  delta x is 0 and delta y > 0
						// 270 if delta x is 0 and delta y < 0
						orientation <= 6 + (delta_y < 0 ? 12 : 0);
						state <= REPORT;
					end
					// else keep calcing
					else begin
						abs_dx_tan15 <= abs_dx_tan15_t;
						abs_dx_tan30 <= abs_dx_tan30_t;
						abs_dx_tan45 <= abs_dx_tan45_t;
						abs_dx_tan60 <= abs_dx_tan60_t;
						abs_dx_tan75 <= abs_dx_tan75_t;
						state <= ABS_DIFF;
					end
				end
				
				// we then need to find abs value of the differences between the calcs and delta y
				ABS_DIFF: begin
					diff_15 <= diff_15_t;
					diff_30 <= diff_30_t;
					diff_45 <= diff_45_t;
					diff_60 <= diff_60_t;
					diff_75 <= diff_75_t;
   			end
				
				// report out the answer is done and get ready for next math
				REPORT: begin
					done <= 1;
					state <= IDLE;
					// make sure to module 24 if needed aka reduce angle to [0 to 360) 
					if (orientation >= 24) begin
						orientation = orientation - 24;
					end
				end
				
				// default to IDLE
				default: begin
					if (enable) begin
						state <= SHORTCUT_TEST;
						done <= 0;
					end
				end
				
			endcase
		end
	end
   
	// then we can find the smallest one which is the best angle approximation
	wire comp15_30;
	wire comp30_45;
	wire comp15_45;
	wire [1:0] min15_30_45;
	assign comp15_30 = diff15 > diff30;
	assign comp30_45 = diff30 > diff45;
	assign comp15_45 = diff15 > diff45;
	assign min15_30_45 = comp15_30 && comp15_45
	wire comp45_60;
	wire comp60_75;
	
	assign comp45_60 = diff45 < diff60;
	assign comp60_75 = diff60 < diff75;
	wire [2:0] result_less90 = comp15_30 + comp30_45 + comp45_60 + comp60_75;
   wire [4:0] base_angle;
	
	wire on_15;
	
	assign base_angle = 	(diff15 < diff30) + (diff30 < diff45) + 
								(diff45 < diff60) + (diff60 < diff75);
   
   // then we can find orientation based on the base angle and quadrant
   always @(*) begin
      case(quadrant)
         2: orientation = (5'h0C - base_angle); // 75 = 180-75, 15 = 180-15
         3: orientation = (5'h0C + base_angle); // 15 = 180+15, 75 = 180+75
         4: orientation = (5'h18 - base_angle); // 75 = 360-75, 15 = 360-15
			default: orientation = base_angle; // 15 = 15, 75 = 75
      endcase
   end

endmodule
