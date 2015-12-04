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
   inout[7:0] JA, 
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
    synchronize dbsw0 (.clk(clock_25mhz), .in(SW[0]), .out(db_SW[0]));
	synchronize dbsw1 (.clk(clock_25mhz), .in(SW[1]), .out(db_SW[1]));
	synchronize dbsw2 (.clk(clock_25mhz), .in(SW[2]), .out(db_SW[2]));
	synchronize dbsw3 (.clk(clock_25mhz), .in(SW[3]), .out(db_SW[3]));
	synchronize dbsw4 (.clk(clock_25mhz), .in(SW[4]), .out(db_SW[4]));
	synchronize dbsw5 (.clk(clock_25mhz), .in(SW[5]), .out(db_SW[5]));
	synchronize dbsw6 (.clk(clock_25mhz), .in(SW[6]), .out(db_SW[6]));
	synchronize dbsw7 (.clk(clock_25mhz), .in(SW[7]), .out(db_SW[7]));
	//synchronize dbsw8 (.clk(clock_25mhz), .in(SW[8]), .out(db_SW[8]));
    //synchronize dbsw9 (.clk(clock_25mhz), .in(SW[9]), .out(db_SW[9]));
	//synchronize dbsw10 (.clk(clock_25mhz), .in(SW[10]), .out(db_SW[10]));
	//synchronize dbsw11 (.clk(clock_25mhz), .in(SW[11]), .out(db_SW[11]));
	//synchronize dbsw12 (.clk(clock_25mhz), .in(SW[12]), .out(db_SW[12]));
	//synchronize dbsw13 (.clk(clock_25mhz), .in(SW[13]), .out(db_SW[13]));
	//synchronize dbsw14 (.clk(clock_25mhz), .in(SW[14]), .out(db_SW[14]));
	synchronize dbsw15 (.clk(clock_25mhz), .in(SW[15]), .out(db_SW[15]));
    debounce #(.DELAY(250000)) dbbtnc (.reset(db_SW[15]), .clock(clock_25mhz), .noisy(BTNC), .clean(db_BTNC));
    //debounce #(.DELAY(250000)) dbbtnu (.reset(db_SW[15]), .clock(clock_25mhz), .noisy(BTNU), .clean(db_BTNU));
    //debounce #(.DELAY(250000)) dbbtnl (.reset(db_SW[15]), .clock(clock_25mhz), .noisy(BTNL), .clean(db_BTNL));
    //debounce #(.DELAY(250000)) dbbtnr (.reset(db_SW[15]), .clock(clock_25mhz), .noisy(BTNR), .clean(db_BTNR));
    //debounce #(.DELAY(250000)) dbbtnd (.reset(db_SW[15]), .clock(clock_25mhz), .noisy(BTND), .clean(db_BTND));
	// assign reset
	wire reset;
	assign reset = db_SW[15];
    
//////////////////////////////////////////////////////////////////////////////////
		
	// link up the IR Receiver
    wire ir_in;
    assign ir_in = ~JA[0];
    wire [3:0] ir_state;
    wire move_ready;
    wire [11:0] move_data_t;
	ir_receiver ir1(.clock(clock_25mhz),.reset(reset),.data_in(ir_in),.done(move_ready),
					.move_data(move_data_t),.state(ir_state));
    
    // link up the motor controller
    wire motor_l_f;
    wire motor_l_b;
    wire motor_r_f;
    wire motor_r_b;
    assign JA[1] = motor_l_f;
    assign JA[2] = motor_l_b;
    assign JA[3] = motor_r_f;
    assign JA[4] = motor_r_b;
    wire [3:0] motor_state;
    wire [11:0] move_data;
    wire start_move;
    wire move_done;
	motor_signal_stream mss1(.clock(clock_25mhz),.reset(reset),
	                         .command_ready(start_move),
							 .command(move_data),
							 .motor_l_f(motor_l_f),.motor_r_f(motor_r_f),
							 .motor_l_b(motor_l_b),.motor_r_b(motor_r_b),
							 .move_done(move_done),.state(motor_state));
	
	// link up the main fsm
	wire [3:0] master_state;
	rover_main_fsm fsm1(.clock(clock_25mhz),.reset(reset),.move_done(move_done),
	                    .move_ready(move_ready),.move_data_t(move_data_t),
	                    .start_move(start_move),.move_data(move_data), // comment out this line for testing mode
	                    .state(master_state));	
	
    // for testing and determining lengths to travel
    //assign move_data = {4'h0,db_SW[7:0]};
    //assign start_move = db_BTNC;
    // end testing block
	
    //  instantiate 7-segment display; use for debugging
    wire [31:0] data = {move_data[8:0],
                        move_data_t[8:0],
                        motor_l_f,motor_l_b,motor_r_f,motor_r_b,
                        master_state[0],motor_state[2:0],
                        ir_state,
                        2'h0,move_ready,move_done
                        };
    
    // hex display for debug
    wire [7:0] segments;
    display_8hex_nexys4 display(.clk(clock_25mhz),.data(data), .seg(segments), .strobe(AN));     // digit strobe
    assign SEG[7:0] = segments;
endmodule

// as provided by 6.111 Staff for 25mhz clock
module clock_quarter_divider(input clk100_mhz, output reg clock_25mhz = 0);
    reg counter = 0;
    
    always @(posedge clk100_mhz) begin
        counter <= counter + 1;
        if (counter == 0) begin
            clock_25mhz <= ~clock_25mhz;
        end
    end
endmodule

