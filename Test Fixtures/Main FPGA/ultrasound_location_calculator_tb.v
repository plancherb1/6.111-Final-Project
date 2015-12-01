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
		#40;
		// now we are "trigered" lets get some data back
		#10;
		ultrasound_signals = 1;
		#400;
		ultrasound_signals = 0;
		// should have registered 40 cycles which gets us 20 for the first one
		#10;
		// now we should be triggering again
		#50;
		// now we are triggered
		#10;
		ultrasound_signals = 1;
		#280;
		ultrasound_signals = 0;
		// loaded in a 14 for #2
		#10;
		#50;
		#10;
		ultrasound_signals = 1;
		#450;
		ultrasound_signals = 0;
		// loaded in a 22 for #3 so median is 20
		#50;
		// we should now be done
		
	end
      
endmodule

