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
	output reg motor_r,
	output reg move_done,
	// output analyzer_clock, // for debug only
    // output [15:0] analyzer_data // for debug only
	output reg [3:0] state // exposed for debug
   );
   
   parameter OFF = 1'b0;
   parameter ON = 1'b1;
   
   // fsm state parameters
   parameter IDLE = 4'h0;
   parameter TURNING = 4'h1;
   parameter MOVING = 4'h2;
   parameter PAUSE = 4'h3;
   parameter TESTING_DELAY = 4'hF; // for testing mode only
   
   // parameters for distance and angle move times
   
   // CALC THESE WITH TEST MODE WHICH IS ENABLED------------------------------------------
   
   parameter FIFTEEN_DEG = 15;
   parameter FOUR_INCHES = 4;
   
   // CALC THESE WITH TEST MODE WHICH IS ENABLED -----------------------------------------
   
   parameter PAUSE_TIME = 25000000; // one second // set to 5 for simulation
   reg [5:0] angle;
   reg [6:0] distance;
   reg [5:0] angle_count;
   reg [31:0] angle_sub_count;
   reg [6:0] distance_count;
   reg [31:0] distance_sub_count;
   reg [31:0] pause_count;
   
   // helpers for test of distance move mode
   parameter COUNT_GOAL = 2500000; // counts at 25mhz for 0.1 seconds // set to 25 for simulation
   reg [31:0] test_sub_counter;
   reg [11:0] test_counter;
   // end testing block
   
   // synchronize on clock
	always @(posedge clock) begin
		// if we see reset update all to default
		if (reset == ON) begin
			state <= IDLE;
			motor_l <= OFF;
			motor_r <= OFF;
			angle <= 0;
			angle_count <= 0;
			angle_sub_count <= 0;
			distance <= 0;
			distance_count <= 0;
			distance_sub_count <= 0;
			pause_count <= 0;
			move_done <= 0;
		end
		// else enter states
		else begin
			case (state)
				
				// turn first to face the desired direction
				TURNING: begin
					// turn until you have finished the angle then go to MOVING
					if (angle_sub_count == FIFTEEN_DEG - 1) begin
                       if (angle_count == angle - 1) begin
                           motor_l <= OFF;
                           motor_r <= OFF;
                           state <= PAUSE;
                           angle_count <= 0;
                           angle_sub_count <= 0;
                       end
					   else begin
                           angle_count <= angle_count + 1;
                           angle_sub_count <= 0;
                        end
					end
					else begin
					   angle_sub_count <= angle_sub_count + 1;
					end
				end
				
				// then pause to let the motors reset
				PAUSE: begin
				    if (pause_count == PAUSE_TIME - 1) begin
				        motor_l <= ON;
                        motor_r <= ON;
                        state <= MOVING;
				    end
				    else begin
				        pause_count = pause_count + 1;
				    end
				end
				
				// then move until you reach the target
				MOVING: begin
					// move until you have finished the distance then go to IDLE
                    if (distance_sub_count == FOUR_INCHES - 1) begin
                        if (distance_count == distance - 1) begin
                           motor_l <= OFF;
                           motor_r <= OFF;
                           state <= IDLE;
                           distance_count <= 0;
                           distance_sub_count <= 0;
                           move_done <= 1;
                        end
                        else begin
                           distance_count <= distance_count + 1;
                           distance_sub_count <= 0;
                        end
                    end
                    else begin
                       distance_sub_count <= distance_sub_count + 1;
                    end
				end
				
				// for test use the code below to simply move for 2500000 clock cycles times
                // the value passed in from move command which is simply 0.1 second increments
				TESTING_DELAY: begin
				    if (test_counter == command - 1) begin
                        motor_l <= OFF;
                        motor_r <= OFF;
                        test_counter <= 0;
                        test_sub_counter <= 0;
                        state <= IDLE;
				    end
                    else if (test_sub_counter == COUNT_GOAL-1) begin
                        test_counter <= test_counter + 1;
                        test_sub_counter <= 0; 
                    end
                    else begin
                        test_sub_counter <= test_sub_counter + 1;
                    end
				end
				
				// don't move until command is ready
                default: begin
                    move_done <= 0;
                    if (command_ready) begin
                        //state <= TURNING;
                        //motor_l <= ON;
                        //motor_r <= OFF;
                        //angle <= command[11:7];
                        //distance <= command[6:0];
                        //angle_count <= 0;
                        //angle_sub_count <= 0;
                        //distance_count <= 0;
                        //distance_sub_count <= 0;
                        //pause_count <= 0;
                        //move_done <= 0;
                        
                        // testing mode code below
                        test_counter <= 0;
                        test_sub_counter <= 1;
                        motor_l <= ON;
                        motor_r <= ON;
                        state <= TESTING_DELAY;
                        // end testing block
                    end
                end
				
			endcase
		end
	end
endmodule