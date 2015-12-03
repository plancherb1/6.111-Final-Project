`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        MIT 6.111 Final Project
// Engineer:       Brian Plancher
// 
// Module Name:    IR Receiver
// Project Name:   FPGA Phone Home
//
//////////////////////////////////////////////////////////////////////////////////
module ir_receiver(
	input clock,
	input reset,
	input data_in,
	output reg done,
	output reg [11:0] move_data,
	output reg [3:0] state // output for debug
	// output analyzer_clock, // for debug only
	// output [15:0] analyzer_data // for debug only
   );
	
	// basic parameters
	parameter ACTIVE = 1'b1;
	parameter IDLE = 1'b0;
	parameter WILDCARD = 1'b?;
	
	// fsm controls
	parameter STATE_WAIT_START  		= 4'h1;
	parameter STATE_COMMAND 			= 4'h2;
	parameter STATE_WAIT_1				= 4'h3;
	
	// for tracking what we have seen
	parameter HIGH_PULSES = 8'h10; // 2*8*dividerpulses
	parameter LOW_PULSES = 8'h08; // 1*8*dividerpulses
	parameter START_PULSES = 8'h20; // 4*8*dividerpulses
	parameter HIGH_THRESHOLD = 8'h02;
	parameter LOW_THRESHOLD = 8'h02;
	parameter START_THRESHOLD = 8'h02;
	parameter COMMAND_BITS = 8'h0F;
	reg [3:0] bits_seen;
	reg [7:0] positive_samples;
	
	// get our divider
	wire enable;
	parameter COUNT_GOAL = 1875; // counts at 25mhz for 600us
	divider_600us #(.COUNT_GOAL(COUNT_GOAL)) d1(.clk(clock),.reset(reset),.enable(enable)); // for simulation replace with assign enable = 1; //
	
	// set up debug
	// assign analyzer_clock = enable;
	// assign analyzer_data = {16'h0000};
	
	// synchronize on clock
	always @(posedge clock) begin
		// if we see reset update all to default
		if (reset == ACTIVE) begin
			move_data <= 12'h000;
			done <= 0;
			bits_seen <= 0;
			positive_samples <= 0;
			state <= STATE_WAIT_START;
		end
		// else enter states
		else begin
			case (state)
				
				// between the command we go into state wait for 1 and just ignore all 0s
				STATE_WAIT_1: begin
					if (data_in == ACTIVE) begin
						positive_samples <= 1;
						state <= STATE_COMMAND;
					end
				end
				
				// load in the command until we see all bits
				STATE_COMMAND: begin
					// sample on enable and see where we are
					if (enable) begin
						// if we see a 0 test the stream for a valid high or low
						if (data_in == IDLE) begin
							// if in threshold for high add a high
							if ((positive_samples >= (HIGH_PULSES - HIGH_THRESHOLD)) && 
								 (positive_samples <= (HIGH_PULSES + HIGH_THRESHOLD))) begin
								// add a high and get ready for next signal
								move_data[bits_seen] <= 1'b1;
								positive_samples <= 0;
								// if we have seen all of the bits then notify to done and wait for next command
								if (bits_seen == COMMAND_BITS - 1) begin
									state <= STATE_WAIT_START;
									bits_seen <= 0;
									done <= 1;
								end
								// else stay in this state
								else begin
									bits_seen <= bits_seen + 1;
									state <= STATE_WAIT_1;
								end
							end
							// else if in threshold for low add a low
							else if ((positive_samples >= (LOW_PULSES - LOW_THRESHOLD)) && 
										(positive_samples <= (LOW_PULSES + LOW_THRESHOLD))) begin
								// add a low and get ready for next signal
								move_data[bits_seen] <= 1'b0;
								positive_samples <= 0;
								// if we have seen all of the bits then notify to done and wait for next command
								if (bits_seen == COMMAND_BITS - 1) begin
									state <= STATE_WAIT_START;
									bits_seen <= 0;
									done <= 1;
								end
								// else stay in this state
								else begin
									bits_seen <= bits_seen + 1;
									state <= STATE_WAIT_1;
								end
							end
							//else bad data so reset
							else begin
								positive_samples <= 0;
								bits_seen <= 0;
								state <= STATE_WAIT_START;
							end
						end
						// else keep counting 1s
						else begin
							positive_samples <= positive_samples + 1;
						end
					end
				end					
				
				// default "rover" to listen for command from the main FSM
				default: begin
					// command is no longer valid as it is stale
					done <= 0;
					// sample on enable and see where we are
					if (enable) begin
						// if we see a 0 test the stream for a valid start
						if (data_in == IDLE) begin
							// if in threshold move to command state
							if ((positive_samples >= START_PULSES - START_THRESHOLD) && 
								 (positive_samples <= START_PULSES + START_THRESHOLD)) begin
								state <= STATE_WAIT_1;
							end
							// in either case reset everything and if we don't move we are waiting for start again
							positive_samples <= 0;
						end
						// else keep counting 1s
						else begin
							positive_samples <= positive_samples + 1;
						end
					end
				end
			endcase
		end
	end
endmodule