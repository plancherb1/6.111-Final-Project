`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Engineer: Brian plancher
//
// Design Name:   ultrasound_location_calculator
// Module Name:   ultrasound_location_calculator_tb.v
// Project Name:  Main_FPGA
//
// Verilog Test Fixture created by ISE for module: ultrasound_location_calculator
//
////////////////////////////////////////////////////////////////////////////////

module ultrasound_location_calculator_tb;

	// Inputs
	reg clock;
	reg reset;
	reg calculate;
	reg [11:0] ultrasound_signals;

	// Outputs
	wire done;
	wire [11:0] rover_location;
	wire [11:0] ultrasound_commands;

	// Instantiate the Unit Under Test (UUT)
	ultrasound_location_calculator uut (
		.clock(clock), 
		.reset(reset), 
		.calculate(calculate), 
		.ultrasound_signals(ultrasound_signals), 
		.done(done), 
		.rover_location(rover_location), 
		.ultrasound_commands(ultrasound_commands)
	);
	
	// get the clock
	always #5 clock = !clock;
	
	initial begin
		// Initialize Inputs
		clock = 0;
		reset = 0;
		calculate = 0;
		ultrasound_signals = 0;

		// Wait 100 ns for global reset to finish
		#100;
		
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
		#4000;
		ultrasound_signals = 0;
		#10;

	end
      
endmodule

