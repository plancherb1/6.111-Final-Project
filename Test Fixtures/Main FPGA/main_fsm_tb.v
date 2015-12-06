`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   19:44:39 12/05/2015
// Design Name:   main_fsm
// Module Name:   /afs/athena.mit.edu/user/p/l/plancher/Desktop/6.111-Final-Project/Test Fixtures/Main FPGA//main_fsm_tb.v
// Project Name:  Main_FPGA
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: main_fsm
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module main_fsm_tb;

	// Inputs
	reg clock;
	reg reset;
	reg run_program;
	reg [11:0] target_location;
	reg ultrasound_done;
	reg [11:0] rover_location;

	// Outputs
	wire run_ultrasound;
	wire orientation_done;
	wire [4:0] orientation;
	wire [11:0] move_command;
	wire transmit_ir;
	wire reached_target;
	wire [11:0] orient_location_1;
	wire [11:0] orient_location_2;
	wire [4:0] state;

	// Instantiate the Unit Under Test (UUT)
	main_fsm uut (
		.clock(clock), 
		.reset(reset), 
		.run_program(run_program), 
		.target_location(target_location), 
		.ultrasound_done(ultrasound_done), 
		.rover_location(rover_location), 
		.run_ultrasound(run_ultrasound), 
		.orientation_done(orientation_done), 
		.orientation(orientation), 
		.move_command(move_command), 
		.transmit_ir(transmit_ir), 
		.reached_target(reached_target), 
		.orient_location_1(orient_location_1), 
		.orient_location_2(orient_location_2), 
		.state(state)
	);
	
	always #5 clock = !clock;
	initial begin
		// Initialize Inputs
		clock = 0;
		reset = 0;
		run_program = 0;
		target_location = 0;
		ultrasound_done = 0;
		rover_location = 0;

		// Wait 100 ns for global reset to finish
		#100;
		reset = 1;
		#10;
		reset = 0;
        
		// Add stimulus here
		run_program = 1;
		target_location = {4'h7,8'h30};//105 degrees 48 inches out
		#10;
		run_program = 0;
		#10;
		ultrasound_done <= 1;
		rover_location = {4'h1,8'h07}; //15 degrees 7 inches out
		#10;
		ultrasound_done <= 0;
		#400;
		ultrasound_done <= 1;
		rover_location = {4'h1,8'h20}; //15 degrees 32 inches out
		#10;
		ultrasound_done <= 0;
		
	end
      
endmodule

