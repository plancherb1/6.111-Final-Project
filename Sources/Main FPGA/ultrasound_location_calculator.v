`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        MIT 6.111 Final Project
// Engineer:       Brian Plancher
// 
// Module Name:    Ultrasound Location Calculator
// Project Name:   FPGA Phone Home
//
//////////////////////////////////////////////////////////////////////////////////

module ultrasound_location_calculator(
   input clock,
   input reset,
   input calculate,
   input [9:0] ultrasound_signals, // can use up to 10 ultrasounds
   output reg done,
   output reg [11:0] rover_location, // {4 bits for angle, 8 for distance}
   output reg [9:0] ultrasound_commands, // can use up to 10 ultrasounds
	output reg [9:0] ultrasound_power, // can use up to 10 ultrasounds
   //output analyzer_clock, // for debug only
   //output [15:0] analyzer_data, // for debug only
   output reg [2:0] state // made output for debug
   );
	
	// state parameters and reg
	parameter IDLE = 3'h0; // waiting to do something
	parameter TRIGGER = 3'h1; // trigger the module
	parameter WAIT_FOR1 = 3'h2; // waiting for distance value
	parameter WAIT_FOR0 = 3'h3; // getting in distance value 0 marks end
	parameter REPEAT = 3'h4; // cylce to next module if needed
	parameter REPORT = 3'h5; // when done send out value
	parameter POWER_CYCLE = 3'h6; // make sure to power cycle in case stuck
	parameter ERROR_CORRECT_REPEAT = 3'h7; // run each ultrasound a couple times to be safe

	// distance calcing parameters and regs
	reg [4:0] curr_ultrasound;
	parameter TOTAL_ULTRASOUNDS = 1;
	reg [8:0] trigger_count;
	parameter TRIGGER_TARGET = 275; // about 10 us with a little extra per spec
	reg [19:0] distance_count; // 20 bit to allow for multiplication and shift later of max size DISTANCE_MAX*7
	parameter DISTANCE_MAX = 1048576; // spec says distance in 150us to 25ms with 38ms as
												  // nothing found which is about 2^20 clock cycles
   parameter POWER_CYCLE_TIME = 27000000; // one second just to make sure it flushes it self
   reg [24:0] power_cycle_timer; // as sized for one milisecond in counting
	reg [7:0] best_distance;
	reg [3:0] best_angle;
	
	// parameters for repeat and median that we calc from it
	// note: you will need to adjust variables and median if you want more passes
	//       and the case statement down below
	parameter NUM_REPEATS = 3;
	reg [19:0] distance_pass_1;
	reg [19:0] distance_pass_2;
	reg [19:0] distance_pass_3;
	reg [1:0] repeat_counter;
	wire [19:0] median_distance;
	median_3 m3 (.data1(distance_pass_1),.data2(distance_pass_2),
					  .data3(distance_pass_3),.median(median_distance));	
	
	// debug only
	//assign analyzer3_clock = clock;
	//assign analyzer_data = {state, //3
	//								 ultrasound_power, //10
	//								 curr_ultrasound[1:0]};
	
	// synchronize on the clock
	always @(posedge clock) begin
		// if reset set back to default
		if (reset) begin
         state <= IDLE;
			done <= 0;
			rover_location <= 12'h000;
			ultrasound_commands <= 12'h000;
         ultrasound_power <= 10'h3FF;
			trigger_count <= 0;
			curr_ultrasound <= 0;
			best_distance <= 0;
         best_angle <= 0;
         power_cycle_timer <= 0;
         repeat_counter <= 0;
         distance_count <= 0;
         distance_pass_1 <= 0;
         distance_pass_2 <= 0;
         distance_pass_3 <= 0;
		end
		// else execute the FSM
		else begin
			case (state)
				
				// to calculate distance we send send out a trigger to the ultrasound module
				// and then wait for the response
				TRIGGER: begin
					if (trigger_count == TRIGGER_TARGET - 1) begin
						trigger_count <= 0;
						state <= WAIT_FOR1;
						ultrasound_commands[curr_ultrasound] <= 0;
					end
					else begin
						trigger_count <= trigger_count + 1;
					end
				end
				
				// wait until see the first 1 meaning the distance value is coming
				WAIT_FOR1: begin
					if(ultrasound_signals[curr_ultrasound] == 1) begin
						state <= WAIT_FOR0;
						distance_count <= 1;
					end
				end
				
				// count until we see a 0 or hit max time indicating the length
				// start the division process now and will be done in next state
				WAIT_FOR0: begin
					if (ultrasound_signals[curr_ultrasound] == 0)begin
						// per spec distance is microseconds divide by 148 which is 
						// about 7/1024 (~1% error) -- but note we have 27 clock
						// pulses per microsecond so it is actually divide by 1/3996
						// which we can approximate with 2.5% error to 1/4096! :)
						distance_count <= (distance_count) >> 12;
						state <= ERROR_CORRECT_REPEAT;
					end
					else if (distance_count == DISTANCE_MAX -1) begin
						distance_count <= 10'h7FF;
                  // cut power to the ultrasound and enter power cycle mode
                  ultrasound_power[curr_ultrasound] <= 0;
                  power_cycle_timer <= 1;
						state <= POWER_CYCLE;
					end
					else begin
						distance_count <= distance_count + 1;
					end
				end
				
				// The HC-SR04's I have get stuck and need to be power cycled if they
				// calc a distance of 0
				POWER_CYCLE: begin
					// count until we havae enough time and then turn it back on
					if (power_cycle_timer == POWER_CYCLE_TIME - 1) begin
                  state <= ERROR_CORRECT_REPEAT;
                  power_cycle_timer <= 0;
                  ultrasound_power[curr_ultrasound] <= 1;
               end
               else begin
                  power_cycle_timer <= power_cycle_timer + 1;
               end
				end
				
				// cycle within the ultrasound module to avoid error
				ERROR_CORRECT_REPEAT: begin
					// we are going to do 3 passes for each reading and take the median value to
					// adjust for any noise in the readings just to be safe
					// if we are done then test for next ultrasound (but delay 1 for median to clear)
					if (repeat_counter == NUM_REPEATS - 1) begin
						distance_pass_3 <= distance_count;
                  distance_count <= 0;
                  repeat_counter <= repeat_counter + 1;
	   				state <= ERROR_CORRECT_REPEAT; // for one cycle delay
					end
					// else we are in delay or save the value and re-calculate
					else begin
                  // delay done go to repeat
                  if (repeat_counter == NUM_REPEATS) begin
                     state <= REPEAT;
                     repeat_counter <= 0;
                  end
                  else begin
                     // save the distance in the right variable 
                     // (2D arrays keep breaking so using a case statement instead)
                     // if you increase pass size update this (note the last state
                     // appears above on the other if statement)
                     case(repeat_counter)
                        1: distance_pass_2 <= distance_count;
                        default: distance_pass_1 <= distance_count;
                     endcase
                     // then get ready for next pass
                     repeat_counter <= repeat_counter + 1;
                     state <= TRIGGER;
                     ultrasound_commands[curr_ultrasound] <= 1;
                     trigger_count <= 1;
                     distance_count <= 0;
                  end
					end
				end
				
				// cycle to next module and/or finalize value
				REPEAT: begin
               // in all cases we need to see if our result is the new best result
               // and then zero out the distance for this round
               if ((median_distance > 0) && 
                   ((best_distance == 0) ||
                    (median_distance < best_distance))) begin
                  best_distance <= median_distance[7:0];
                  best_angle <= curr_ultrasound + curr_ultrasound + 1; // occurs at 1,3,5,7,9,11 times 15 degrees for 0,1,2,3,4,5 ultrasound numbers
               end
               // if done then go to report state
               if (curr_ultrasound == TOTAL_ULTRASOUNDS - 1) begin
                  state <= REPORT;
                  curr_ultrasound <= 0;
               end
               // else go to next ultrasound
               else begin
                  curr_ultrasound <= curr_ultrasound + 1;
                  state <= TRIGGER;
                  ultrasound_commands[curr_ultrasound+1] <= 1;
                  trigger_count <= 1;
               end
				end
				
				// report out the result
				REPORT: begin
					rover_location <= {best_angle,best_distance};
					done <= 1;
					best_angle <= 0;
					best_distance <= 0;
					state <= IDLE;
				end
				
				// default to IDLE state
				default: begin
					// if we see a run_program then begin the calculation else stay in IDLE
					if (calculate) begin
						state <= TRIGGER;
						ultrasound_commands[curr_ultrasound] <= 1;
						done <= 0;
                  trigger_count <= 1;
                  curr_ultrasound <= 0;
                  best_distance <= 0;
                  best_angle <= 0;
                  power_cycle_timer <= 0;
                  repeat_counter <= 0;
                  distance_count <= 0;
                  distance_pass_1 <= 0;
                  distance_pass_2 <= 0;
                  distance_pass_3 <= 0;
					end
				end
			
			endcase
		end
	end
	
endmodule	