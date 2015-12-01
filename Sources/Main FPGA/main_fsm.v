`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        MIT 6.111 Final Project
// Engineer:       Brian Plancher
// 
// Module Name:    main fsm
// Project Name:   FPGA Phone Home
//
// Note: controls all of the modules and makes sure they only fire when needed
//
// Note2: Updated 12/1 to include orientation and path calculation logic for simplicity
//			 and ultrasound module declaration
//
//////////////////////////////////////////////////////////////////////////////////
module main_fsm(
	 input clock,
	 input reset,
	 input enable,
	 input ultrasound_done, // becomes output (put ultrasound inside)
	 input move_ready, // becomes output
	 input orientation_done, //becomes output
	 input reached_target, // goes away as is internal
	 input missed_target, //goes away as is internal
	 //input [11:0] rover_location, // r is [7:0] theta is [11:8]
	 //input [3:0] target_location,
	 input [11:0] move_command, // becoms output
	 // output [4:0] orientation,
	 output reg run_ultrasound,// goes away as is internal
	 output reg enable_orientation, // goes away as is internal
	 output reg transmit_ir,
	 // output analyzer_clock, // for debug only
	 // output [15:0] analyzer_data // for debug only
	 output reg [3:0] state // exposed for debug
	 );
		
	 // on/off parameters
	 parameter OFF 						= 1'b0;
	 parameter ON 							= 1'b1;
	 // state parameters
	 parameter IDLE 						= 4'h0;
	 parameter RUN_ULTRASOUND_1		= 4'h1;
	 parameter ORIENTATION_PHASE_1 	= 4'h2;
	 parameter ORIENTATION_MOVE		= 4'h3;
	 parameter RUN_ULTRASOUND_2		= 4'h4;
	 parameter ORIENTATION_PHASE_2	= 4'h5;
	 parameter CALC_MOVE_COMMAND		= 4'h6;
	 parameter MOVE_MOVE					= 4'h7;
	 parameter RUN_ULTRASOUND_3		= 4'h8;
	 parameter ARE_WE_DONE				= 4'h9;
	 
	 
	 // ORIENTATION_PHASE_1 helper memory and paramenters for orientation and path
   reg [11:0] original_location;
   reg [11:0] updated_location;
   parameter ORIENTATION_MOVE = 12'h005;
   
   // ORIENTATION_PHASE_2 helper to do the math for orientation
   reg orientation_helper_enable;
   wire orientation_helper_done;
   orientation_math om (.r_theta_original(original_location),.r_theta_final(updated_location),.orientation(orientation),
                        .enable(orientation_helper_enable),.done(orientation_helper_done),.reset(reset),.clock(clock));
	 
	 // ORIENTATION_MOVE and MOVE_MOVE helpers
	 reg [33:0] move_delay_timer; // 34 bits for max of 255 seconds
	 parameter MOVE_DELAY_FACTOR = 27000000;
	 
	 always @(posedge clock) begin
		if (reset) begin
			state <= IDLE;
			run_ultrasound <= OFF;
			enable_orientation <= OFF;
			transmit_ir <= OFF;
		end
		else begin
			case (state)
				
				// wait for ultrasound to finish then enable orientation to start
				RUN_ULTRASOUND_1: begin
					run_ultrasound <= OFF;
					if (ultrasound_done) begin
						state <= ORIENTATION_PHASE_1;
						enable_orientation <= ON;
					end
				end
				
				// in phase 1 of orientation we send out the move command
				// to just move the rover forward
				ORIENTATION_PHASE_1: begin
					enable_orientation <= OFF;
					if (move_ready) begin
						transmit_ir <= ON;
						move_delay_timer <= MOVE_DELAY_FACTOR * move_command[7:0];
						state <= ORIENTATION_MOVE;
					end
				end
				
				// we then wait for the move to complete
				ORIENTATION_MOVE: begin
					transmit_ir <= OFF;
					if (move_delay_timer == 0) begin
						// now we are done moving so go get figure out where it went
						state <= RUN_ULTRASOUND_2;
						run_ultrasound <= ON;
					end
					else begin
						move_delay_timer <= move_delay_timer - 1;
					end
				end
				
				// wait for ultrasound to finish then enable next orientation phase
				RUN_ULTRASOUND_2: begin
					run_ultrasound <= OFF;
					if (ultrasound_done) begin
						state <= ORIENTATION_PHASE_2;
						enable_orientation <= ON;
					end
				end
				
				// in phase 2 of orientation we calc the orientation and then
				// we send out the next move command to do the move
				ORIENTATION_PHASE_2: begin
					enable_orientation <= OFF;
					// for now we ignore the move because its a stretch goal
					// and bypass the next few states
					if (orientation_done) begin
						state <= IDLE;
						//if (move_ready) begin
							//transmit_ir <= ON;
							//move_delay_timer <= MOVE_DELAY_FACTOR * move_command[7:0];
							//state <= MOVE_MOVE;
						//end
					end
				end
				
				// we then wait for the move to complete
				MOVE_MOVE: begin
					transmit_ir <= OFF;
					if (move_delay_timer == 0) begin
						// now we are done moving so go get figure out where it went
						state <= RUN_ULTRASOUND_3;
						run_ultrasound <= ON;
					end
					else begin
						move_delay_timer <= move_delay_timer - 1;
					end
				end
				
				// wait for ultrasound to finish then enable next move analysis
				RUN_ULTRASOUND_3: begin
					run_ultrasound <= OFF;
					if (ultrasound_done) begin
						state <= ORIENTATION_PHASE_2;
						enable_orientation <= ON;
					end
				end
				
				// see if we are done else keep moving toward target
				ARE_WE_DONE: begin
					enable_orientation <= OFF;
					// if done we are done!
					if (reached_target) begin
						state <= IDLE;
					end
					else begin
						// if we missed repeat to get closer
						if (missed_target) begin
							state <= RUN_ULTRASOUND_1;
							run_ultrasound <= ON;
						end
						// else keep waiting for result
					end
				end
				
			
				// default to IDLE state
				default: begin
					if (enable) begin
						// when enabled start the process by doing a run_ultrasound
						state <= RUN_ULTRASOUND_1;
						run_ultrasound <= ON;
					end
				end
			
			endcase
		end
	 end
	
endmodule
