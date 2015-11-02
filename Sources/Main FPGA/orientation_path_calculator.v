//////////////////////////////////////////////////////////////////////////////////
// Company:        MIT 6.111 Final Project
// Engineer:       Brian Plancher
// 
// Module Name:    Orientation and Path Calculator
// Project Name:   FPGA Phone Home
//
//////////////////////////////////////////////////////////////////////////////////

module orientation_path_calculator(
	input clock,
	input reset,
	input enable,
   input [11:0] rover_location,
   input [3:0] target_location,
   output reg done,
   output reg [11:0] move_command
	// output analyzer_clock, // for debug only
	// output [15:0] analyzer_data // for debug only
	);
	
	// TBD DO IT
	// will need internal state to determine the mode we are in
	always @(posedge clock) begin
		done <= 1;
		move_command <= 11'h7FF;
	end
	
endmodule	 