`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        MIT 6.111 Final Project
// Engineer:       Brian Plancher
// 
// Module Name:    rover_location_calculator
// Project Name:   FPGA Radar Guidance
//
// Note1: This leverages the get_median_of_3_HCSR04_runs to compute the distance to
//        each of the ultrasounds and calculates the angle based on which ultrasound
//        reports the closest angle assuming they are located at 15 + 30n degrees
//
//////////////////////////////////////////////////////////////////////////////////
rover_location_calculator(
   input clock,
   input reset,
   input enable,
   input [5:0] ultrasound_response, // uses 6 ultrasounds
   output reg [5:0] ultrasound_trigger, // uses 6 ultrasounds
	output reg [5:0] ultrasound_power, // uses 6 ultrasounds
   output reg [11:0] rover_location, // {4 bits for angle, 8 for distance}
   output reg done
   output reg [3:0] state, // exposed for debug
   output reg [3:0] curr_ultrasound // exposed for debug
   );
   
   // connect our module which will compute the distances for each ultrasound
   reg run_hcsr04;
   reg hcsro04_done;
   reg [4:0] hcsro04_state;
   reg [7:0] rover_distance_t;
   get_median_of_3_HCSR04_runs gm3hcsr04 (.clock(clock),.reset(reset),.enable(run_hcsr04),
                                          .curr_ultrasound(curr_ultrasound),.ultrasound_response(ultrasound_response),
                                          .ultrasound_trigger(ultrasound_trigger),.ultrasound_power(ultrasound_power),
                                          .rover_distance(rover_distance_t),.done(hcsro04_done),.state(hcsro04_state))
   
   // keep track of the values
   reg [7:0] best_distance;
	reg [3:0] best_angle;
   parameter TOTAL_ULTRASOUNDS = 6;
   
   // fsm parameters
   parameter RUN    = 4'h1;
   parameter PAUSE  = 4'h2; // induce a 1 cycle delay to allow the module to get out of the done state
   parameter WAIT   = 4'h3;
   parameter REPORT = 4'h4;
   
   // synchronize on the clock
	always @(posedge clock) begin
		// if reset set back to default
		if (reset) begin
         state <= IDLE;
			done <= 0;
			rover_location <= 12'h000;
         best_distance <= 0;
         best_angle <= 0;
         curr_ultrasound <= 0;
      end
      else begin
         // fsm to control the operation
         case (state)
         
            // run the helper module to calc the vale for the curr ultrasound
            RUN: begin
               run_HCSR04 <= 1;
               state <= PAUSE;
            end
            
            // one cycle delay
            PAUSE: state <= WAIT;
            
            // wait for the helper to finish and then potentially save the value
            WAIT: begin
               run_hcsr04 <= 0;
               if (hcsro04_done) begin
                  // if this is the new best value save it
                  if ((best_distance == 0) || (rover_distance_t < best_distance)) begin
							best_distance <= rover_distance_t;
							best_angle <= (curr_ultrasound << 1) + 1; // occurs at 1,3,5,7,9,11 times 15 degrees for 0,1,2,3,4,5 ultrasound numbers
						end
						// if done then go to report state
						if (curr_ultrasound == TOTAL_ULTRASOUNDS - 1) begin
							state <= REPORT;
							curr_ultrasound <= 0;
						end
						// else go to next ultrasound
						else begin
							curr_ultrasound <= curr_ultrasound + 1;
							state <= RUN;
						end
               end
            end
            
            // then report out the location
            REPORT: begin
					// if the best distance is NOTHING_FOUND (all 1s) set to 0 else report as is
					if (&best_distance) begin
						rover_location <= 12'h100; // since at origin doesn't matter what angle
					end
					else begin
						rover_location <= {best_angle,best_distance};
					end
					best_angle <= 0;
					best_distance <= 0;
               done <= 1;
					state <= IDLE;
				end
         
            // default to IDLE state
            default: begin
               // if we are enabled then start the process, else wait
               if (enable) begin
                  state <= RUN;
                  done <= 0;
                  rover_location <= 12'h000;
                  best_distance <= 0;
                  best_angle <= 0;
                  curr_ultrasound <= 0;
               end
            end
            
         endcase
      end
   end
endmodule