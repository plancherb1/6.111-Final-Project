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
	 input [3:0] target_location,
    input [9:0] ultrasound_signals, // can use up to 10 ultrasounds
    output reg [9:0] ultrasound_commands, // can use up to 10 ultrasounds
    output reg [9:0] ultrasound_power, // can use up to 10 ultrasounds
    output ultrasound_done,
    output [11:0] rover_location, // r is [7:0] theta is [11:8]
    output orientation_done,
	 output [4:0] orientation,
	 output [11:0] move_command,
	 output reg transmit_ir,
    output reg reached_target,
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
	 parameter ORIENTATION_MOVE_S		= 4'h3;
	 parameter RUN_ULTRASOUND_2		= 4'h4;
	 parameter ORIENTATION_PHASE_2	= 4'h5;
    parameter ORIENTATION_PHASE_3	= 4'h6;
	 parameter CALC_MOVE_COMMAND		= 4'h7;
	 parameter MOVE_MOVE					= 4'h8;
	 parameter RUN_ULTRASOUND_3		= 4'h9;
	 parameter ARE_WE_DONE				= 4'hA;
	 
	
   // ultrasound helpers
   reg run_ultrasound;
   wire [2:0] ultrasound_state;
   // Ultrasound
   ultrasound_location_calculator ul(.clock(clock),.reset(reset),
									.calculate(run_ultrasound),
                           .rover_location(rover_location),
									.done(ultrasound_done),
									//.analyzer_clock(analyzer3_clock),
									//.analyzer_data(analyzer3_data),
									.state(ultrasound_state),
                           .ultrasound_signals(ultrasound_signals),
									.ultrasound_commands(ultrasound_commands),
									.ultrasound_power(ultrasound_power));
	
    // ORIENTATION_PHASE_1/2/3 helper memory and paramenters for orientation and path
    reg [11:0] original_location;
    reg [11:0] updated_location;
    parameter ORIENTATION_MOVE = 12'h005;
    reg orientation_helper_enable;
    orientation_math om (.r_theta_original(original_location),.r_theta_final(updated_location),.orientation(orientation),
                        .enable(orientation_helper_enable),.done(orientation_done),.reset(reset),.clock(clock));
	 
	 // ORIENTATION_MOVE and MOVE_MOVE helpers
	 reg [33:0] move_delay_timer; // 34 bits for max of 255 seconds
	 parameter MOVE_DELAY_FACTOR = 27000000;
    
    // MOVE_COMMAND_CALC helpers
    reg move_command_calc_helper_done;
    reg move_command_calc_helper_enable;
    wire [11:0] move_command_t;
    
    // MAKE MODULE TO DO THE MATH HERE
    
    // ARE_WE_DONE helpers
    reg location_reached_helper_done;
    reg location_reached_helper_enable;
    
    // MAKE MODULE TO DO THE MATH HERE
	 
	 always @(posedge clock) begin
		if (reset) begin
			state <= IDLE;
			run_ultrasound <= OFF;
			enable_orientation <= OFF;
			transmit_ir <= OFF;
		end
		else begin
			case (state)
				
				// wait for ultrasound to finish then save the location for orientation
				RUN_ULTRASOUND_1: begin
					run_ultrasound <= OFF;
					if (ultrasound_done) begin
						state <= ORIENTATION_PHASE_1;
						original_location <= rover_location;
						move_command <= ORIENTATION_MOVE;
					end
				end
				
				// in phase 1 of orientation we send out the move command
				// to just move the rover forward
				ORIENTATION_PHASE_1: begin
               transmit_ir <= ON;
               move_delay_timer <= MOVE_DELAY_FACTOR * move_command[7:0];
               state <= ORIENTATION_MOVE_S;
				end
				
				// we then wait for the move to complete
				ORIENTATION_MOVE_S: begin
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
				
				// wait for ultrasound to finish then save the location for orientation math phase
				RUN_ULTRASOUND_2: begin
					run_ultrasound <= OFF;
					if (ultrasound_done) begin
						state <= ORIENTATION_PHASE_2;
                  updated_location <= rover_location;
					end
				end
				
				// in phase 2 of orientation we enable the helper to calc the orientation
				ORIENTATION_PHASE_2: begin
					orientation_helper_enable <= ON;
               state <= ORIENTATION_PHASE_3;
				end
            
            // in phase 3 of orientation we wait for the helper to finish and then
				// we send out the next move command to do the move
            ORIENTATION_PHASE_3: begin
					orientation_helper_enable <= OFF;
					// for now we ignore the move because its a stretch goal
					// and bypass the next few states
					if (orientation_done) begin
						state <= IDLE;
						//initiate the helper to calculate the move command
                  //state <= MOVE_COMMAND_CALC;
                  //move_command_calc_helper_enable <= ON;
					end
				end
            
            // use the helper to calculate the move command
				MOVE_COMMAND_CALC: begin
               if (move_command_calc_helper_done) begin
                  move_command <= move_command_t;
                  transmit_ir <= ON;
                  move_delay_timer <= MOVE_DELAY_FACTOR * move_command_t[7:0];
                  state <= MOVE_MOVE;
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
						state <= ARE_WE_DONE;
						location_reached_helper_enable <= ON;
					end
				end
				
				// see if we are done else keep moving toward target
				ARE_WE_DONE: begin
					location_reached_helper_enable <= OFF;
					// wait for the helper to finish
               if (location_reached_helper_done) begin
                  // if we are there then done
                  if (reached_target) begin
                     state <= IDLE;
                  end
                  // else restart from orientation step and try again
                  else begin
                     state <= RUN_ULTRASOUND_1;
                     run_ultrasound <= ON;
						end
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
