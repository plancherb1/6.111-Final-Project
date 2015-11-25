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
     output wire [9:0] abs7rtan_60,
     output wire [9:0] abs7rtan_75);
     
		// tan 15 is about 549/2048 which is 16'hs0225 >>> 11
		// tan 30 is about 591/1024 which is 16'hs024f >>> 10
		// tan 45 = 1
		// tan 60 is about 3547/2048 which is 16'hs0DDB >>> 11
		// tan 75 is about 7643/2048 which is 16'hs1DDB >>> 11
		wire signed [31:0] rtan_15deg; // large bit size to multiply and shift 
		wire signed [31:0] rtan_30deg; // large bit size to multiply and shift 
		wire signed [31:0] rtan_60deg; // large bit size to multiply and shift 
		wire signed [31:0] rtan_75deg; // large bit size to multiply and shift 
		assign rtan_15deg = (r*16'sh0225) >>> 11;
		assign rtan_30deg = (r*16'sh024f) >>> 10;
		assign rtan_60deg = (r*16'sh0DDB) >>> 11;
		assign rtan_75deg = (r*16'sh1DDB) >>> 11;
     
		// tan 15, 30, 45 <= 1 so will retain size
		// tan 60, 75 are < 4 but > 1 so need 2 extra bits 
		assign abs7rtan_15 = rtan_15deg[7:0];
		assign abs7rtan_30 = rtan_30deg[7:0];
		assign abs7rtan_45 = r;
		assign abs7rtan_60 = rtan_60deg[9:0];
		assign abs7rtan_75 = rtan_75deg[9:0];
    
endmodule
