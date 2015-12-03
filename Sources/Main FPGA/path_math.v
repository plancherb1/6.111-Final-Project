`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        MIT 6.111 Final Project
// Engineer:       Brian Plancher
// 
// Module Name:    Path Math
// Project Name:   FPGA Phone Home
//
// Notes: this relies on only using 6 angles values of 15deg + 30n up to 165
//        if you want to use more or different angles you need to update the code
//
//////////////////////////////////////////////////////////////////////////////////

module path_math
    (input [11:0] location, // r is [7:0] theta is [11:8]
     input [11:0] target, // r is [7:0] theta is [11:8]
     input [4:0] orientation, // angle = orientation * 15deg
     input clock,
     input enable,
     input reset,
     output reg done,
     output reg [11:0] move_command);
	  
	// learning from the VGA and orientation I will pipeline this from the start
   // our goal is to solve distance of move = delta_y / sin(orientation)
   // we also know that angle of move = 
   
   
   ////// NEED TO CALC THE ANGLE THEN THIS WORKS!!!! :)
   
	
	// Helper Angles
	parameter DEG360 = 5'h18;
	parameter DEG180 = 5'h0C;
	
	// FSM states
	reg [3:0] state;
	parameter IDLE 			 	= 4'h0;
	parameter PTC					= 4'h1;
	parameter DELTAS				= 4'h2;
	parameter ABS_DELTA_QUAD 	= 4'h3;
   parameter ORIENT_BASE_ANGLE= 4'h4;
	parameter ABS_DY_DIV_SIN	= 4'h5;
	parameter REPORT			 	= 4'hF;
	
	// PTC helpers
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
	reg [7:0] distance;
   wire [7:0] distance_t;
	//use a helper function for the math
	calc_r_y_theta calcr (.y(abs_delta_y),.x(abs_delta_x),.theta(base_angle),.r(distance_t));
	
	always @(posedge clock) begin
      if (reset) begin
         state <= IDLE;
         done <= 0;
			orientation <= 5'h00;
      end
      else begin
         case(state)
				
				// we begin the pipeline with the Polar to Cartesian (PTC) calc
				PTC: begin
					x_location <= x_location_t;
					y_location <= y_location_t;
					x_target <= x_target_t;
					y_target <= y_target_t;
					state <= DELTAS;
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
					quadrant <= quadrant_t;
					state <= ORIENT_BASE_ANGLE;
				end
				
				// find the base angle
				ORIENT_BASE_ANGLE: begin
               case (quadrant)
                  1: base_angle <= (DEG180 - orientation);
                  2: base_angle <= (orientation - DEG180)
                  3: base_angle <= (DEG360 - orientation)
                  default: base_angle <= orientation[3:0]
               endcase
               state <= ABS_DY_DIV_SIN;
				end
            
            // then we need to find ABS(DeltaY/sin(base_angle))
				ABS_DY_DIV_SIN: begin
					distance <= distance_t
					state <= REPORT;
				end
				
				// report out the answer is done and get ready for next math
				REPORT: begin
					done <= 1;
					state <= IDLE;
					move_command = {angle,distance};
				end
				
				// default to IDLE
				default: begin
					if (enable) begin
						state <= PTC;
						done <= 0;
					end
				end
				
			endcase
		end
	end

endmodule