`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        MIT 6.111 Final Project
// Engineer:       Brian Plancher
// 
// Module Name:    VGA Writer
// Project Name:   FPGA Phone Home
//
// Notes: Based on Pong Game Logic
//////////////////////////////////////////////////////////////////////////////////
module vga_writer (
   input vclock,						// 65MHz clock
   input reset,						// 1 to initialize module
   input [11:0] location,		// input location of the Rover
   input [11:0] move_command,  // move command to the rover (if applicable)
   input [4:0] orientation,		// orientation of the rover
   input [3:0] target_location,// location of the target based on switches
   input new_data,					// ready to re-draw and use the new location
   input orientation_ready,   	// ready to draw the orientation
   input [10:0] hcount,			// horizontal index of current pixel (0..1023)
   input [9:0]  vcount, 			// vertical index of current pixel (0..767)
   input hsync,						// XVGA horizontal sync signal (active low)
   input vsync,						// XVGA vertical sync signal (active low)
   input blank,						// XVGA blanking (1 means output black pixel)
   output phsync,					// output horizontal sync
   output pvsync,					// output vertical sync
   output pblank,					// output blanking
	//output analyzer_clock,			// debug only
	//output [15:0] analyzer_data,	// debug only
   output reg [23:0] pixel		// output pixel  // r=23:16, g=15:8, b=7:0 
   );
	
	// we need to delay hxync, vsync, and blank by the same amount as our
	// total pipeline time below
	parameter PIPELINE_LENGTH = 5;
	delayN #(.NDELAY(PIPELINE_LENGTH)) hdelay (.clk(vclock),.in(hsync),.out(phsync));
	delayN #(.NDELAY(PIPELINE_LENGTH)) vdelay (.clk(vclock),.in(vsync),.out(pvsync));
	delayN #(.NDELAY(PIPELINE_LENGTH)) bdelay (.clk(vclock),.in(blank),.out(pblank));
   
   // turn hcount and vcount into x,y for easier analysis
   parameter TOTAL_WIDTH = 1024;
	parameter TOTAL_HEIGHT = 768;
   wire signed [11:0] x_value;
   wire signed [11:0] y_value;
   assign x_value = hcount - TOTAL_WIDTH/2;
   assign y_value = TOTAL_HEIGHT - vcount;
   
   // parameters to define shapes
   parameter BLANK_COLOR = 24'h00_00_00;
   parameter GRID_COLOR = 24'hFF_FF_FF;
   parameter TARGET_WIDTH = 16;
	parameter TARGET_HEIGHT = 16;
	parameter TARGET_COLOR = 24'h00_FF_00;
	parameter ROVER_HEIGHT = 16;
	parameter ROVER_WIDTH = 16;
	parameter ROVER_COLOR = 24'hFF_00_00;
	parameter ROVER_ORIENTED_COLOR = 24'h00_00_FF;
	// and the grid
	parameter GRID_LINE_WIDTH = 1;
	parameter GRID_HEIGHT = 256;
	parameter GRID_WIDTH = 512;
	parameter GRID_RIGHT_BORDER = (TOTAL_WIDTH-GRID_WIDTH)/2;
	parameter GRID_LEFT_BORDER = -1*GRID_RIGHT_BORDER;
	parameter GRID_BOTTOM_BORDER = (TOTAL_HEIGHT-GRID_HEIGHT)/2;
	parameter GRID_TOP_BORDER = TOTAL_HEIGHT - GRID_BOTTOM_BORDER;
   
   // for debug
	//assign analyzer_clock = vsync;
	//assign analyzer_data = {rover_x[7:0],rover_y[7:0]};
   
   // helpers for the rover and target position update on VSYNC
   reg signed [11:0] target_x;
   reg signed [11:0] target_y;
   reg signed [11:0] rover_x;
   reg signed [11:0] rover_y;
   wire signed [8:0] temp_rover_x;
   wire signed [8:0] temp_rover_y;
	wire signed [11:0] sized_temp_rover_x;
	wire signed [11:0] sized_temp_rover_y;
   // helper to compute the polar to cartesian
   polar_to_cartesian ptc (.r_theta(location),.x_value(temp_rover_x),.y_value(temp_rover_y));
   assign sized_temp_rover_x = {temp_rover_x[8],temp_rover_x[8],temp_rover_x[8],temp_rover_x};
	assign sized_temp_rover_y = {temp_rover_y[8],temp_rover_y[8],temp_rover_y[8],temp_rover_y};
   // scaling factor is how big we make the distance between each arc
	// we default to 2 but can change it according to the rover and target location
	// that is, the rover and target need to be in the grid so therefore scale is the
	// min(GRID_HEIGHT/absmax(target_y, rover_y),GRID_WIDTH/absmax(target_x,rover_x))
	reg signed [11:0] max_x;
	reg signed [11:0] max_y;
	// helper function for abs_max needed here
	wire [2:0] scale_factor;
	assign scale_factor = 10;
   
   // instantiate the grid
   wire [23:0] grid_pixel;
   grid 	#(.GRID_COLOR(GRID_COLOR),.BLANK_COLOR(BLANK_COLOR), 
			  .BOTTOM_BORDER(GRID_BOTTOM_BORDER),.TOP_BORDER(GRID_TOP_BORDER),
			  .LEFT_BORDER(GRID_LEFT_BORDER),.RIGHT_BORDER(GRID_RIGHT_BORDER),
			  .LINE_WIDTH(GRID_LINE_WIDTH))
		grid(.x_value(x_value),.y_value(y_value),.pixel(grid_pixel),.clock(vclock));
   
   // instantiate the target
   wire [23:0] target_pixel;
	blob #(.WIDTH(TARGET_WIDTH),.HEIGHT(TARGET_HEIGHT),.COLOR(TARGET_COLOR),.BLANK_COLOR(BLANK_COLOR))
		  target(.center_x(target_x),.center_y(target_y),.x_value(x_value),.y_value(y_value),.pixel(target_pixel));
   
   // instantiate the square rover
   wire [23:0] rover_pixel_noO;
   blob #(.WIDTH(ROVER_WIDTH),.HEIGHT(ROVER_HEIGHT),.COLOR(ROVER_COLOR),.BLANK_COLOR(BLANK_COLOR))
		  rover_noO(.center_x(rover_x),.center_y(rover_y),.x_value(x_value),.y_value(y_value),.pixel(rover_pixel_noO));
   
   //instantiate the triangle rover
   wire [23:0] rover_pixel_yesO;
   triangle #(.WIDTH(ROVER_WIDTH),.HEIGHT(ROVER_HEIGHT),.COLOR(ROVER_ORIENTED_COLOR),
				  .BLANK_COLOR(BLANK_COLOR),.INDICATOR_COLOR(ROVER_COLOR))
		  rover_yesO(.center_x(rover_x),.center_y(rover_y),.x_value(x_value),.y_value(y_value),.pixel(rover_pixel_yesO),
						 .orientation(orientation),.clock(vclock));
	
   // helpers for the delays
   reg [23:0] target_pixel2;
   reg [23:0] target_pixel3;
   reg [23:0] target_pixel4;
   reg [23:0] target_pixel5;
   reg [23:0] rover_pixel_noO2;
   reg [23:0] rover_pixel_noO3;
   reg [23:0] rover_pixel_noO4;
   reg [23:0] rover_pixel;
   reg [23:0] grid_pixel2;
   
   // helper modules for ALPHA_BLEND
   parameter ALPHA_M = 2;
   parameter ALPHA_N = 4;
   parameter ALPHA_N_LOG_2 = 2;
   wire [23:0] overlap_pixel;
   alpha_blend #(.ALPHA_M(ALPHA_M),.ALPHA_N(ALPHA_N),.ALPHA_N_LOG_2(ALPHA_N_LOG_2))
              ab(.pixel_1(rover_pixel),.pixel_2(target_pixel5),.overlap_pixel(overlap_pixel));
   
   // we then pipeline the rest of the VGA display because it takes too long to clear
   always @(posedge vclock) begin
		// when we reset move the rover off of the screen and wait for ultrasound to update
		if (reset) begin
            rover_x <= 0; 
            rover_y <= GRID_BOTTOM_BORDER;
            
            // UPDATE THESE ONCE YOU ARE DONE DEBUGGING TO THE ACTUALLY RESET POSITION---------------------
            
      end
		else begin
			// only actually update the position every screen refresh for both the target and the rover
			if (!vsync) begin
				// else for the location of the "Rover" we only update when we have valid new information
				if (new_data | orientation_ready) begin
					// save the updated rover location
					rover_x <= sized_temp_rover_x * scale_factor;
					rover_y <= (sized_temp_rover_y * scale_factor) + GRID_BOTTOM_BORDER;		
				end
				// always update the target to the state of the switches
				case(target_location[1:0])
					2'h1: target_x <= 0;
					2'h2: target_x <= GRID_LEFT_BORDER;
					2'h3: target_x <= GRID_RIGHT_BORDER;
					default: target_x <= GRID_RIGHT_BORDER/2;
				endcase
				case(target_location[3:2])
					2'h1: target_y <= (GRID_TOP_BORDER-GRID_BOTTOM_BORDER)/4 + GRID_BOTTOM_BORDER;
					2'h2: target_y <= (GRID_TOP_BORDER-GRID_BOTTOM_BORDER)/2 + GRID_BOTTOM_BORDER;
					2'h3: target_y <= GRID_TOP_BORDER;
					default: target_y <= GRID_BOTTOM_BORDER;
				endcase
				
				// UPDATE THE SCALE FACTOR ???? ----- STRETCH GOAL WOULD GO HERE USING MAXX AND MAXY
				
			end
			
			// else enter the pipelined FSM to calculate all of the correct pixel values
			else begin
				// Get the values back from the helper functions
				// grid takes 4 clock cycles so delay 1 for rover combos
				// triangle (oriented target) takes 4 clock cycles so delay 0
				// blobs (un-oriented rover and target) take 1 cycle so delay 4
				// alpha blend takes 1 clock cycle
				// final output is delayed then by 5 clock cycles
				
				// 1st clock cycle only the blobs clearrover_pixel_yesO
				rover_pixel_noO2 <= rover_pixel_noO;
				target_pixel2 <= target_pixel;
				// 2nd clock cylce still only the blobs clear so delay again
				rover_pixel_noO3 <= rover_pixel_noO2;
				target_pixel3 <= target_pixel2;
            // 3rd clock cycle still only the blobs clear so delay again
            rover_pixel_noO4 <= rover_pixel_noO3;
            target_pixel4 <= target_pixel3;
				// 4th clock cycle create rover pixel and delay target once more as triangle cleared and delay grid 1
				rover_pixel <= orientation_ready ? rover_pixel_yesO : rover_pixel_noO4;
				target_pixel5 <= target_pixel4;
            grid_pixel2 <= grid_pixel;
				// 5th clock cycle alpha blend and display the grid as alpha blend is 1 cycle and grid is now done
				pixel <= |overlap_pixel ? overlap_pixel : grid_pixel2;
			end
		end
   end
   
endmodule
