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
   output analyzer_clock, // for debug only
   output [15:0] analyzer_data, // for debug only
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
	
	// distance calcing parameters and regs
	reg [4:0] curr_ultrasound;
	parameter TOTAL_ULTRASOUNDS = 1;
	reg [8:0] trigger_count;
	parameter TRIGGER_TARGET = 275; // about 10 us with a little extra per spec
	reg [19:0] distance_count; // 20 bit to allow for multiplication and shift later of max size DISTANCE_MAX*7
	parameter DISTANCE_MAX = 1048576; // spec says distance in 150us to 25ms with 38ms as
												  // nothing found which is about 2^20 clock cycles
   parameter POWER_CYCLE_TIME = 27000000; // one milisecond just to make sure it flushes it self
   reg [24:0] power_cycle_timer; // as sized for one milisecond in counting
	reg [7:0] best_distance;
	reg [3:0] best_angle;
	
	// debug only
	assign analyzer3_clock = clock;
	assign analyzer_data = {state, //3
						  ultrasound_signals[0],
						  ultrasound_commands[0],
						  calculate,
						  distance_count[10],
						  done,
						  rover_location[7:0]};
	
	// synchronize on the clock
	always @(posedge clock) begin
		// if reset set back to default
		if (reset) begin
			done <= 0;
			rover_location <= 12'h000;
			ultrasound_commands <= 12'h000;
			state <= IDLE;
			trigger_count <= 0;
			curr_ultrasound <= 0;
			best_distance <= 0;
         ultrasound_power <= 10'h3FF;
         power_cycle_timer <= 0;
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
						state <= REPEAT;
						// per spec distance is microseconds divide by 148 which is 
						// about 7/1024 (~1% error) -- but note we have 27 clock
						// pulses per microsecond so it is actually divide by 1/3996
						// which we can approximate with 2.5% error to 1/4096! :)
						distance_count <= (distance_count) >> 12;
					end
					else if (distance_count == DISTANCE_MAX -1) begin
						state <= POWER_CYCLE;
						distance_count <= 10'h7FFFF;
                  // cut power to the ultrasound and enter power cycle mode
                  ultrasound_power[curr_ultrasound] <= 0;
                  power_cycle_timer <= 1;
					end
					else begin
						distance_count <= distance_count + 1;
					end
				end
				
				// The HC-SR04's I have get stuck and need to be power cycled if they
				// calc a distance of 0
				POWER_CYLCE: begin
					// count until we havae enough time and then turn it back on
					if (power_cycle_timer == POWER_CYCLE_TIME) begin
                  state <= REPEAT;
                  power_cycle_timer <= 0;
                  ultrasound_power[curr_ultrasound] <= 1;
               end
               else begin
                  power_cycle_timer <= power_cycle_timer + 1;
               end
				end
				
				// cycle to next module and/or finalize value
				REPEAT: begin
					// in all cases we need to see if our result is the new best result
					// and then zero out the distance for this round
					if ((distance_count > 0) && 
						 ((best_distance == 0) ||
						  (distance_count < best_distance))) begin
						best_distance <= distance_count[7:0];
						best_angle <= curr_ultrasound;
					end
					distance_count <= 0;
					// if done then go to report state
					if (curr_ultrasound == TOTAL_ULTRASOUNDS - 1) begin
						state <= REPORT;
						curr_ultrasound <= 0;
					end
					// else go to next ultrasound
					else begin
						curr_ultrasound <= curr_ultrasound + 1;
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
					done <= 0;
					// if we see a run_program then begin the calculation else stay in IDLE
					if (calculate) begin
						state <= TRIGGER;
						ultrasound_commands[curr_ultrasound] <= 1;
						trigger_count <= 1;
					end
				end
			
			endcase
		end
	end
	
endmodule	 