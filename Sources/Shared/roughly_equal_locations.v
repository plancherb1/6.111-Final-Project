`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        MIT 6.111 Final Project
// Engineer:       Brian Plancher
// 
// Module Name:    Roughly Equal Locations
// Project Name:   FPGA Radar Guidance
//
//////////////////////////////////////////////////////////////////////////////////
module roughly_equal_locations(
   input clock,
   input reset,
   input enable,
   input [11:0] loc_1,
   input [11:0] loc_2,
   output reg done,
   output reg equal
   );
   
   // again we pipeline the math to be safe
   
   // fsm helpers
   reg [3:0] state;
   parameter IDLE    = 4'h0;
   parameter PTC     = 4'h1;
   parameter DELTAS  = 4'h2;
   parameter D_2     = 4'h3;
   parameter COMP    = 4'h4;
   
   // PTC helpers
   reg signed [8:0] loc_1_x;
	reg signed [8:0] loc_1_y;
	reg signed [8:0] loc_2_x;
	reg signed [8:0] loc_2_y;
	wire signed [8:0] loc_1_x_t;
	wire signed [8:0] loc_1_y_t;
	wire signed [8:0] loc_2_x_t;
	wire signed [8:0] loc_2_y_t;
	polar_to_cartesian ptc_original (.r_theta(loc_1),.x_value(loc_1_x_t),.y_value(loc_1_y_t));
	polar_to_cartesian ptc_final (.r_theta(loc_2),.x_value(loc_2_x_t),.y_value(loc_2_y_t));   
   
   // DELTAS and D_2 helpers
   reg [11:0] dx;
   reg [11:0] dy;
   reg [23:0] dx_2;
   reg [23:0] dy_2;
   
   // COMP helpers
   parameter MAX_DISTANCE_FOR_EQUAL = 6;
   parameter MAX_DISTANCE_FOR_EQUAL_2 = MAX_DISTANCE_FOR_EQUAL * MAX_DISTANCE_FOR_EQUAL;
   
   always @(posedge clock) begin
      if (reset) begin
         equal <= 0;
         done <= 0;
      end
      else begin
         case (state)
            
            // first convert polar to cartesian
            PTC: begin
               loc_1_x <= loc_1_x_t;
               loc_1_y <= loc_1_y_t;
               loc_2_x <= loc_2_x_t;
               loc_2_y <= loc_2_y_t;
					state <= DELTAS;
            end
            
            // then get deltas
            DELTAS: begin
               dx <= (loc_1_x > loc_2_x) ? (loc_1_x - loc_2_x) : (loc_2_x - loc_1_x);
               dy <= (loc_1_y > loc_2_y) ? (loc_1_y - loc_2_y) : (loc_2_y - loc_1_y);
					state <= D_2;
            end
            
            // then square for distance
            D_2: begin
               dx_2 <= dx*dx;
               dy_2 <= dy*dy;
					state <= COMP;
            end
            
            // then compare sum of distance squared to our max distance
            COMP: begin
               equal <= MAX_DISTANCE_FOR_EQUAL_2 >= dx_2 + dy_2;
               done <= 1;
               state <= IDLE;
            end
            
            default: begin
               equal <= 0;
               done <= 0;
               if (enable) begin
                  state <= PTC;
               end
            end
            
         endcase
      end
   end
   

endmodule