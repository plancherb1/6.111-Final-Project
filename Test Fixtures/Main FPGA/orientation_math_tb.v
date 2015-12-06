`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   13:01:41 11/24/2015
// Design Name:   orientation_math
// Module Name:   /afs/athena.mit.edu/user/p/l/plancher/Desktop/6.111-Final-Project/Test Fixtures/Main FPGA//orientation_math_tb.v
// Project Name:  Main_FPGA
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: orientation_math
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module orientation_math_tb;

	// Inputs
	reg [11:0] r_theta_original;
	reg [11:0] r_theta_final;
	reg clock;
	reg enable;
	reg reset;

	// Outputs
	wire done;
	wire [4:0] orientation;

	// Instantiate the Unit Under Test (UUT)
	orientation_math uut (
		.r_theta_original(r_theta_original), 
		.r_theta_final(r_theta_final), 
		.clock(clock), 
		.enable(enable), 
		.reset(reset), 
		.done(done), 
		.orientation(orientation)
	);
	
	always #5 clock = !clock;
	initial begin
		// Initialize Inputs
		r_theta_original = 0;
		r_theta_final = 0;
		clock = 0;
		enable = 0;
		reset = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		
		// for help testing path math
		enable = 1;
		#10;
		r_theta_final = {4'h7,8'h30};//105 degrees 48 inches out
		r_theta_original = {4'h1,8'h20}; //15 degrees 32 inches out
		enable = 0;
		#150;
		
		// test shortcut
		enable = 1;
		#10;
		r_theta_original = 12'h110;
		r_theta_final = 12'h115;
		enable = 0;
		#60;
		// should report out 1
		
		enable = 1;
		#10;
		r_theta_original = 12'h110;
		r_theta_final = 12'h105;
		enable = 0;
		#60;
		// shoudl report 13
		
		// test 90 degree and 0 degree movements
		//enable = 1;
		//#10;
		//r_theta_original = 12'h50B; // 11 at 75
		//r_theta_final = 12'h129; // 41 at 15
		//enable = 0;
		//#100;
		
		//enable = 1;
		//#10;
		//r_theta_original = 12'h129; // 41 at 15
		//r_theta_final = 12'h50B; // 11 at 75
		//enable = 0;
		//#100;
		
		//enable = 1;
		//#10;
		//r_theta_original = 12'h129; // 41 at 15
		//r_theta_final = 12'h599; // 153 at 75
		//enable = 0;
		//#100;
		
		//enable = 1;
		//#10;
		//r_theta_original = 12'h599; // 153 at 75
		//r_theta_final = 12'h129; // 41 at 15
		//enable = 0;
		//#100;
		
		// test some arbitrary angles in each quadrant
		
		// 45 movement in Q2 to make sure it works in Q2 move as well
		enable = 1;
		#10;
		r_theta_original = 12'hB25; // 37 at 165
		r_theta_final = 12'h725; // 37 at 105
		enable = 0;
		#150;
		// shoudl report out 9
				
		// 105 = 75
		enable = 1;
		#10;
		r_theta_original = 12'h13A; // 58 at 15
		r_theta_final = 12'h343; // 67 at 45
		enable = 0;
		#150;
		// shoudl report out 7
		
		// 195 = 15
		enable = 1;
		#10;
		r_theta_original = 12'h395; // 149 at 45
		r_theta_final = 12'h556; // 86 at 9075
		enable = 0;
		#150;
		// shoudl report out 13
		
		// 330 = 30
		enable = 1;
		#10;
		r_theta_original = 12'h52c; // 44 at 75
		r_theta_final = 12'h13c; // 60 at 15
		enable = 0;
		#150;
		// shoudl report out 22
		
		// 60
		enable = 1;
		#10;
		r_theta_original = 12'h122; // 34 at 15
		r_theta_final = 12'h35d; // 93 at 45
		enable = 0;
		#150;
		// shoudl report out 4

	end
      
endmodule

