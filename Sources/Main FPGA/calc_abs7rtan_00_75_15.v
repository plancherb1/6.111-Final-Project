`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        MIT 6.111 Final Project
// Engineer:       Brian Plancher
// 
// Module Name:    Calculate Abs Value of RTan 00 to 75 with 15 Degree Steps in 8 bits
// Project Name:   FPGA Phone Home
//
// Note 1: this relies on only using angles values of 0 deg + 15 n up to 90
//         if you want to use more or different angles you need to update the code
//
// Note 2: this blindly casts to 8 bits and gets absolute value use with caution
//
//////////////////////////////////////////////////////////////////////////////////

module calc_abs7rtan_00_75_15
    (input [7:0] r,
     output wire [7:0] abs7rtan_15,
     output wire [7:0] abs7rtan_30,
     output wire [7:0] abs7rtan_45,
     output wire [7:0] abs7rtan_60,
     output wire [7:0] abs7rtan_75);
     
     // get signed values from helper module
     wire signed [10:0] rtan_00;
     wire signed [10:0] rtan_15;
     wire signed [10:0] rtan_30;
     wire signed [10:0] rtan_45;
     wire signed [10:0] rtan_60;
     wire signed [10:0] rtan_75;
     wire signed [10:0] rtan_90;
     calc_rtan_00_90_15 originalTans (.r(r),.rtan_00(rtan_00),.rtan_15(rtan_15),.rtan_30(rtan_30),
                                      .rtan_45(rtan_45),.rtan_60(rtan_60),.rtan_75(rtan_75),.rtan_90(rtan_90));
     
     // we know the input is positive so all outputs are positive so just reduce size
	  assign abs7rtan_15 = posrtan_15[7:0];
	  assign abs7rtan_30 = posrtan_30[7:0];
	  assign abs7rtan_45 = posrtan_45[7:0];
	  assign abs7rtan_60 = posrtan_60[7:0];
	  assign abs7rtan_75 = posrtan_75[7:0];
    
endmodule
