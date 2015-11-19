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
   input [3:0] orientation,		// orientation of the rover
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
	output analyzer_clock,			// debug only
	output [15:0] analyzer_data,	// debug only
   output [23:0] pixel				// output pixel  // r=23:16, g=15:8, b=7:0 
   );

   assign phsync = hsync;
   assign pvsync = vsync;
   assign pblank = blank;
   
   // turn hcount and vcount into x,y for easier analysis
   parameter TOTAL_WIDTH = 1024;
	parameter TOTAL_HEIGHT = 768;
   wire signed [11:0] x_value;
   wire signed [11:0] y_value;
   assign x_value = hcount - TOTAL_WIDTH/2;
   assign y_value = TOTAL_HEIGHT - vcount;
   
   // parameters to define shapes
   parameter BLANK_COLOR = 24'h00_00_00;
   parameter GRID_COLOR = 24'hFF_00_00;
   parameter TARGET_WIDTH = 16;
	parameter TARGET_HEIGHT = 16;
	parameter TARGET_COLOR = 24'h00_00_FF;
	parameter ROVER_HEIGHT = 32;
	parameter ROVER_WIDTH = 32;
	parameter ROVER_COLOR = 24'h00_FF_00;
	parameter ROVER_ORIENTED_COLOR = 24'hFF_FF_00;
	parameter PIXEL_ALL_1S = 24'hFF_FF_FF;
	// and the grid
	parameter GRID_LINE_WIDTH = 1;
	parameter GRID_HEIGHT = 256;
	parameter GRID_WIDTH = 512;
	parameter GRID_RIGHT_BORDER = (TOTAL_WIDTH-GRID_WIDTH)/2;
	parameter GRID_LEFT_BORDER = -1*GRID_RIGHT_BORDER;
	parameter GRID_BOTTOM_BORDER = (TOTAL_HEIGHT-GRID_HEIGHT)/2;
	parameter GRID_TOP_BORDER = TOTAL_HEIGHT - GRID_BOTTOM_BORDER;
   
   // display the target and rover based on the location
   reg signed [11:0] target_x;
   reg signed [11:0] target_y;
   reg signed [11:0] rover_x;
   reg signed [11:0] rover_y;
   wire signed [8:0] temp_rover_x;
   wire signed [8:0] temp_rover_y;
	wire signed [11:0] sized_temp_rover_x;
	wire signed [11:0] sized_temp_rover_y;
   
   // instantiate the helper module with continuous translation of rover (r,theta) to (x,y)
   polar_to_cartesian ptc (.r_theta(location),.x_value(temp_rover_x),.y_value(temp_rover_y));
   assign sized_temp_rover_x = {temp_rover_x[8],temp_rover_x[8],temp_rover_x[8],temp_rover_x};
	assign sized_temp_rover_y = {temp_rover_y[8],temp_rover_y[8],temp_rover_y[8],temp_rover_y};
	
	// for debug
	//assign analyzer_clock = vsync;
	//assign analyzer_data = {rover_x[7:0],rover_y[7:0]};
	
	// scaling factor is how big we make the distance between each arc
	// we default to 2 but can change it according to the rover and target location
	// that is, the rover and target need to be in the grid so therefore scale is the
	// min(GRID_HEIGHT/absmax(target_y, rover_y),GRID_WIDTH/absmax(target_x,rover_x))
	reg signed [11:0] max_x;
	reg signed [11:0] max_y;
	// helper function for abs_max needed here
	wire [2:0] scale_factor;
	assign scale_factor = 2;
	
   // only actually update the position every screen refresh for both the target and the rover
   always @(posedge vsync) begin
      // when we reset move the rover off of the screen and wait for ultrasound to update
      if (reset) begin
         rover_x <= 0;
         rover_y <= GRID_BOTTOM_BORDER;
			target_x <= 0;
			target_y <= GRID_TOP_BORDER;
      end
      // else for the location of the "Rover" we only update when we have valid new information
      else if (new_data | orientation_ready) begin
         // save the updated rover location
         rover_x <= sized_temp_rover_x * scale_factor;
         rover_y <= (sized_temp_rover_y * scale_factor) + GRID_BOTTOM_BORDER;
			
			// scaling?
			
      end
      // in all cases target assign location based on the switches (defines center) 
      // Note: these are hard coded for various test values
      //case(target_location)
      //   4'h1: {target_x,target_y} <= {140,50};
      //   4'h2: {target_x,target_y} <= {-240,500};
      //   4'h3: {target_x,target_y} <= {-440,400};
      //   4'h4: {target_x,target_y} <= {340,100};
      //   4'h5: {target_x,target_y} <= {50,700};
      //   4'h6: {target_x,target_y} <= {110,300};
      //   4'h7: {target_x,target_y} <= {-110,300};
      //   default: {target_x,target_y} <= {440,200};
      //endcase
   end
   
   // instantiate the grid
   wire [23:0] grid_pixel;
   grid 	#(.GRID_COLOR(GRID_COLOR),.BLANK_COLOR(BLANK_COLOR), 
			  .BOTTOM_BORDER(GRID_BOTTOM_BORDER),.TOP_BORDER(GRID_TOP_BORDER),
			  .LEFT_BORDER(GRID_LEFT_BORDER),.RIGHT_BORDER(GRID_RIGHT_BORDER),
			  .LINE_WIDTH(GRID_LINE_WIDTH))
		grid(.x_value(x_value),.y_value(y_value),.pixel(grid_pixel));
   
   // instantiate the target
   wire [23:0] target_pixel;
	blob #(.WIDTH(TARGET_WIDTH),.HEIGHT(TARGET_HEIGHT),.COLOR(TARGET_COLOR),.BLANK_COLOR(BLANK_COLOR))
		  target(.x(target_x),.y(target_y),.x_value(x_value),.y_value(y_value),.pixel(target_pixel));
   
   // instantiate the square rover
   wire [23:0] rover_pixel_s;
   blob #(.WIDTH(ROVER_WIDTH),.HEIGHT(ROVER_HEIGHT),.COLOR(ROVER_COLOR),.BLANK_COLOR(BLANK_COLOR))
		  rover_s(.x(rover_x),.y(rover_y),.x_value(x_value),.y_value(y_value),.pixel(rover_pixel_s));
   
   //instantiate the triangle rover
   wire [23:0] rover_pixel_t;
   triangle #(.WIDTH(ROVER_WIDTH),.HEIGHT(ROVER_HEIGHT),.COLOR(ROVER_ORIENTED_COLOR),
				  .BLANK_COLOR(BLANK_COLOR),.INDICATOR_COLOR(ROVER_COLOR))
		  rover_t(.center_x(rover_x),.center_y(rover_y),.x_value(x_value),.y_value(y_value),.pixel(rover_pixel_t),
					 .orientation(orientation));
        
   // use the appropriate rover
	wire [23:0] rover_pixel;
   assign rover_pixel = rover_pixel_t; //orientation_ready ? rover_pixel_t : rover_pixel_s;
   
   // compute the alpha blend of the rover and the target
   // show either the alpha blend or both if they don't overlap
	parameter ALPHA_M = 2;
	parameter ALPHA_N = 4;
	parameter ALPHA_N_LOG_2 = 2;
   wire [7:0] alpha_blend_R;
   wire [7:0] alpha_blend_G;
   wire [7:0] alpha_blend_B;
   wire [23:0] alpha_blend_pixel;
   wire [23:0] overlap_pixel;
	assign alpha_blend_R = ((rover_pixel[23:16]*ALPHA_M)>>ALPHA_N_LOG_2) + 
	                           ((target_pixel[23:16]*(ALPHA_N-ALPHA_M))>>ALPHA_N_LOG_2);
	assign alpha_blend_G = ((rover_pixel[15:8]*ALPHA_M)>>ALPHA_N_LOG_2) + 
	                           ((target_pixel[15:8]*(ALPHA_N-ALPHA_M))>>ALPHA_N_LOG_2);
	assign alpha_blend_B = ((rover_pixel[7:0]*ALPHA_M)>>ALPHA_N_LOG_2) +
	                           ((target_pixel[7:0]*(ALPHA_N-ALPHA_M))>>ALPHA_N_LOG_2);
   assign alpha_blend_pixel = {alpha_blend_R, alpha_blend_G, alpha_blend_B};
	assign overlap_pixel = ((rover_pixel & target_pixel) > 0) ? alpha_blend_pixel : (rover_pixel | target_pixel);
   
   // overall show the overlap pixel or the grid underneath it if applicable
   assign pixel = ((overlap_pixel & PIXEL_ALL_1S) > 0) ? overlap_pixel : grid_pixel;
	
endmodule
