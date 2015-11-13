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
    (input signed [8:0] r,
     output [7:0] abs7rtan_00,
     output [7:0] abs7rtan_15,
     output [7:0] abs7rtan_30,
     output [7:0] abs7rtan_45,
     output [7:0] abs7rtan_60,
     output [7:0] abs7rtan_75);
     
     // get signed values from helper module
     wire signed [10:0] rtan_00;
     wire signed [10:0] rtan_15;
     wire signed [10:0] rtan_30;
     wire signed [10:0] rtan_45;
     wire signed [10:0] rtan_60;
     wire signed [10:0] rtan_75;
     wire signed [10:0] rtan_90;
     calc_rtan_00_90_15 originalTans (.r(r),.rtan_00(rtan_00),.rtan_15(rtan_15),
												  .rtan_30(rtan_30),.rtan_45(rtan_45),
												  .rtan_60(rtan_60),.rtan_75(rtan_75),
												  .rtan_90(rtan_90));
     
     // convert back from 2s compliment and cast
     assign abs7rtan_00 = (rtan_00>0) ? ((~rtan_00)+1)[7:0] : rtan_00[7:0];
     assign abs7rtan_15 = (rtan_15>0) ? ((~rtan_15)+1)[7:0] : rtan_15[7:0];
     assign abs7rtan_30 = (rtan_30>0) ? ((~rtan_30)+1)[7:0] : rtan_30[7:0];
     assign abs7rtan_45 = (rtan_45>0) ? ((~rtan_45)+1)[7:0] : rtan_45[7:0];
     assign abs7rtan_60 = (rtan_60>0) ? ((~rtan_60)+1)[7:0] : rtan_60[7:0];
     assign abs7rtan_75 = (rtan_75>0) ? ((~rtan_75)+1)[7:0] : rtan_75[7:0];
    
endmodule
