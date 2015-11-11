`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        MIT 6.111 Final Project
// Engineer:       Brian Plancher
// 
// Module Name:    Calculate RSin 00 to 180 with 15 Degree Steps
// Project Name:   FPGA Phone Home
//
// Notes: this relies on only using angles values of 0 deg + 15 n up to 180
//        if you want to use more or different angles you need to update the code
//
//////////////////////////////////////////////////////////////////////////////////

module calc_rsin_00_180_15
    (input [11:0] r_theta, // r is [7:0] theta is [11:8]
     output wire signed [11:0] rsin_00,
     output wire signed [11:0] rsin_15,
     output wire signed [11:0] rsin_30,
     output wire signed [11:0] rsin_45,
     output wire signed [11:0] rsin_60,
     output wire signed [11:0] rsin_75,
     output wire signed [11:0] rsin_90);
	
   // continuously create the values we could need
   // sin 00 = cos 90 = -sin 180 // is 1
   // sin 90 = cos 00 = -cos 180 // is 0
   assign rsin_00 = 1;
   assign rsin_90 = 0;
   
   // do the math for the other values that we can't reuse our other module to compute
   // sin 30 = cos 60 = sin 150 = - cos 120 // is about XXXXX
   // sin 60 = cos 30 = sin 120 = - cos 150 // is about XXXXX
   wire signed [31:0] rsin_30deg; // large bit size to multiply and shift
   wire signed [31:0] rsin_60deg; // large bit size to multiply and shift 
   assign rsin_15deg = (r_theta[7:0]*66) >>> 8;  
   
   // then after we have done multiply and shift in larger size variables output
   // the smaller order bits that we care about (which are the only ones left anyway)
   // all are appended with a 0 as they are signed and they are all positive
   assign rsin_30 = {0,rsin_30deg[10:0]};
   assign rsin_60 = {0,rsin_60deg[10:0]};
   
   // use the helper function to get the other three
   calc_rsin_15_165_30 helper (.r_theta(r_theta),.rsin_15(rsin_15),.rsin_45(rsin_45),.rsin_75(rsin_75)))

endmodule
