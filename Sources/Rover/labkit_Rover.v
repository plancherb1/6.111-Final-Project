`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// 
// Create Date: 10/1/2015 V1.0
// Design Name: 
// Module Name: labkit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module labkit(
   input CLK100MHZ,
   input[15:0] SW, 
   input BTNC, BTNU, BTNL, BTNR, BTND,
   output[3:0] VGA_R, 
   output[3:0] VGA_B, 
   output[3:0] VGA_G,
   output[7:0] JA, 
   output VGA_HS, 
   output VGA_VS, 
   output[15:0] LED,
   output[7:0] SEG,  // segments A-G (0-6), DP (7)
   output[7:0] AN    // Display 0-7
   );
   

//////////////////////////////////////////////////////////////////////////////////
// create 25mhz system clock

    wire clock_25mhz;
    clock_quarter_divider clockgen(.clk100_mhz(CLK100MHZ), .clock_25mhz(clock_25mhz));

//////////////////////////////////////////////////////////////////////////////////
// debounce and synchronize all switches and buttons
    
    wire [15:0] db_SW;
    wire db_BTNC;
    wire db_BTNU;
    wire db_BTNL;
    wire db_BTNR;
    wire db_BTND;
	synchronize dbsw15 (.clk(clock_25mhz), .in(SW[1]), .out(db_SW[1]));
	synchronize dbsw15 (.clk(clock_25mhz), .in(SW[2]), .out(db_SW[2]));
	synchronize dbsw15 (.clk(clock_25mhz), .in(SW[3]), .out(db_SW[3]));
	synchronize dbsw15 (.clk(clock_25mhz), .in(SW[4]), .out(db_SW[4]));
	synchronize dbsw15 (.clk(clock_25mhz), .in(SW[5]), .out(db_SW[5]));
	synchronize dbsw15 (.clk(clock_25mhz), .in(SW[6]), .out(db_SW[6]));
	synchronize dbsw15 (.clk(clock_25mhz), .in(SW[7]), .out(db_SW[7]));
	synchronize dbsw15 (.clk(clock_25mhz), .in(SW[8]), .out(db_SW[8]));
    synchronize dbsw15 (.clk(clock_25mhz), .in(SW[9]), .out(db_SW[9]));
	synchronize dbsw15 (.clk(clock_25mhz), .in(SW[10]), .out(db_SW[10]));
	synchronize dbsw15 (.clk(clock_25mhz), .in(SW[11]), .out(db_SW[11]));
	synchronize dbsw15 (.clk(clock_25mhz), .in(SW[12]), .out(db_SW[12]));
	synchronize dbsw15 (.clk(clock_25mhz), .in(SW[13]), .out(db_SW[13]));
	synchronize dbsw15 (.clk(clock_25mhz), .in(SW[14]), .out(db_SW[14]));
	synchronize dbsw15 (.clk(clock_25mhz), .in(SW[15]), .out(db_SW[15]));
    debounce dbbtnc #(.DELAY(250000))(.reset(db_SW[15]), .clock(clock_25mhz), .noisy(BTNC), .clean(db_BTNC));
    debounce dbbtnu #(.DELAY(250000))(.reset(db_SW[15]), .clock(clock_25mhz), .noisy(BTNU), .clean(db_BTNU));
    debounce dbbtnl #(.DELAY(250000))(.reset(db_SW[15]), .clock(clock_25mhz), .noisy(BTNL), .clean(db_BTNL));
    debounce dbbtnr #(.DELAY(250000))(.reset(db_SW[15]), .clock(clock_25mhz), .noisy(BTNR), .clean(db_BTNR));
    debounce dbbtnd #(.DELAY(250000))(.reset(db_SW[15]), .clock(clock_25mhz), .noisy(BTND), .clean(db_BTND));
	// assign reset
	wire reset;
	assign reset = db_SW[15];
    
//////////////////////////////////////////////////////////////////////////////////
   
	wire ir_in;
	// link it to something assign ir_in = X;
	wire motor_l;
	// link it to something assign motor_l = X;
	wire motor_r;
	// link it to something assign motor_r = X;
	wire [3:0] state;
	wire move_ready;
	wire [11:0] move_data;
	
	// link up the IR Receiver to the Motor Control
	ir_receiver ir1(.clock(clock_25mhz,.reset(reset),.data_in(ir_in),.done(move_ready),
					.move_data(move_data),.state(state));
	motor_signal_stream mss1(.clock(clock_25mhz),.reset(reset),.command_ready(move_ready),
							 .command(move_data),.motor_l(motor_l),.motor_r(motor_r));
	
    //  instantiate 7-segment display; use for debugging
    wire [31:0] data = {32'hfff};
    wire [7:0] segments;
    display_8hex_nexys4 display(.clk(clock_25mhz),.data(data), .seg(segments), .strobe(AN));     // digit strobe
    assign SEG[7:0] = segments;
    
//////////////////////////////////////////////////////////////////////////////////
// sample Verilog to generate color bars 
    
    wire [9:0] hcount;
    wire [9:0] vcount;
    wire hsync, vsync, at_display_area;
    vga vga1(.vga_clock(clock_25mhz),.hcount(hcount),.vcount(vcount),
          .hsync(hsync),.vsync(vsync),.at_display_area(at_display_area));
        
    assign VGA_R = at_display_area ? {4{hcount[7]}} : 0;
    assign VGA_G = at_display_area ? {4{hcount[6]}} : 0;
    assign VGA_B = at_display_area ? {4{hcount[5]}} : 0;
    assign VGA_HS = ~hsync;
    assign VGA_VS = ~vsync;
endmodule

module clock_quarter_divider(input clk100_mhz, output reg clock_25mhz = 0);
    reg counter = 0;
    
    always @(posedge clk100_mhz) begin
        counter <= counter + 1;
        if (counter == 0) begin
            clock_25mhz <= ~clock_25mhz;
        end
    end
endmodule

module vga(input vga_clock,
            output reg [9:0] hcount = 0,    // pixel number on current line
            output reg [9:0] vcount = 0,	 // line number
            output vsync, hsync, at_display_area);
    // Counters.
    always @(posedge vga_clock) begin
        if (hcount == 799) begin
            hcount <= 0;
        end
        else begin
            hcount <= hcount +  1;
        end
        if (vcount == 524) begin
            vcount <= 0;
        end
        else if(hcount == 799) begin
            vcount <= vcount + 1;
        end
    end
    
    assign hsync = (hcount < 96);
    assign vsync = (vcount < 2);
    assign at_display_area = (hcount >= 144 && hcount < 784 && vcount >= 35 && vcount < 515);
endmodule

