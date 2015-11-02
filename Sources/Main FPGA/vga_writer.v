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
   input vclock,				// 65MHz clock
   input reset,					// 1 to initialize module
   input [11:0] location,		// input location of the Rover
   input [11:0] move_command,  	// move command to the rover (if applicable)
   input [5:0] orientation,		// orientation of the rover
   input [3:0] target_location, // location of the target based on switches
   input new_data,				// ready to re-draw and use the new location
   input [3:0] pspeed,  		// puck speed in pixels/tick 
   input [10:0] hcount,			// horizontal index of current pixel (0..1023)
   input [9:0] 	vcount, 		// vertical index of current pixel (0..767)
   input hsync,					// XVGA horizontal sync signal (active low)
   input vsync,					// XVGA vertical sync signal (active low)
   input blank,					// XVGA blanking (1 means output black pixel)
 	
   output phsync,				// output horizontal sync
   output pvsync,				// output vertical sync
   output pblank,				// output blanking
   output [23:0] pixel			// output pixel  // r=23:16, g=15:8, b=7:0 
   );

   assign phsync = hsync;
   assign pvsync = vsync;
   assign pblank = blank;
   
   // UPDATE THE BELOW FROM PONG TO THE LOGIC FOR OUR DISPLAY!!!!!!
   
   
	
	// define parameters to work with starting with shape sizes and colors
	parameter TOTAL_WIDTH = 1024;
	parameter TOTAL_HEIGHT = 768;
	parameter PUCK_WIDTH = 64;
	parameter PUCK_HEIGHT = 64;
	parameter PUCK_COLOR = 24'hFF_FF_FF;
	parameter PADDLE_WIDTH = 16;
	parameter PADDLE_HEIGHT = 128;
	parameter PADDLE_COLOR = 24'hFF_FF_FF;
	parameter FALSE = 1'b0;
	parameter TRUE = 1'b1;
	// then define movement boundaries and defaults for paddle
	parameter PADDLE_MOVE = 4;
	parameter PADDLE_MAX_Y = TOTAL_HEIGHT - PADDLE_HEIGHT - PADDLE_MOVE;
	parameter PADDLE_MIN_Y = PADDLE_MOVE;
	parameter PADDLE_START_Y = (TOTAL_HEIGHT-PADDLE_HEIGHT)/2;
	parameter PADDLE_START_X = 0;
	// define movement boundaries and defaults for puck
	parameter PUCK_START_X = (TOTAL_WIDTH-PUCK_WIDTH)/2;
	parameter PUCK_START_Y = (TOTAL_HEIGHT-PUCK_HEIGHT)/2;
	parameter PUCK_UP = 1'b0;
	parameter PUCK_DOWN = 1'b1;
	parameter PUCK_LEFT = 1'b0;
	parameter PUCK_RIGHT = 1'b1;
	//define the parameters for the center alpha bender square
	parameter SQUARE_HEIGHT = 128;
	parameter SQUARE_WIDTH = 128;
	parameter SQUARE_X = (TOTAL_WIDTH-SQUARE_WIDTH)/2;
	parameter SQUARE_Y = (TOTAL_HEIGHT-SQUARE_HEIGHT)/2;
	parameter SQUARE_COLOR = 24'hFF_00_00;
		
	// define variables needed for the puck and paddle sprites and movement
	reg [9:0] paddle_x;
	reg [9:0] paddle_y;
	reg [9:0] puck_x;
	reg [9:0] puck_y;
	reg puck_x_vel; 
	reg puck_y_vel;
	reg lost;
	wire [23:0] paddle_pixel;
	wire [23:0] puck_pixel;
	wire [23:0] square_pixel;
	wire [23:0] alpha_bend_pixel;
	wire [7:0] alpha_bend_R;
	wire [7:0] alpha_bend_G;
	wire [7:0] alpha_bend_B;
	wire [23:0] paddle_square_pixel;
	
	wire up;
	wire down;
	// every time we go into sync to refresh the screen update the positions for next screen
	always @(posedge vsync) begin
		// if reset update shapes to starting position
		if (reset) begin
			paddle_y <= PADDLE_START_Y;
			paddle_x <= PADDLE_START_X;
			puck_x <= PUCK_START_X;
			puck_y <= PUCK_START_Y;
			puck_x_vel <= PUCK_RIGHT;
			puck_y_vel <= PUCK_UP;
			lost <= FALSE;
		end
		// if in the losing state freeze everything else we can move stuff around!
		else if (lost == FALSE) begin
			// if we get a paddle move and can execute without going off screen do it
			if (down && PADDLE_MAX_Y > paddle_y) begin
				paddle_y <= paddle_y + PADDLE_MOVE;
			end
			else if (up && paddle_y > PADDLE_MIN_Y) begin
				paddle_y <= paddle_y - PADDLE_MOVE;
			end
			// puck always needs to move unless it hits boundary if moving down
			if (puck_y_vel == PUCK_DOWN) begin
				if(TOTAL_HEIGHT - PUCK_HEIGHT - pspeed > puck_y) begin
					puck_y <= puck_y + pspeed;
				end
				else begin
					puck_y_vel <= PUCK_UP;
				end
			end
			// puck always needs to move unless it hits boundary if moving up
			if (puck_y_vel == PUCK_UP) begin
				if(puck_y > pspeed) begin
					puck_y <= puck_y - pspeed;
				end
				else begin
					puck_y_vel <= PUCK_DOWN;
				end
			end
			// puck always needs to move unless it hits boundary if moving right
			if (puck_x_vel == PUCK_RIGHT) begin
				if (TOTAL_WIDTH - PUCK_WIDTH - pspeed > puck_x) begin
					puck_x <= puck_x + pspeed;
				end
				else begin
					puck_x_vel <= PUCK_LEFT;
				end
			end
			// If moving left puck needs to move until it either hits the paddle
			// or the game is over because it reached the boundary
			if (puck_x_vel == PUCK_LEFT) begin
				// if off to the right safe to move left
				if (puck_x > pspeed + PADDLE_WIDTH) begin
					puck_x <= puck_x - pspeed;
				end
				// if it will hit the paddle in vertical constraints then bounce
				else if (puck_y+PUCK_HEIGHT > paddle_y && puck_y < paddle_y + PADDLE_HEIGHT) begin
					puck_x_vel <= PUCK_RIGHT;
				end
				// else we will hit the edge so we lose
				else begin
					puck_x <= 0;
					lost <= TRUE;
				end
			end
		end
	end
	
	// instantiate a puck, paddle, and square sprite
	blob #(.WIDTH(PUCK_WIDTH),.HEIGHT(PUCK_HEIGHT),.COLOR(PUCK_COLOR))
		  puck(.x(puck_x),.y(puck_y),.hcount(hcount),.vcount(vcount),.pixel(puck_pixel));
	blob #(.WIDTH(PADDLE_WIDTH),.HEIGHT(PADDLE_HEIGHT),.COLOR(PADDLE_COLOR))
		  paddle(.x(paddle_x),.y(paddle_y),.hcount(hcount),.vcount(vcount),.pixel(paddle_pixel));
	blob #(.WIDTH(SQUARE_WIDTH),.HEIGHT(SQUARE_HEIGHT),.COLOR(SQUARE_COLOR))
		  square(.x(SQUARE_X),.y(SQUARE_Y),.hcount(hcount),.vcount(vcount),.pixel(square_pixel));
		  
	// compute the alpha bend of puck and square
	parameter ALPHA_M = 1;
	parameter ALPHA_N = 4;
	parameter ALPHA_N_LOG_2 = 2;
	assign alpha_bend_R = ((puck_pixel[23:16]*ALPHA_M)>>ALPHA_N_LOG_2) + 
	                           ((square_pixel[23:16]*(ALPHA_N-ALPHA_M))>>ALPHA_N_LOG_2);
	assign alpha_bend_G = ((puck_pixel[15:8]*ALPHA_M)>>ALPHA_N_LOG_2) + 
	                           ((square_pixel[15:8]*(ALPHA_N-ALPHA_M))>>ALPHA_N_LOG_2);
	assign alpha_bend_B = ((puck_pixel[7:0]*ALPHA_M)>>ALPHA_N_LOG_2) +
	                           ((square_pixel[7:0]*(ALPHA_N-ALPHA_M))>>ALPHA_N_LOG_2);
	assign alpha_bend_pixel = {alpha_bend_R, alpha_bend_G, alpha_bend_B};
	
	// show either the alpha blend or both if they don't overlap
	assign paddle_square_pixel = (puck_pixel & square_pixel > 0) ? alpha_bend_pixel : (square_pixel | puck_pixel);
	assign pixel = paddle_pixel | paddle_square_pixel;
	
endmodule