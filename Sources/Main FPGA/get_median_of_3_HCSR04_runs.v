`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        MIT 6.111 Final Project
// Engineer:       Brian Plancher
// 
// Module Name:    Get Median of 3 HCSR04 Runs
// Project Name:   FPGA Radar Guidance
//
// Note1: This leverages the run_HCSR04 module to compute the median of 3 runs for
//        increased accuracy of measurement
//
//////////////////////////////////////////////////////////////////////////////////
get_median_of_3_HCSR04_runs(
   input clock,
   input reset,
   input enable,
   input [3:0] curr_ultrasound, // which ultrasound to run (0 to 5)
   input [5:0] ultrasound_response, // can use up to 6 ultrasounds
   output reg [5:0] ultrasound_trigger, // can use up to 6 ultrasounds
	output reg [5:0] ultrasound_power, // can use up to 6 ultrasounds
   output reg [7:0] rover_distance,
   output reg done,
   output reg [3:0] state // exposed for debug
   );
   
   // get our HCSR04 module
   reg run_hcsr04;
   reg hcsro04_done;
   reg [4:0] hcsro04_state;
   reg [7:0] rover_distance_t;
   run_HCSR04 us_module (.clock(clock),.reset(reset),.enable(run_hcsr04),
                         .curr_ultrasound(curr_ultrasound),.ultrasound_response(ultrasound_response),
                         .ultrasound_trigger(ultrasound_trigger),.ultrasound_power(ultrasound_power),
                         .rover_distance(rover_distance_t),.done(hcsro04_done),.state(hcsro04_state));
   
   // get our helper module which computes the median of 3 values
   reg [7:0] distance_pass_0;
	reg [7:0] distance_pass_1;
	reg [7:0] distance_pass_2;
	reg [1:0] repeat_counter;
	wire [7:0] median_distance;
	median_3 m3 (.data1(distance_pass_0),.data2(distance_pass_1),
					  .data3(distance_pass_2),.median(median_distance));
                 
   // fsm parameters to run it 3 times
   parameter IDLE          = 4'h0;
   parameter RUN           = 4'h1;
   parameter PAUSE         = 4'h2; // induce a 1 cycle delay to allow the module to get out of the done state
   parameter WAIT          = 4'h3;
   parameter CALC_MEDIAN   = 4'h4; // induce a 1 cycle delay to allow for the median calculation to clear
   parameter REPORT        = 4'h5;
   
   reg [4:0] repeat_counter;
	parameter NUM_REPEATS = 3;
   
   // synchronize on the clock
	always @(posedge clock) begin
		// if reset set back to default
		if (reset) begin
         state <= IDLE;
			done <= 0;
			rover_location <= 12'h000;
         repeat_counter <= 0;
      end
      else begin
         // fsm to control the operation
         case (state)
            
            // run the HCSR04 module
            RUN: begin
               run_HCSR04 <= 1;
               state <= PAUSE;
            end
            
            // one cycle delay
            PAUSE: state <= WAIT;
            
            // wait for the HCSR04 to finish and the save the value
            WAIT: begin
               run_hcsr04 <= 0;
               if (hcsro04_done) begin
                  // save the value in the correct variable
                  case (repeat_counter)
                     1: distance_pass_1 <= rover_distance_t;
                     2: distance_pass_2 <= rover_distance_t;
                     default: distance_pass_0 <= rover_distance_t;
                  endcase
                  // if we are done then move to the next state
                  if (repeat_counter == NUM_REPEATS - 1) begin
                     state <= CALC_MEDIAN;
                     repeat_counter <= 0;
                  end
                  // else run again
                  else begin
                     state <= RUN;
                  end
               end
            end
            
            // one cycle delay
            CALC_MEDIAN: state <= REPORT;
            
            // report out the result
            REPORT: begin
               rover_distance <= median_distance;
               done <= 1;
            end
            
            // default to IDLE state
            default: begin
               // if we are enabled then start the process, else wait
               if (enable) begin
                  state <= RUN;
                  repeat_counter <= 0;
                  done <= 0;
               end
            end
            
         endcase
      end
endmodule