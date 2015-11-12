`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        MIT 6.111 Final Project
// Engineer:       Brian Plancher
// 
// Module Name:    Calculate RTan 00 to 90 with 15 Degree Steps
// Project Name:   FPGA Phone Home
//
// Note 1: this relies on only using angles values of 0 deg + 15 n up to 90
//         if you want to use more or different angles you need to update the code
//
// Note 2: this returns infinity for rtan90 by returning max
//
//////////////////////////////////////////////////////////////////////////////////

module calc_rtan_00_90_15
    (input signed [8:0] r, // our tans can scale up by a factor of 4 so we need two more bits for outputs
     output signed wire [10:0] rtan_00, 
     output signed wire [10:0] rtan_15,
     output signed wire [10:0] rtan_30,
     output signed wire [10:0] rtan_45,
     output signed wire [10:0] rtan_60,
     output signed wire [10:0] rtan_75,
     output signed wire [10:0] rtan_90);
	
   // continuously create the values we could need
   // tan 00 = 0
   // tan 90 = infinity 
   // tan 45 = 1
   assign rtan_00 = 0;
   assign rtan_90 = r[8]*10'h3FF;
   assign rtan_45 = ((r <<< 2) >>> 2); // shift up to get the signed digit in the right spot and then shift back
   
   // For the other three we need to do the math and recast to smaller bit size
   // tan 15 is about 549/2048 which is 16'hs0225 >>> 11
   // tan 30 is about 591/1024 which is 16'hs024f >>> 10
   // tan 60 is about 3547/2048 which is 16'hs0DDB >>> 11
   // tan 75 is about 7643/2048 which is 16'hs1DDB >>> 11
   wire signed [31:0] rtan_15deg; // large bit size to multiply and shift 
   wire signed [31:0] rtan_30deg; // large bit size to multiply and shift 
   wire signed [31:0] rtan_60deg; // large bit size to multiply and shift 
   wire signed [31:0] rtan_75deg; // large bit size to multiply and shift 
   assign rsin_15deg = (r_theta*16'hs0225) >>> 11;
   assign rsin_30deg = (r_theta*16'hs024f) >>> 10;
   assign rsin_60deg = (r_theta*16'hs0DDB) >>> 11;
   assign rsin_75deg = (r_theta*16'hs1DDB) >>> 11;
   assign rsin_15 = rsin_15deg[10:0];
   assign rsin_30 = rsin_30deg[10:0];
   assign rsin_60 = rsin_60deg[10:0];
   assign rsin_75 = rsin_75deg[10:0];

endmodule
