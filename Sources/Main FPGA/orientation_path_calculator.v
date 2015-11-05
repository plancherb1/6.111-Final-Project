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
   input [11:0] rover_location,
   input [3:0] target_location,
   output reg move_done,
   output reg orientation_done,
   output reg [11:0] move_command,
   output reg [4:0] state // exposed for debug
	// output analyzer_clock, // for debug only
	// output [15:0] analyzer_data // for debug only
	);
	
   // fsm parameters
   parameter IDLE = 4'h1;
   parameter START_ORIENTATION = 4'h2;
   parameter WAIT_FOR_NEW_LOC = 4'h3;
   parameter CALC_ORIENTATION = 4'h4;
   parameter START_MOVE = 4'h5;
   
   // memory and paramenters for orientation and path
   reg [11:0] original_location;
   reg [11:0] updated_location;
   parameter ORIENTATION_MOVE = 12'h005;
   reg [11:0]
	
	always @(posedge clock) begin
      // reset on reset
      if (reset) begin
         move_command <= 12'h000;
         move_done <= 0;
         orientation_done <= 0;
      end
      // else do the FSM
      else begin
         case(state)
         
            // start the orientation by sending a command to move forward a short amount
            START_ORIENTATION: begin
               move_command <= ORIENTATION_MOVE;
               state <= WAIT_FOR_NEW_LOC;
            end
            
            // wait for the new location and then move to calculate step
            WAIT_FOR_NEW_LOC: begin
               if(enable) begin
                  state <= CALC_ORIENTATION;
                  updated_location <= rover_location;
               end
            end
            
            // do the vector math to calc orientation
            CALC_ORIENTATION: begin
               
               
               
               // TBD -- use helper module with continuous assignment and then just pull in the value here
               
               
               
               // orientation <= ?
               orientation_done <= 1;
               state <= START_MOVE;
            end
            
            // for now we do not do move and just go straight back to idle
            START_MOVE: begin
               state <= IDLE;
            end
            
            // default to IDLE state
            default: begin
               // if you see enable then move to the first orientation state else wiat
               if (enable) begin
                  state <= START_ORIENTATION;
                  original_location <= rover_location;
                  move_done <= 0;
                  orientation_done <= 0;
               end
            end
         
         endcase
      end
	end
	
endmodule	 