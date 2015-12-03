`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// Engineer:  Brian Plancher
//
// Module Name:  motor_signal_stream_tb
//
//////////////////////////////////////////////////////////////////////////////////

module motor_signal_stream_tb;

    // Inputs
	reg clock;
	reg reset;
	reg command_ready;
    reg [11:0] command;

	// Outputs
	wire motor_l;
	wire motor_r;

	// Instantiate the Unit Under Test (UUT)
	motor_signal_stream uut (
		.clock(clock), 
		.reset(reset),
		.command_ready(command_ready),
		.command(command),
		.motor_l(motor_l),
		.motor_r(motor_r)
	);
	
	always #5 clock = !clock;
	initial begin
		// Initialize Inputs
		clock = 0;
		reset = 0;
		command_ready = 0;
		command = 12'h000;

		// Wait 100 ns for global reset to finish
		#100;
		
		// manual reset
		reset = 1;
		#10;
		reset = 0;
		#100;
        
		// Add stimulus here
        command = 12'h104; // 2 and 4
        command_ready = 1;
        #50;

	end

endmodule
