`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   16:13:10 12/05/2015
// Design Name:   mid3_of5
// Module Name:   /afs/athena.mit.edu/user/p/l/plancher/Desktop/6.111-Final-Project/Main_FPGA/mid3_of5_tb.v
// Project Name:  Main_FPGA
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: mid3_of5
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module mid3_of5_tb;

	// Inputs
	reg [7:0] data1;
	reg [7:0] data2;
	reg [7:0] data3;
	reg [7:0] data4;
	reg [7:0] data5;

	// Outputs
	wire [7:0] mid1;
	wire [7:0] mid2;
	wire [7:0] mid3;

	// Instantiate the Unit Under Test (UUT)
	mid3_of5 uut (
		.data1(data1), 
		.data2(data2), 
		.data3(data3), 
		.data4(data4), 
		.data5(data5), 
		.mid1(mid1), 
		.mid2(mid2), 
		.mid3(mid3)
	);

	initial begin
		// Initialize Inputs
		data1 = 0;
		data2 = 0;
		data3 = 0;
		data4 = 0;
		data5 = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		data1 = 1;
		data2 = 2;
		data3 = 3;
		data4 = 4;
		data5 = 5;
		#10;
		data1 = 2;
		data2 = 1;
		data3 = 3;
		data4 = 4;
		data5 = 5;
		#10;
		data1 = 2;
		data2 = 3;
		data3 = 1;
		data4 = 4;
		data5 = 5;
		#10;
		data1 = 2;
		data2 = 3;
		data3 = 4;
		data4 = 1;
		data5 = 5;
		#10;
		data1 = 2;
		data2 = 3;
		data3 = 4;
		data4 = 5;
		data5 = 1;
		#10;
		data1 = 1;
		data2 = 3;
		data3 = 2;
		data4 = 4;
		data5 = 5;
		#10;
		data1 = 1;
		data2 = 3;
		data3 = 4;
		data4 = 2;
		data5 = 5;
		#10;
		data1 = 1;
		data2 = 3;
		data3 = 4;
		data4 = 5;
		data5 = 2;
		#10;
		data1 = 1;
		data2 = 2;
		data3 = 4;
		data4 = 3;
		data5 = 5;
		#10;
		data1 = 1;
		data2 = 2;
		data3 = 4;
		data4 = 5;
		data5 = 3;
		#10;
		data1 = 1;
		data2 = 2;
		data3 = 3;
		data4 = 5;
		data5 = 4;
		#10;
	end
      
endmodule

