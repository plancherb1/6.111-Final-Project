`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   23:26:23 11/16/2015
// Design Name:   vga_writer
// Module Name:   /afs/athena.mit.edu/user/p/l/plancher/Desktop/6.111-Final-Project/Test Fixtures/Main FPGA//vga_writer_tb.v
// Project Name:  Main_FPGA
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: vga_writer
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module vga_writer_tb;

	// Inputs
	reg vclock;
	reg reset;
	reg [11:0] location;
	reg [11:0] move_command;
	reg [3:0] orientation;
	reg [3:0] target_location;
	reg new_data;
	reg orientation_ready;
	reg [10:0] hcount;
	reg [9:0] vcount;
	reg hsync;
	reg vsync;
	reg blank;

	// Outputs
	wire phsync;
	wire pvsync;
	wire pblank;
	wire analyzer_clock;
	wire [15:0] analyzer_data;
	wire [23:0] pixel;

	// Instantiate the Unit Under Test (UUT)
	vga_writer uut (
		.vclock(vclock), 
		.reset(reset), 
		.location(location), 
		.move_command(move_command), 
		.orientation(orientation), 
		.target_location(target_location), 
		.new_data(new_data), 
		.orientation_ready(orientation_ready), 
		.hcount(hcount), 
		.vcount(vcount), 
		.hsync(hsync), 
		.vsync(vsync), 
		.blank(blank), 
		.phsync(phsync), 
		.pvsync(pvsync), 
		.pblank(pblank), 
		.analyzer_clock(analyzer_clock), 
		.analyzer_data(analyzer_data), 
		.pixel(pixel)
	);
	
	integer i;
	
	always #5 vsync = !vsync;
	initial begin
		// Initialize Inputs
		vclock = 0;
		reset = 0;
		location = 0;
		move_command = 0;
		orientation = 0;
		target_location = 0;
		new_data = 0;
		orientation_ready = 0;
		hcount = 0;
		vcount = 0;
		hsync = 0;
		vsync = 0;
		blank = 0;

		// Wait 100 ns for global reset to finish
		#100;
      
		// hard reset
		reset = 1;
		#10;
		reset = 0;
		
		// Add stimulus here
		// test the target and see where it shows up which should be
		// for 16 around 512
		hcount = 512;
		for (i=0; i<768; i=i+1) begin
         vcount = i;
         #10;
      end

		
		// lets test the grid pixel and look for FF_00_00 for the pixel (only have gird hooked up)
		//vcount = 100;
		//#100;
		//vcount = 1023;
		//#100;
		//vcount = 1000;
		//#100;
		//vcount = 0;
		
	end
      
endmodule

