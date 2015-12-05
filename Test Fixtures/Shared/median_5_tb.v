`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:20:39 12/05/2015
// Design Name:   median_5
// Module Name:   /afs/athena.mit.edu/user/p/l/plancher/Desktop/6.111-Final-Project/Test Fixtures/Shared//median_5_tb.v
// Project Name:  Main_FPGA
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: median_5
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module median_5_tb;

	// Inputs
	reg [7:0] data1;
	reg [7:0] data2;
	reg [7:0] data3;
	reg [7:0] data4;
	reg [7:0] data5;
	reg clock;
	reg reset;
	reg enable;

	// Outputs
	wire done;
	wire [7:0] median;

	// Instantiate the Unit Under Test (UUT)
	median_5 uut (
		.data1(data1), 
		.data2(data2), 
		.data3(data3), 
		.data4(data4), 
		.data5(data5), 
		.clock(clock), 
		.reset(reset), 
		.enable(enable),
		.done(done), 
		.median(median)
	);
	always #5 clock = !clock;
	initial begin
		// Initialize Inputs
		data1 = 0;
		data2 = 0;
		data3 = 0;
		data4 = 0;
		data5 = 0;
		clock = 0;
		reset = 0;
		enable = 0;

		// Wait 100 ns for global reset to finish
		#100;
		reset = 1;
		#10;
		reset = 0;
        
		// Add stimulus here
		data1 = 7;
		data2 = 14;
		data3 = 0;
		data4 = 45;
		data5 = 20;
		enable = 1;
		#10;
		enable = 0;
		#20;
		
		data1 = 7;
		data2 = 14;
		data3 = 0;
		data4 = 3;
		data5 = 20;
		enable = 1;
		#10;
		enable = 0;
		#20;
		
		data1 = 255;
		data2 = 14;
		data3 = 255;
		data4 = 3;
		data5 = 255;
		enable = 1;
		#10;
		enable = 0;
		#20;

	end
      
endmodule

