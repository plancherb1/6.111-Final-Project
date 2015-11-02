`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        MIT 6.111 Final Project
// Engineer:       Brian Plancher
// 
// Module Name:    IR Receiver
// Project Name:   FPGA Phone Home
//
//////////////////////////////////////////////////////////////////////////////////
module motor_signal_stream(
	input clock,
	input reset,
	input command_ready,
	input [11:0] command,
	output reg motor_l,
	output reg motor_r
	// output analyzer_clock, // for debug only
	// output [15:0] analyzer_data // for debug only
   );
   
   reg [2:0] state;
   parameter IDLE = 2'b00;
   parameter TURNING = 2'b10;
   parameter MOVING = 3'b11;
   reg angle;
   reg distance;
   
   // synchronize on clock
	always @(posedge clock) begin
		// if we see reset update all to default
		if (reset == ACTIVE) begin
			state <= IDLE;
			motor_l <= 0;
			motor_r <= 0;
		end
		// else enter states
		else begin
			case (state)
				// don't move until command is ready
				IDLE: begin
					if (command_ready <= ACTIVE) begin
						state <= TURNING;
						angle <= command[11:7];
						distance <= command[6:0];
					end
				end
				
				// then turn first to face the desired direction
				TURNING: begin
					// turn until you have finished the angle then go to MOVING
					// NEED TO IMPLIMENT
				end
				
				// then move until you reach the target
				MOVING: begin
					// move until you have finished the distance then go to IDLE
					// NEED TO IMPLIMENT
				end
				
			endcase
		end
endmodule