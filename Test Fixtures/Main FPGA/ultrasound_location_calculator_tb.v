`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   19:58:15 11/19/2015
// Design Name:   ultrasound_location_calculator
// Module Name:   /afs/athena.mit.edu/user/p/l/plancher/Desktop/6.111-Final-Project/Test Fixtures/Main FPGA//ultrasound_location_calculator_tb.v
// Project Name:  Main_FPGA
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: ultrasound_location_calculator
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module ultrasound_location_calculator_tb;

	// Inputs
	reg clock;
	reg reset;
	reg calculate;
	reg [9:0] ultrasound_signals;

	// Outputs
	wire done;
	wire [11:0] rover_location;
	wire [9:0] ultrasound_commands;
	wire [9:0] ultrasound_power;
	wire [2:0] state;

	// Instantiate the Unit Under Test (UUT)
	ultrasound_location_calculator uut (
		.clock(clock), 
		.reset(reset), 
		.calculate(calculate), 
		.ultrasound_signals(ultrasound_signals), 
		.done(done), 
		.rover_location(rover_location), 
		.ultrasound_commands(ultrasound_commands), 
		.ultrasound_power(ultrasound_power), 
		.state(state)
	);
	
	always #5 clock = !clock;
	
	initial begin
		// Initialize Inputs
		clock = 0;
		reset = 0;
		calculate = 0;
		ultrasound_signals = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		// Manual reset
		reset = 1;
		#10;
		reset = 0;
		#10;
        
		// Add stimulus here
		calculate = 1;
		#10;
		calculate = 0;
		#3000;
		// now we are "trigered" lets get some data back
		ultrasound_signals = 1;
		#60000;
		ultrasound_signals = 0;
		#40;
		ultrasound_signals = 1;
		#120000;
		ultrasound_signals = 0;
		#40;
		ultrasound_signals = 1;
		#180000;
		ultrasound_signals = 0;
		#40;
	end
      
endmodule

