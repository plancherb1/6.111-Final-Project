`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   18:43:07 11/19/2015
// Design Name:   median_3
// Module Name:   /afs/athena.mit.edu/user/p/l/plancher/Desktop/6.111-Final-Project/Main_FPGA/median_3_tb.v
// Project Name:  Main_FPGA
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: median_3
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module median_3_tb;

	// Inputs
	reg reset;
	reg [19:0] data1;
	reg [19:0] data2;
	reg [19:0] data3;

	// Outputs
	wire [19:0] median;

	// Instantiate the Unit Under Test (UUT)
	median_3 uut (
		.data1(data1), 
		.data2(data2), 
		.data3(data3), 
		.median(median)
	);

	initial begin
		// Initialize Inputs
		data1 = 0;
		data2 = 0;
		data3 = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		data1 = 1;
		data2 = 5;
		data3 = 10;
		#10; // median should be 5 as 1<2<3
		
		data1 = 7;
		#10; // median should be 7 as 2<1<3
		
		data3 = 6;
		#10; // median should be 6 as 2<3<1
		
		data2 = 11;
		#10; // median should be 7 as 3<1<2
		
		data1 = 1;
		#10; // median should be 5 as 1<3<2
		
		data1 = 20;
		#10; // median should be 11 as 3<2<1
		
	end
      
endmodule

