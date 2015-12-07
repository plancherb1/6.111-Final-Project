`default_nettype none

///////////////////////////////////////////////////////////////////////////////
//
// 6.111 Remote Control Transmitter Module V2.1
//
// Created: February 29, 2009
// Author: Adam Lerer,
// Updated GPH October 6, 2010 
//     - fixed 40Khz modulation, repeat commands exaclty every 45ms. 
//
///////////////////////////////////////////////////////////////////////////////
//
// 6.111 FPGA Labkit -- Template Toplevel Module
//
// For Labkit Revision 004
//
//
// Created: October 31, 2004, from revision 003 file
// Author: Nathan Ickes
//
///////////////////////////////////////////////////////////////////////////////
//
// CHANGES FOR BOARD REVISION 004
//
// 1) Added signals for logic analyzer pods 2-4.
// 2) Expanded "tv_in_ycrcb" to 20 bits.
// 3) Renamed "tv_out_data" to "tv_out_i2c_data" and "tv_out_sclk" to
//    "tv_out_i2c_clock".
// 4) Reversed disp_data_in and disp_data_out signals, so that "out" is an
//    output of the FPGA, and "in" is an input.
//
// CHANGES FOR BOARD REVISION 003
//
// 1) Combined flash chip enables into a single signal, flash_ce_b.
//
// CHANGES FOR BOARD REVISION 002
//
// 1) Added SRAM clock feedback path input and output
// 2) Renamed "mousedata" to "mouse_data"
// 3) Renamed some ZBT memory signals. Parity bits are now incorporated into 
//    the data bus, and the byte write enables have been combined into the
//    4-bit ram#_bwe_b bus.
// 4) Removed the "systemace_clock" net, since the SystemACE clock is now
//    hardwired on the PCB to the oscillator.
//
///////////////////////////////////////////////////////////////////////////////
//
// Complete change history (including bug fixes)
//
// 2006-Mar-08: Corrected default assignments to "vga_out_red", "vga_out_green"
//              and "vga_out_blue". (Was 10'h0, now 8'h0.)
//
// 2005-Sep-09: Added missing default assignments to "ac97_sdata_out",
//              "disp_data_out", "analyzer[2-3]_clock" and
//              "analyzer[2-3]_data".
//
// 2005-Jan-23: Reduced flash address bus to 24 bits, to match 128Mb devices
//              actually populated on the boards. (The boards support up to
//              256Mb devices, with 25 address lines.)
//
// 2004-Oct-31: Adapted to new revision 004 board.
//
// 2004-May-01: Changed "disp_data_in" to be an output, and gave it a default
//              value. (Previous versions of this file declared this port to
//              be an input.)
//
// 2004-Apr-29: Reduced SRAM address busses to 19 bits, to match 18Mb devices
//              actually populated on the boards. (The boards support up to
//              72Mb devices, with 21 address lines.)
//
// 2004-Apr-29: Change history started
//
///////////////////////////////////////////////////////////////////////////////

module labkit (beep, audio_reset_b, ac97_sdata_out, ac97_sdata_in, ac97_synch,
	       ac97_bit_clock,
	       
	       vga_out_red, vga_out_green, vga_out_blue, vga_out_sync_b,
	       vga_out_blank_b, vga_out_pixel_clock, vga_out_hsync,
	       vga_out_vsync,

	       tv_out_ycrcb, tv_out_reset_b, tv_out_clock, tv_out_i2c_clock,
	       tv_out_i2c_data, tv_out_pal_ntsc, tv_out_hsync_b,
	       tv_out_vsync_b, tv_out_blank_b, tv_out_subcar_reset,

	       tv_in_ycrcb, tv_in_data_valid, tv_in_line_clock1,
	       tv_in_line_clock2, tv_in_aef, tv_in_hff, tv_in_aff,
	       tv_in_i2c_clock, tv_in_i2c_data, tv_in_fifo_read,
	       tv_in_fifo_clock, tv_in_iso, tv_in_reset_b, tv_in_clock,

	       ram0_data, ram0_address, ram0_adv_ld, ram0_clk, ram0_cen_b,
	       ram0_ce_b, ram0_oe_b, ram0_we_b, ram0_bwe_b, 

	       ram1_data, ram1_address, ram1_adv_ld, ram1_clk, ram1_cen_b,
	       ram1_ce_b, ram1_oe_b, ram1_we_b, ram1_bwe_b,

	       clock_feedback_out, clock_feedback_in,

	       flash_data, flash_address, flash_ce_b, flash_oe_b, flash_we_b,
	       flash_reset_b, flash_sts, flash_byte_b,

	       rs232_txd, rs232_rxd, rs232_rts, rs232_cts,

	       mouse_clock, mouse_data, keyboard_clock, keyboard_data,

	       clock_27mhz, clock1, clock2,

	       disp_blank, disp_data_out, disp_clock, disp_rs, disp_ce_b,
	       disp_reset_b, disp_data_in,

	       button0, button1, button2, button3, button_enter, button_right,
	       button_left, button_down, button_up,

	       switch,

	       led,
	       
	       user1, user2, user3, user4,
	       
	       daughtercard,

	       systemace_data, systemace_address, systemace_ce_b,
	       systemace_we_b, systemace_oe_b, systemace_irq, systemace_mpbrdy,
	       
	       analyzer1_data, analyzer1_clock,
 	       analyzer2_data, analyzer2_clock,
 	       analyzer3_data, analyzer3_clock,
 	       analyzer4_data, analyzer4_clock);

   output beep, audio_reset_b, ac97_synch, ac97_sdata_out;
   input  ac97_bit_clock, ac97_sdata_in;
   
   output [7:0] vga_out_red, vga_out_green, vga_out_blue;
   output vga_out_sync_b, vga_out_blank_b, vga_out_pixel_clock,
	  vga_out_hsync, vga_out_vsync;

   output [9:0] tv_out_ycrcb;
   output tv_out_reset_b, tv_out_clock, tv_out_i2c_clock, tv_out_i2c_data,
	  tv_out_pal_ntsc, tv_out_hsync_b, tv_out_vsync_b, tv_out_blank_b,
	  tv_out_subcar_reset;
   
   input  [19:0] tv_in_ycrcb;
   input  tv_in_data_valid, tv_in_line_clock1, tv_in_line_clock2, tv_in_aef,
	  tv_in_hff, tv_in_aff;
   output tv_in_i2c_clock, tv_in_fifo_read, tv_in_fifo_clock, tv_in_iso,
	  tv_in_reset_b, tv_in_clock;
   inout  tv_in_i2c_data;
        
   inout  [35:0] ram0_data;
   output [18:0] ram0_address;
   output ram0_adv_ld, ram0_clk, ram0_cen_b, ram0_ce_b, ram0_oe_b, ram0_we_b;
   output [3:0] ram0_bwe_b;
   
   inout  [35:0] ram1_data;
   output [18:0] ram1_address;
   output ram1_adv_ld, ram1_clk, ram1_cen_b, ram1_ce_b, ram1_oe_b, ram1_we_b;
   output [3:0] ram1_bwe_b;

   input  clock_feedback_in;
   output clock_feedback_out;
   
   inout  [15:0] flash_data;
   output [23:0] flash_address;
   output flash_ce_b, flash_oe_b, flash_we_b, flash_reset_b, flash_byte_b;
   input  flash_sts;
   
   output rs232_txd, rs232_rts;
   input  rs232_rxd, rs232_cts;

   input  mouse_clock, mouse_data, keyboard_clock, keyboard_data;

   input  clock_27mhz, clock1, clock2;

   output disp_blank, disp_clock, disp_rs, disp_ce_b, disp_reset_b;  
   input  disp_data_in;
   output  disp_data_out;
   
   input  button0, button1, button2, button3, button_enter, button_right,
	  button_left, button_down, button_up;
   input  [7:0] switch;
   output [7:0] led;

   inout [31:0] user1, user2, user3, user4;
   
   inout [43:0] daughtercard;

   inout  [15:0] systemace_data;
   output [6:0]  systemace_address;
   output systemace_ce_b, systemace_we_b, systemace_oe_b;
   input  systemace_irq, systemace_mpbrdy;

   output [15:0] analyzer1_data, analyzer2_data, analyzer3_data, 
		 analyzer4_data;
   output analyzer1_clock, analyzer2_clock, analyzer3_clock, analyzer4_clock;

   ////////////////////////////////////////////////////////////////////////////
   //
   // I/O Assignments
   //
   ////////////////////////////////////////////////////////////////////////////
   
   // Audio Input and Output
   assign beep= 1'b0;
   assign audio_reset_b = 1'b0;
   assign ac97_synch = 1'b0;
   assign ac97_sdata_out = 1'b0;
   // ac97_sdata_in is an input

   // VGA Output
   //assign vga_out_red = 8'h0;
   //assign vga_out_green = 8'h0;
   //assign vga_out_blue = 8'h0;
   //assign vga_out_sync_b = 1'b1;
   //assign vga_out_blank_b = 1'b1;
   //assign vga_out_pixel_clock = 1'b0;
   //assign vga_out_hsync = 1'b0;
   //assign vga_out_vsync = 1'b0;

   // Video Output
   assign tv_out_ycrcb = 10'h0;
   assign tv_out_reset_b = 1'b0;
   assign tv_out_clock = 1'b0;
   assign tv_out_i2c_clock = 1'b0;
   assign tv_out_i2c_data = 1'b0;
   assign tv_out_pal_ntsc = 1'b0;
   assign tv_out_hsync_b = 1'b1;
   assign tv_out_vsync_b = 1'b1;
   assign tv_out_blank_b = 1'b1;
   assign tv_out_subcar_reset = 1'b0;
   
   // Video Input
   assign tv_in_i2c_clock = 1'b0;
   assign tv_in_fifo_read = 1'b0;
   assign tv_in_fifo_clock = 1'b0;
   assign tv_in_iso = 1'b0;
   assign tv_in_reset_b = 1'b0;
   assign tv_in_clock = 1'b0;
   assign tv_in_i2c_data = 1'bZ;
   // tv_in_ycrcb, tv_in_data_valid, tv_in_line_clock1, tv_in_line_clock2, 
   // tv_in_aef, tv_in_hff, and tv_in_aff are inputs
   
   // SRAMs
   assign ram0_data = 36'hZ;
   assign ram0_address = 19'h0;
   assign ram0_adv_ld = 1'b0;
   assign ram0_clk = 1'b0;
   assign ram0_cen_b = 1'b1;
   assign ram0_ce_b = 1'b1;
   assign ram0_oe_b = 1'b1;
   assign ram0_we_b = 1'b1;
   assign ram0_bwe_b = 4'hF;
   assign ram1_data = 36'hZ; 
   assign ram1_address = 19'h0;
   assign ram1_adv_ld = 1'b0;
   assign ram1_clk = 1'b0;
   assign ram1_cen_b = 1'b1;
   assign ram1_ce_b = 1'b1;
   assign ram1_oe_b = 1'b1;
   assign ram1_we_b = 1'b1;
   assign ram1_bwe_b = 4'hF;
   assign clock_feedback_out = 1'b0;
   // clock_feedback_in is an input
   
   // Flash ROM
   assign flash_data = 16'hZ;
   assign flash_address = 24'h0;
   assign flash_ce_b = 1'b1;
   assign flash_oe_b = 1'b1;
   assign flash_we_b = 1'b1;
   assign flash_reset_b = 1'b0;
   assign flash_byte_b = 1'b1;
   // flash_sts is an input

   // RS-232 Interface
   assign rs232_txd = 1'b1;
   assign rs232_rts = 1'b1;
   // rs232_rxd and rs232_cts are inputs

   // PS/2 Ports
   // mouse_clock, mouse_data, keyboard_clock, and keyboard_data are inputs

/*
   // LED Displays
   assign disp_blank = 1'b1;
   assign disp_clock = 1'b0;
   assign disp_rs = 1'b0;
   assign disp_ce_b = 1'b1;
   assign disp_reset_b = 1'b0;
   assign disp_data_out = 1'b0;
   // disp_data_in is an input
*/

   // Buttons, Switches, and Individual LEDs
   assign led = 8'hFF;
   // button0, button1, button2, button3, button_enter, button_right,
   // button_left, button_down, button_up, and switches are inputs

   // User I/Os
   //assign user1 = 32'hZ;
   assign user2 = 32'hZ;
   assign user3 = 32'hZ;
   assign user4 = 32'hZ;

   // Daughtercard Connectors
   assign daughtercard = 44'hZ;

   // SystemACE Microprocessor Port
   assign systemace_data = 16'hZ;
   assign systemace_address = 7'h0;
   assign systemace_ce_b = 1'b1;
   assign systemace_we_b = 1'b1;
   assign systemace_oe_b = 1'b1;
   // systemace_irq and systemace_mpbrdy are inputs

   // Logic Analyzer
   assign analyzer1_data = 16'h0;
   assign analyzer1_clock = 1'b1;
   assign analyzer2_data = 16'h0;
   assign analyzer2_clock = 1'b1;
   assign analyzer3_data = 16'h0;
   assign analyzer3_clock = 1'b1;
   assign analyzer4_data = 16'h0;
   assign analyzer4_clock = 1'b1;


  ////////////////////////////////////////////////////////////////////////////
  //
  // Reset Generation
  //
  // A shift register primitive is used to generate an active-high reset
  // signal that remains high for 16 clock cycles after configuration finishes
  // and the FPGA's internal clocks begin toggling.
  //
  ////////////////////////////////////////////////////////////////////////////
  wire reset_init;
  SRL16 reset_sr(.D(1'b0), .CLK(clock_27mhz), .Q(reset_init),
	         .A0(1'b1), .A1(1'b1), .A2(1'b1), .A3(1'b1));
  defparam reset_sr.INIT = 16'hFFFF;
  
  // debounce the buttons and synchnozie the switches
  wire btnU_db;
  wire btnD_db;
  wire btnL_db;
  wire btnR_db;
  wire btn0_db;
  wire btn1_db;
  wire btn2_db;
  wire btn3_db;
  wire btnE_db;
  wire [7:0] db_switch;
  // reset is the OR of button enter and the FPGA reset
  debounce #(.DELAY(270000)) db_E (.reset(reset_init), .clock(clock_27mhz), .noisy(~button_enter), .clean(btnE_db));
  wire reset = reset_init | btnE_db;
  // rest of buttons and switches
  //debounce #(.DELAY(270000)) db_U (.reset(reset), .clock(clock_27mhz), .noisy(~button_up), .clean(btnU_db));
  //debounce #(.DELAY(270000)) db_D (.reset(reset), .clock(clock_27mhz), .noisy(~button_down), .clean(btnD_db));
  //debounce #(.DELAY(270000)) db_L (.reset(reset), .clock(clock_27mhz), .noisy(~button_left), .clean(btnL_db));
  //debounce #(.DELAY(270000)) db_R (.reset(reset), .clock(clock_27mhz), .noisy(~button_right), .clean(btnR_db));
  debounce #(.DELAY(270000)) db_0 (.reset(reset), .clock(clock_27mhz), .noisy(~button0), .clean(btn0_db));
  debounce #(.DELAY(270000)) db_1 (.reset(reset), .clock(clock_27mhz), .noisy(~button1), .clean(btn1_db));
  debounce #(.DELAY(270000)) db_2 (.reset(reset), .clock(clock_27mhz), .noisy(~button2), .clean(btn2_db));
  debounce #(.DELAY(270000)) db_3 (.reset(reset), .clock(clock_27mhz), .noisy(~button3), .clean(btn3_db));
  debounce #(.DELAY(270000)) db_S0 (.reset(reset), .clock(clock_27mhz), .noisy(switch[0]), .clean(db_switch[0]));
  debounce #(.DELAY(270000)) db_S1 (.reset(reset), .clock(clock_27mhz), .noisy(switch[1]), .clean(db_switch[1]));
  debounce #(.DELAY(270000)) db_S2 (.reset(reset), .clock(clock_27mhz), .noisy(switch[2]), .clean(db_switch[2]));
  //debounce #(.DELAY(270000)) db_S3 (.reset(reset), .clock(clock_27mhz), .noisy(switch[3]), .clean(db_switch[3]));
  //debounce #(.DELAY(270000)) db_S4 (.reset(reset), .clock(clock_27mhz), .noisy(switch[4]), .clean(db_switch[4]));
  //debounce #(.DELAY(270000)) db_S5 (.reset(reset), .clock(clock_27mhz), .noisy(switch[5]), .clean(db_switch[5]));
  //debounce #(.DELAY(270000)) db_S6 (.reset(reset), .clock(clock_27mhz), .noisy(switch[6]), .clean(db_switch[6]));
  //debounce #(.DELAY(270000)) db_S7 (.reset(reset), .clock(clock_27mhz), .noisy(switch[7]), .clean(db_switch[7]));
  
  ////////////////////////////////////////////////////////////////////////////
  //
  // Set up the XVGA Output per Lab3
  //
  ////////////////////////////////////////////////////////////////////////////
  
  // use FPGA's digital clock manager to produce a
  // 65MHz clock (actually 64.8MHz)
  wire clock_65mhz_unbuf,clock_65mhz;
  DCM vclk1(.CLKIN(clock_27mhz),.CLKFX(clock_65mhz_unbuf));
  // synthesis attribute CLKFX_DIVIDE of vclk1 is 10
  // synthesis attribute CLKFX_MULTIPLY of vclk1 is 24
  // synthesis attribute CLK_FEEDBACK of vclk1 is NONE
  // synthesis attribute CLKIN_PERIOD of vclk1 is 37
  BUFG vclk2(.O(clock_65mhz),.I(clock_65mhz_unbuf));
  
  // generate basic XVGA video signals
  wire [10:0] hcount;
  wire [9:0]  vcount;
  wire hsync,vsync,blank;
  xvga xvga1(.vclock(clock_65mhz),.hcount(hcount),.vcount(vcount),
             .hsync(hsync),.vsync(vsync),.blank(blank));
  // signals for logic to update
  wire [23:0] pixel;
  wire phsync,pvsync,pblank;
  // VGA Output.  In order to meet the setup and hold times of the
  // AD7125, we send it ~clock_65mhz.
  assign vga_out_red = pixel[23:16];
  assign vga_out_green = pixel[15:8];
  assign vga_out_blue = pixel[7:0];
  assign vga_out_sync_b = 1'b1;    // not used
  assign vga_out_blank_b = ~pblank;
  assign vga_out_pixel_clock = ~clock_65mhz;
  assign vga_out_hsync = phsync;
  assign vga_out_vsync = pvsync;
  
  ////////////////////////////////////////////////////////////////////////////
  //
  // Connect the Modules to Produce the Desired Behaviors
  //
  ////////////////////////////////////////////////////////////////////////////
  
  // variables to pass around information
  wire transmit_ir; // send IR flag
  wire master_on; // turn on the whole process flag
  wire ir_signal; // IR data
  wire run_ultrasound; // flag to turn on the ultrasound
  wire run_ultrasound_fsm; // flag to turn on the ultrasound from fsm
  wire ultrasound_done; // flag for new location ready
  wire orientation_done; // flag for new orientation ready
  wire reached_target; // flag for reached target
  wire [11:0] move_command; // angle == [11:7], distance == [6:0]
  wire [11:0] rover_location; // theta == [11:8], r == [7:0]
  wire [4:0] rover_orientation; // every 15 degrees around the circle
  wire [2:0] target_switches;
  wire [11:0] target_location; // theta == [11:8], r == [7:0]
  wire [5:0] ultrasound_trigger;
  wire [5:0] ultrasound_power;
  wire [5:0] ultrasound_response;
  
  // assignments of some of those variables to inputs and outputs
  assign user1[31] = ir_signal;
  // we only want one high when the button is pressed
  edge_detect e1 (.in(btn3_db),.clock(clock_27mhz),.reset(reset),.out(master_on));
  // need two ways to run ultrasound both the start manually and from the orientation / path
  assign target_switches = db_switch[2:0];
  // assign command, power, signal, to 0,1,2 + 3n
  assign {user1[12],user1[15],user1[18],user1[21],user1[24],user1[27]} = ultrasound_trigger;
  assign {user1[13],user1[16],user1[19],user1[22],user1[25],user1[28]} = ultrasound_power;
  assign ultrasound_response = {user1[14],user1[17],user1[20],user1[23],user1[26],user1[29]};
  
  // target location selector logic
  target_location_selector tls (.switches(target_switches),.location(target_location));
  
  wire [4:0] main_state;
  wire [4:0] needed_orientation;
  wire [11:0] orient_location_1;
  wire [11:0] orient_location_2;
  wire [11:0] move_command_t;
  wire run_move;
  edge_detect e2 (.in(btn2_db),.clock(clock_27mhz),.reset(reset),.out(run_move));
  // master FSM to control all modules (ultrasound and orientation/path and commands for IR)
  main_fsm msfm (.clock(clock_27mhz),.reset(reset),
						.run_program(master_on),.run_move(run_move),
						.target_location(target_location),
                  .ultrasound_done(ultrasound_done),
						.rover_location(rover_location),
						.run_ultrasound(run_ultrasound_fsm),
						.orientation_done(orientation_done),
						.orientation(rover_orientation),
						.move_command(move_command),
						.transmit_ir(transmit_ir),
                  //.analyzer_clock(analyzer3_clock),
                  //.analyzer_data(analyzer3_data),
                  .reached_target(reached_target),
						.orient_location_1(orient_location_1),
						.orient_location_2(orient_location_2),
						.needed_orientation(needed_orientation),
						.move_command_t(move_command_t),
						.state(main_state));
  
  // Ultrasound Block
  wire [3:0] ultrasound_state;
  wire [3:0] curr_ultrasound;
  wire run_ultrasound_manual;
  edge_detect e3 (.in(btn1_db),.clock(clock_27mhz),.reset(reset),.out(run_ultrasound_manual));
  assign run_ultrasound = run_ultrasound_fsm | run_ultrasound_manual;
  rover_location_calculator rlc1 (.clock(clock_27mhz),.reset(reset),.enable(run_ultrasound),
                                  .ultrasound_response(ultrasound_response),
                                  .ultrasound_trigger(ultrasound_trigger),
                                  .ultrasound_power(ultrasound_power),
                                  .rover_location(rover_location),
                                  .done(ultrasound_done),
                                  .state(ultrasound_state),
                                  .curr_ultrasound(curr_ultrasound));
  
  // VGA Display Block
  // feed XVGA signals to our VGA logic module
  vga_writer vg(.vclock(clock_65mhz),.reset(reset),
                .move_command(move_command),.location(rover_location),
                .orientation(rover_orientation),.target_location(target_location),
                .orientation_ready(orientation_done),
					 .new_data(ultrasound_done),
					 //.analyzer_clock(analyzer3_clock),
					 //.analyzer_data(analyzer3_data),
                .hcount(hcount),.vcount(vcount),.hsync(hsync),.vsync(vsync),.blank(blank),
			       .phsync(phsync),.pvsync(pvsync),.pblank(pblank),.pixel(pixel));
  
  wire ir_manual;
  assign ir_manual = btn0_db;
  wire run_ir;
  assign run_ir = ir_signal|ir_manual;
  // Transmitter (from Lab5b hijacked to send IR)
  ir_transmitter transmitter (.clk(clock_27mhz),
                               .reset(reset),
                               .address(move_command[11:7]), // angle
                               .command(move_command[6:0]), // distance
                               .transmit(transmit_ir),
                               .signal_out(run_ir));					  
   
  // use this to display on hex display for debug
  reg [63:0] my_hex_data;
  always @(posedge clock_27mhz) begin
		my_hex_data <= {	
								//3'b0, ultrasound_done, // 4 bits
								
								3'h0,main_state, // 5 bits
								//3'h0,needed_orientation, // 5 bits
								
								//ultrasound_state, // 4 bits
								//curr_ultrasound, // 4 bits
								3'b0,rover_orientation, // 8 bits																
                        //3'b0, orientation_done, // 4 bits
								
								rover_location,// 12 bits
								target_location, // 12 bits
								//orient_location_1, // 12 bits
								//orient_location_2, // 12 bits							
								
								//3'b0, transmit_ir,
								//3'b0, reached_target,
								move_command_t,//12bits
								move_command // 12 bits
							};
  end
	

  display_16hex_labkit disp(reset, clock_27mhz,my_hex_data,
										disp_blank, disp_clock, disp_rs, disp_ce_b,
										disp_reset_b, disp_data_out);
  

  // display waveform on logic analyzer for debug (if needed)
  //assign analyzer3_data = 16'hFFFF;
  //assign analyzer3_clock = clock_27mhz;
			    
endmodule
