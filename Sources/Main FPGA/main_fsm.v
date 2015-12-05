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
	 input run_program,
	 input [11:0] target_location, // r is [7:0] theta is [11:8]
	 input ultrasound_done,
	 input [11:0] rover_location, // r is [7:0] theta is [11:8]
	 output reg run_ultrasound,
	 output orientation_done,
	 output reg [4:0] orientation,
	 output reg [11:0] move_command,
	 output reg transmit_ir,
    output reg reached_target,
	 // output analyzer_clock, // for debug only
	 // output [15:0] analyzer_data // for debug only
	 output reg [11:0] orient_location_1, // exposed for debug
	 output reg [11:0] orient_location_2, // exposed for debug
	 output reg [4:0] state // exposed for debug
	 );
		
	 // on/off parameters
	 parameter OFF 						= 1'b0;
	 parameter ON 							= 1'b1;
	 // state parameters
	 parameter IDLE 						= 5'h00;
	 parameter ONE_CYCLE_DELAY_1		= 5'h01;
	 parameter RUN_ULTRASOUND_1		= 5'h02;
	 parameter ORIENTATION_PHASE_1 	= 5'h03;
    parameter IR_TRANSMIT_DELAY_1  = 5'h04;
	 parameter ORIENTATION_MOVE_S		= 5'h05;
	 parameter ONE_CYCLE_DELAY_2		= 5'h06;
	 parameter RUN_ULTRASOUND_2		= 5'h07;
	 parameter ORIENTATION_PHASE_2	= 5'h08;
	 parameter ONE_CYCLE_DELAY_3		= 5'h0A;
	 parameter ORIENTATION_PHASE_3	= 5'h0B;
	 parameter CALC_MOVE_COMMAND_1	= 5'h0C;
	 parameter ONE_CYCLE_DELAY_4		= 5'h0D;
    parameter CALC_MOVE_COMMAND_2	= 5'h0E;
	 parameter ONE_CYCLE_DELAY_5		= 5'h0F;
    parameter CALC_MOVE_COMMAND_3	= 5'h10;
    parameter IR_TRANSMIT_DELAY_2	= 5'h11;
	 parameter MOVE_MOVE				   = 5'h12;
	 parameter ONE_CYCLE_DELAY_6		= 5'h13;
	 parameter RUN_ULTRASOUND_3		= 5'h14;
	 parameter ONE_CYCLE_DELAY_7		= 5'h15;
	 parameter ARE_WE_DONE				= 5'h16;
	
    // ORIENTATION_PHASE_1/2/3 helper memory and paramenters for orientation and path
    reg [31:0] delay_count;
	 parameter LOCATION_DELAY = 27000000; // delay a second just to be safe for this to clear because
														// weird things are happening
	 parameter ORIENTATION_MOVE = 12'h00A;
    reg orientation_helper_enable;
    wire [4:0] orientation_t;
    orientation_math om (.r_theta_original(orient_location_1),.r_theta_final(orient_location_2),.orientation(orientation_t),
                        .enable(orientation_helper_enable),.done(orientation_done),.reset(reset),.clock(clock));
	 
    // IR Transmit Helpers
    reg [22:0] ir_transmit_delay_counter;
    parameter IR_TRANSMIT_DELAY_COUNT = 5000000; // 1/5 of a second need 23 bits
    
	 // ORIENTATION_MOVE and MOVE_MOVE helpers
	 reg [31:0] move_delay_timer; // large to make room for long moves
    reg [31:0] move_delay_inner_timer; // big for move_delay_factor 
	 parameter MOVE_DELAY_FACTOR = 13500000; // 1/2 of a second per move
	 parameter ORIENTATION_DELAY = ORIENTATION_MOVE[7:0];
    
    // MOVE_COMMAND_CALC helpers
    wire move_command_helper_done;
    reg move_command_helper_enable;
    wire [11:0] move_command_t;
    reg [4:0] needed_orientation;
    path_math pm (.location(rover_location),.target(target_location),
                  .current_orientation(orientation), .needed_orientation(needed_orientation),
                  .enable(move_command_helper_enable),.clock(clock),.reset(reset),
                  .done(move_command_helper_done),.move_command(move_command_t));
    
    // ARE_WE_DONE helpers
    wire location_reached_helper_done;
	 reg location_reached_helper_enable;
	 wire reached_target_t;
	 roughly_equal_locations rel (.clock(clock),.reset(reset),.loc_1(rover_location),.loc_2(target_location),
                                 .done(location_reached_helper_done),.enable(location_reached_helper_enable),
                                 .equal(reached_target_t));
	 
	 // for debug only
	 //assign analyzer_clock = clock;
	 //assign analyzer_data = {state,original_location[5:0],updated_location[5:0]};
	 
	 always @(posedge clock) begin
		if (reset) begin
			state <= IDLE;
         // ultrasound resets
			run_ultrasound <= OFF;
			orient_location_1 <= 12'h000;
			orient_location_2 <= 12'h000;
         delay_count <= 32'h0000_0000;
         // orientation resets
			orientation_helper_enable <= OFF;
         orientation <= 4'h0;
         // ir resets
			move_command <= 12'h000;
			transmit_ir <= OFF;
         ir_transmit_delay_counter <= 22'h00_0000;
         // move resets
			move_delay_timer <= 32'h0000_0000;
         move_delay_inner_timer <= 32'h0000_0000;
		   move_command_helper_enable  <= OFF;
         // other resets
			reached_target <= OFF;
			location_reached_helper_enable  <= OFF;
		end
		else begin
			case (state)
				
				ONE_CYCLE_DELAY_1: state <= RUN_ULTRASOUND_1;
				
				// wait for ultrasound to finish then save the location for orientation
				RUN_ULTRASOUND_1: begin
					run_ultrasound <= OFF;
					if (ultrasound_done) begin
						state <= ORIENTATION_PHASE_1;
					end
				end
				
				// in phase 1 of orientation we send out the move command
				// to just move the rover forward
				ORIENTATION_PHASE_1: begin
					// induce a delay to solve potential timing issue
					if (delay_count == LOCATION_DELAY - 1) begin
						transmit_ir <= ON;
						orient_location_1 <= rover_location;
						move_command <= ORIENTATION_MOVE;
						move_delay_timer <= ORIENTATION_DELAY;
                  move_delay_inner_timer <= MOVE_DELAY_FACTOR;
						state <= IR_TRANSMIT_DELAY_1;
						delay_count <= 0;
					end
					else begin
						delay_count <= delay_count + 1;
					end
				end
            
            // we need to give the IR 1/5 of a second to transmit multiple timescale
            // in case of error and bits being dropped (also 1/5 is less than min move)
            IR_TRANSMIT_DELAY_1: begin
               if (ir_transmit_delay_counter == IR_TRANSMIT_DELAY_COUNT) begin
                  state <= ORIENTATION_MOVE_S;
                  ir_transmit_delay_counter <= 0;
                  transmit_ir <= OFF;
               end
               else begin
                  ir_transmit_delay_counter <= ir_transmit_delay_counter + 1;
               end
            end
				
				// we then wait for the move to complete
				ORIENTATION_MOVE_S: begin
               if (move_delay_inner_timer == 1) begin
                  if (move_delay_timer == 1) begin
                     // now we are done moving so go get figure out where it went
                     state <= ONE_CYCLE_DELAY_2;
                     run_ultrasound <= ON;
                  end
                  else begin
                     move_delay_timer <= move_delay_timer - 1;
                     move_delay_inner_timer <= MOVE_DELAY_FACTOR;
                  end
               end
               else begin
                  move_delay_inner_timer <= move_delay_inner_timer - 1;
               end
				end
				
				ONE_CYCLE_DELAY_2: state <= RUN_ULTRASOUND_2;
				
				// wait for ultrasound to finish then save the location for orientation math phase
				RUN_ULTRASOUND_2: begin
					run_ultrasound <= OFF;
					if (ultrasound_done) begin
						state <= ORIENTATION_PHASE_2;
					end
				end
				
				// in phase 2 of orientation we enable the helper to calc the orientation
				ORIENTATION_PHASE_2: begin
					// induce a delay to solve potential timing issue
					if (delay_count == LOCATION_DELAY - 1) begin
						orient_location_2 <= rover_location;
						orientation_helper_enable <= ON;
						state <= ONE_CYCLE_DELAY_3;
						delay_count <= 0;
					end
					else begin
						delay_count <= delay_count + 1;
					end
				end
            
				ONE_CYCLE_DELAY_3: state <= ORIENTATION_PHASE_3;
				
            // in phase 3 of orientation we wait for the helper to finish and then
				// we send out the next move command to do the move
            ORIENTATION_PHASE_3: begin
					orientation_helper_enable <= OFF;
					// for now we ignore the move because its a stretch goal
					// and bypass the next few states
					if (orientation_done) begin
                  orientation <= orientation_t;
						//state <= IDLE;
						//then move to calc the move command
                  state <= CALC_MOVE_COMMAND_1;
					end
				end
            
            // first we need the orientation between the end and the target
				CALC_MOVE_COMMAND_1: begin
               orient_location_1 <= rover_location;
               orient_location_2 <= target_location;
               orientation_helper_enable <= ON;
               state <= ONE_CYCLE_DELAY_4;
            end
            
				ONE_CYCLE_DELAY_4: state <= CALC_MOVE_COMMAND_2;
				
            // then we save that orientation and calc the move command with it
            CALC_MOVE_COMMAND_2: begin
               orientation_helper_enable <= OFF;
               // make sure our new orientation clears
               if (orientation_done) begin
                  needed_orientation <= orientation_t;
                  move_command_helper_enable <= ON;
                  state <= ONE_CYCLE_DELAY_5;
               end
            end
				
				ONE_CYCLE_DELAY_5: state <= CALC_MOVE_COMMAND_3;
            
            // then we have a move command so prep to send it via ir
            CALC_MOVE_COMMAND_3: begin
               move_command_helper_enable <= OFF;
               if (move_command_helper_done) begin
                  move_command <= move_command_t;
                  transmit_ir <= ON;
                  // set the delay for 1 second per angle and distance to travel and
                  // an additional 1 for the stall in between
                  move_delay_timer <= move_command[7:0] + move_command[11:8] + 1;
                  move_delay_inner_timer <= MOVE_DELAY_FACTOR;
                  state <= IR_TRANSMIT_DELAY_2;
               end
            end
            
            // we need to give the IR 1/5 of a second to transmit multiple timescale
            // in case of error and bits being dropped (also 1/5 is less than min move)
            IR_TRANSMIT_DELAY_2: begin
               if (ir_transmit_delay_counter == IR_TRANSMIT_DELAY_COUNT) begin
                  state <= MOVE_MOVE;
                  ir_transmit_delay_counter <= 0;
                  transmit_ir <= OFF;
               end
               else begin
                  ir_transmit_delay_counter <= ir_transmit_delay_counter + 1;
               end
            end
            
				// we then wait for the move to complete
				MOVE_MOVE: begin
               if (move_delay_inner_timer == 1) begin
                  if (move_delay_timer == 1) begin
                     // now we are done moving so go get figure out where it went
                     state <= ONE_CYCLE_DELAY_6;
                     run_ultrasound <= ON;
                  end
                  else begin
                     move_delay_timer <= move_delay_timer - 1;
                     move_delay_inner_timer <= MOVE_DELAY_FACTOR;
                  end
               end
               else begin
                  move_delay_inner_timer <= move_delay_inner_timer - 1;
               end
				end
				
				ONE_CYCLE_DELAY_6: state <= RUN_ULTRASOUND_3;
				
				// wait for ultrasound to finish then enable next move analysis
				RUN_ULTRASOUND_3: begin
					run_ultrasound <= OFF;
					if (ultrasound_done) begin
						state <= ONE_CYCLE_DELAY_7;
						location_reached_helper_enable <= ON;
					end
				end
				
				ONE_CYCLE_DELAY_7: state <= ARE_WE_DONE;
				
				// see if we are done else keep moving toward target
				ARE_WE_DONE: begin
					location_reached_helper_enable <= OFF;
					// wait for the helper to finish
               if (location_reached_helper_done) begin
                  // currently we just do one shot so commented out
						reached_target <= reached_target_t;
						state <= IDLE;
						/*
                  // if we are there then done
                  if (reached_target_t) begin
                     state <= IDLE;
                  end
                  // else restart from orientation step and try again
                  else begin
                     state <= RUN_ULTRASOUND_1;
                     run_ultrasound <= ON;
                     // ultrasound resets
                     orient_location_1 <= 12'h000;
                     orient_location_2 <= 12'h000;
                     delay_count <= 32'h0000_0000;
                     // orientation resets
                     orientation_helper_enable <= OFF;
                     orientation <= 4'h0;
                     // ir resets
                     move_command <= 12'h000;
                     transmit_ir <= OFF;
                     ir_transmit_delay_counter <= 22'h00_0000;
                     // move resets
                     move_delay_timer <= 32'h0000_0000;
                     move_delay_inner_timer <= 32'h0000_0000;
                     move_command_helper_enable  <= OFF;
                     // other resets
                     reached_target <= OFF;
                     location_reached_helper_enable  <= OFF;
						end
						*/
					end
				end
				
			
				// default to IDLE state
				default: begin
					if (run_program) begin
						// when enabled start the process by doing a run_ultrasound and reset all else
						state <= ONE_CYCLE_DELAY_1;
						run_ultrasound <= ON;
                  // ultrasound resets
                  orient_location_1 <= 12'h000;
                  orient_location_2 <= 12'h000;
                  delay_count <= 32'h0000_0000;
                  // orientation resets
                  orientation_helper_enable <= OFF;
                  orientation <= 4'h0;
                  // ir resets
                  move_command <= 12'h000;
                  transmit_ir <= OFF;
                  ir_transmit_delay_counter <= 22'h00_0000;
                  // move resets
                  move_delay_timer <= 32'h0000_0000;
                  move_delay_inner_timer <= 32'h0000_0000;
                  move_command_helper_enable  <= OFF;
                  // other resets
                  reached_target <= OFF;
                  location_reached_helper_enable  <= OFF;
					end
				end
			
			endcase
		end
	 end
	
endmodule
