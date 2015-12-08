`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        MIT 6.111 Final Project
// Engineer:       Brian Plancher
// 
// Module Name:    Path Math
// Project Name:   FPGA Radar Guidance
//
// Notes: this relies on only using 6 angles values of 15deg + 30n up to 165
//        if you want to use more or different angles you need to update the code
//
//////////////////////////////////////////////////////////////////////////////////

module path_math
    (input [11:0] location, // r is [7:0] theta is [11:8]
     input [11:0] target, // r is [7:0] theta is [11:8]
     input [4:0] current_orientation, // angle = orientation * 15deg
     input clock,
     input enable,
     input reset,
     output reg done,
	  output reg [4:0] needed_orientation, // angle = orientation * 15deg
     output reg [11:0] move_command); // distance is [6:0] and angle is [11:7]
	  
	// learning from the VGA and orientation I will pipeline this from the start
   // our goal is to solve distance of move = delta_y / sin(orientation)
   // we also know that angle of move = orientation of move - theta of location
	
	// Helper Angles
	parameter DEG360 = 5'h18;
	parameter DEG180 = 5'h0C;
	
	// FSM states
	reg [3:0] state;
	parameter IDLE 			 			= 4'h0;
	parameter NEEDED_ORIENTATION_1	= 4'h1;
	parameter ONE_CYCLE_DELAY_1		= 4'h2;
	parameter NEEDED_ORIENTATION_2	= 4'h3;
	parameter ONE_CYCLE_DELAY_2		= 4'h4;
	parameter PTC_AND_ANGLE 			= 4'h5;
	parameter DELTAS						= 4'h6;
	parameter ABS_DELTA_QUAD 			= 4'h7;
   parameter ORIENT_BASE_ANGLE		= 4'h8;
	parameter ABS_DY_DIV_SIN			= 4'h9;
	parameter REPORT			 			= 4'hF;
	
	reg orientation_helper_enable;
   wire [4:0] orientation_t;
	wire orientation_done;
   orientation_math om (.r_theta_original(location),.r_theta_final(target),.orientation(orientation_t),
                        .enable(orientation_helper_enable),.done(orientation_done),.reset(reset),.clock(clock));
	
	// PTC_AND_ANGLE helpers
   reg [4:0] angle;
	reg signed [8:0] x_location;
	reg signed [8:0] y_location;
	reg signed [8:0] x_target;
	reg signed [8:0] y_target;
	wire signed [8:0] x_location_t;
	wire signed [8:0] y_location_t;
	wire signed [8:0] x_target_t;
	wire signed [8:0] y_target_t;
	polar_to_cartesian ptc_original (.r_theta(location),.x_value(x_location_t),.y_value(y_location_t));
	polar_to_cartesian ptc_final (.r_theta(target),.x_value(x_target_t),.y_value(y_target_t));
	
	// DELTAS helpers 
	reg signed [8:0] delta_y;
	reg signed [8:0] delta_x;
	
	// ABS_DELTA_QUAD helpers
	wire [7:0] abs_delta_x_t;
	wire [7:0] abs_delta_y_t;
	reg [7:0] abs_delta_x;
	reg [7:0] abs_delta_y;
	reg [1:0] quadrant;
	wire [1:0] quadrant_t;
	abs_val_8 absx (.v(delta_x),.absv(abs_delta_x_t));
	abs_val_8 absy (.v(delta_y),.absv(abs_delta_y_t));
	quadrant q1 (.x(delta_x),.y(delta_y),.q(quadrant_t));
	
   // ORIENT_BASE_ANGLE helpers
	reg [2:0] base_angle;
   
	// ABS_DY_DIV_SIN helpers
	reg [6:0] distance;
   wire [7:0] distance_t;
	//use a helper function for the math
	calc_r_y_theta calcr (.y(abs_delta_y),.x(abs_delta_x),.theta(base_angle),.r(distance_t));
	
	always @(posedge clock) begin
      if (reset) begin
         state <= IDLE;
         done <= 0;
			angle <= 0;
         x_location <= 0;
         y_location <= 0;
         x_target <= 0;
         y_target <= 0;
         delta_x <= 0;
         delta_y <= 0;
         abs_delta_x <= 0;
         abs_delta_y <= 0;
         quadrant <= 0;
         base_angle <= 0;
         distance <= 0;
         move_command <= 0;
			orientation_helper_enable <= 0;
			needed_orientation <= 0;
      end
      else begin
         case(state)
				
				// we start by determining the orientation we need to have to get there
				NEEDED_ORIENTATION_1: begin
					orientation_helper_enable <= 1;
					state <= ONE_CYCLE_DELAY_1;
				end
				
				ONE_CYCLE_DELAY_1: state <= NEEDED_ORIENTATION_2;
				
				NEEDED_ORIENTATION_2: begin
					orientation_helper_enable <= 0;
					// if the helper is done save the value
					if (orientation_done) begin
						needed_orientation <= orientation_t;
						state <= ONE_CYCLE_DELAY_2;
					end
				end
				
				ONE_CYCLE_DELAY_2: state <= PTC_AND_ANGLE;
				
				// then we do the Polar to Cartesian (PTC) calc
				PTC_AND_ANGLE: begin
               angle <= needed_orientation - current_orientation + ((current_orientation > needed_orientation) ? DEG360 : 0);
					x_location <= x_location_t;
					y_location <= y_location_t;
					x_target <= x_target_t;
					y_target <= y_target_t;
					state <= DELTAS;
				end
				
				// then lets find the deltas in x and y
				DELTAS: begin
					delta_x <= x_target - x_location;
					delta_y <= y_target - y_location;
					state <= ABS_DELTA_QUAD;
				end
				
				// then lets find the quadrant and the abs deltas in x and y
				ABS_DELTA_QUAD: begin
					abs_delta_x <= abs_delta_x_t;
					abs_delta_y <= abs_delta_y_t;
					// we can determine quadrant with the following:
					// if delta y positive and delta x positive then Q1, both negative Q3 --> tan  positive
					// if delta y positive and delta x negative then Q2, inverse Q4 --> tan negative
					quadrant <= quadrant_t;
					state <= ORIENT_BASE_ANGLE;
				end
				
				// find the base angle
				ORIENT_BASE_ANGLE: begin
               case (quadrant)
                  1: base_angle <= (DEG180 - needed_orientation);
                  2: base_angle <= (needed_orientation - DEG180);
                  3: base_angle <= (DEG360 - needed_orientation);
                  default: base_angle <= needed_orientation[3:0];
               endcase
               state <= ABS_DY_DIV_SIN;
				end
            
            // then we need to find ABS(DeltaY/sin(base_angle))
				ABS_DY_DIV_SIN: begin
               // we know max distance for our purposes is 9 bits shifted down 2 is 7
               // since max move is (-128,0) to (128,255)
					distance <= distance_t[6:0];
					state <= REPORT;
				end
				
				// report out the answer is done and get ready for next math
				REPORT: begin
					done <= 1;
					state <= IDLE;
					move_command <= {angle,distance};
				end
				
				// default to IDLE
				default: begin
					if (enable) begin
						state <= NEEDED_ORIENTATION_1;
						done <= 0;
						orientation_helper_enable <= 0;
						needed_orientation <= 0;
					end
				end
				
			endcase
		end
	end

endmodule
