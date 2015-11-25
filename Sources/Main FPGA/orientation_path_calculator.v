`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        MIT 6.111 Final Project
// Engineer:       Brian Plancher
// 
// Module Name:    Orientation and Path Calculator
// Project Name:   FPGA Phone Home
//
//////////////////////////////////////////////////////////////////////////////////

module orientation_path_calculator(
	input clock,
	input reset,
	input enable,
   input [11:0] rover_location, // r is [7:0] theta is [11:8]
   input [3:0] target_location,
   output reg move_ready,
   output reg orientation_done,
   output [4:0] orientation,
   output reg [11:0] move_command, // angle == [11:7], distance == [6:0]
   output reg [3:0] state, // exposed for debug
	// output analyzer_clock, // for debug only
	// output [15:0] analyzer_data // for debug only
	output reg missed_target,
	output reg reached_target
	);
	
   parameter ACTIVE = 1'b1;
   parameter IDLE = 1'b0;
   
   // fsm parameters
   parameter IDLE_STATE = 4'h1;
   parameter START_ORIENTATION = 4'h2;
   parameter WAIT_FOR_NEW_LOC = 4'h3;
   parameter CALC_ORIENTATION = 4'h4;
   parameter START_MOVE = 4'h5;
   
   // memory and paramenters for orientation and path
   reg [11:0] original_location;
   reg [11:0] updated_location;
   parameter ORIENTATION_MOVE = 12'h005;
   
   // helper to do the math for orientation
   reg orientation_helper_enable;
   wire orientation_helper_done;
   orientation_math om (.r_theta_original(original_location),.r_theta_final(updated_location),.orientation(orientation),
                        .enable(orientation_helper_enable),.done(orientation_helper_done),.reset(reset),.clock(clock));
	
	always @(posedge clock) begin
      // reset on reset
      if (reset) begin
         move_command <= 12'h000;
         move_ready <= IDLE;
         orientation_done <= IDLE;
         orientation_helper_enable <= IDLE;
         state <= IDLE_STATE;
         original_location <= 12'h000;
         updated_location <= 12'h000;
      end
      // else do the FSM
      else begin
         case(state)
         
            // start the orientation by sending a command to move forward a short amount
            START_ORIENTATION: begin
					original_location <= rover_location;
               move_command <= ORIENTATION_MOVE;
					move_ready <= ACTIVE;
               state <= WAIT_FOR_NEW_LOC;
            end
            
            // wait for the new location and then move to calculate step
            WAIT_FOR_NEW_LOC: begin
					move_ready <= IDLE;
               if(enable) begin
                  state <= CALC_ORIENTATION;
                  updated_location <= rover_location;
                  orientation_helper_enable <= ACTIVE;
               end
            end
            
            // do the vector math to calc orientation
            CALC_ORIENTATION: begin
               // wait for our helper function to finish
               if (orientation_helper_done) begin
                  orientation_done <= ACTIVE;
                  state <= START_MOVE;
                  orientation_helper_enable <= IDLE;
               end
            end
            
            // for now we do not do move and just go straight back to idle
            START_MOVE: begin
               state <= IDLE_STATE;
            end
            
            // default to IDLE state
            default: begin
               // if you see enable then move to the first orientation state else wiat
               if (enable) begin
                  state <= START_ORIENTATION;
                  move_ready <= IDLE;
                  orientation_done <= IDLE;
                  orientation_helper_enable <= IDLE;
               end
            end
         
         endcase
      end
	end
	
endmodule	 