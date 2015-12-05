`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        MIT 6.111 Final Project
// Engineer:       Brian Plancher
// 
// Module Name:    Run HCSR04
// Project Name:   FPGA Radar Guidance
//
// Note1: HCSR04 requires about 10 us trigger pulse and then will respond with a 
//        TTL high signal which is 148 microsecond per inch for 150us to 25ms with 
//        38ms representing nothing found. The unit has a range of about 13 feet.
//        From extensive testing the units I received had a defect and need to be
//        power cycled if they do not find anything for a hard reset. I have found
//        that a 1 second power cycle usually rests the unit.
//
// Note2: In this implimentation I report a max value for nothing found since I am
//        going to be using the closest match. You may need to adjust this if used
//        for other projects.
//
//////////////////////////////////////////////////////////////////////////////////

module run_HCSR04(
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
   
   // counters and count goals we need
   parameter TRIGGER_TARGET = 275; // a little of 10us at 27mhz
   parameter DISTANCE_MAX = 1048576; // about 38ms at 27mhz
   parameter POWER_CYCLE_TIME = 27000000; // one second at 27mhz
   reg [8:0] trigger_count;
	reg [19:0] distance_count;
   reg [25:0] power_cycle_timer;
   
   // parameter for the physical device
	parameter DISTANCE_OFFSET = 5;
	parameter NOTHING_FOUND = 20'hF_FFFF;
	
	// fsm state parameters
	parameter IDLE 			= 4'h0; // waiting to do something
	parameter TRIGGER 		= 4'h1; // trigger the module
	parameter WAIT_FOR1 		= 4'h2; // waiting for distance value
	parameter WAIT_FOR0 		= 4'h3; // getting in distance value 0 marks end
	parameter POWER_CYCLE 	= 4'h4; // make sure to power cycle in case stuck
   parameter REPORT        = 4'h5; // send out the value
   
   // synchronize on the clock
	always @(posedge clock) begin
		// if reset set back to default
		if (reset) begin
         state <= IDLE;
			done <= 0;
			rover_location <= 12'h000;
			ultrasound_commands <= 10'h000;
         ultrasound_power <= 10'h3FF;
         trigger_count <= 0;
         distance_count <= 0;
         power_cycle_timer <= 0;
      end
      else begin
         // fsm to control the operation
         case (state)
         
            // run the trigger command for the time specified
            TRIGGER: begin
               // if we have reached our time goal wait for a response
               if (trigger_count == TRIGGER_TARGET - 1) begin
                  state <= WAIT_FOR1;
                  trigger_count <= 0;
                  ultrasound_trigger[curr_ultrasound] <= 0;
               end
               // else keep triggering
               else begin
                  trigger_count <= trigger_count + 1;
               end
            end
            
            // wait until we see the beginning of the response to start counting
            WAIT_FOR1: begin
               if(ultrasound_response[curr_ultrasound]) begin
                  state <= WAIT_FOR0;
                  distance_count <= 1;
               end
            end
            
            // count until we see a 0 and then either report the result or powercycle if needed
            WAIT_FOR0: begin
               // if we see a zero analyze for report
               if (~ultrasound_response[curr_ultrasound]) begin
                  // 148 microsecond per inch means to get inches we divide the count by
                  // 148*27 = 3996 ~ 4096 so just shift it down 12 times
                  distance_count <= (distance_count >> 12);
                  state <= REPORT;
               end
               // else if we hit max time go to power cycle and report nothing found
               else if (distance_count == DISTANCE_MAX - 1) begin
                  distance_count <= NOTHING_FOUND;
                  state <= POWER_CYCLE;
                  power_cycle_timer <= 1;
                  ultrasound_power[curr_ultrasound] <= 0;
               end
               // else keep counting
               else begin
                  distance_count <= distance_count + 1;
               end
            end
            
            // power cycle for the appropriate time
            POWER_CYCLE: begin
               // if we hit our desired time move to report
               if (power_cycle_timer == POWER_CYCLE_TIME - 1) begin
                  power_cycle_timer <= 0;
                  state <= REPORT;
               end
               // else keep counting
               else begin
                  power_cycle_timer <= power_cycle_timer + 1;
               end
            end
            
            // report out the distance
            REPORT: begin
               done <= 1;
               rover_distance <= distance_count + DISTANCE_OFFSET;
               distance_count <= 0;
               state <= IDLE;
            end
            
            // default to IDLE state
            default: begin
               // if we are enabled then start the process, else wait
               if (enable) begin
                  state <= TRIGGER;
						ultrasound_trigger[curr_ultrasound] <= 1;
						done <= 0;
                  trigger_count <= 1;
                  distance_count <= 0;
                  power_cycle_timer <= 0;
               end
            end
            
         endcase
      end
endmodule