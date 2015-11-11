`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        MIT 6.111 Final Project
// Engineer:       Brian Plancher
// 
// Module Name:    Calculate RSin 15 to 165 with 30 Degree Steps
// Project Name:   FPGA Phone Home
//
// Notes: this relies on only using angles values of 15 deg + 30 n up to 165
//        if you want to use more or different angles you need to update the code
//
//////////////////////////////////////////////////////////////////////////////////

module calc_rsin_15_165_30
    (input [11:0] r_theta, // r is [7:0] theta is [11:8]
     output wire signed [11:0] rsin_15,
     output wire signed [11:0] rsin_45,
     output wire signed [11:0] rsin_75);
   
   // do the math for the other values
   // sin 15 = cos 75 = sin 165 = - cos 105 // is about 66/256
   // sin 45 = cos 45 = sin 135 = - cos 135 // is about 181/256
   // sin 75 = cos 15 = sin 105 = - cos 165 // is about 247/256
   wire signed [31:0] rsin_15deg; // large bit size to multiply and shift
   wire signed [31:0] rsin_45deg; // large bit size to multiply and shift
   wire signed [31:0] rsin_75deg; // large bit size to multiply and shift   
   assign rsin_15deg = (r_theta[7:0]*66) >>> 8;  
   assign rsin_45deg = (r_theta[7:0]*181) >>> 8;             
   assign rsin_75deg = (r_theta[7:0]*247) >>> 8;
   
   // then after we have done multiply and shift in larger size variables output
   // the smaller order bits that we care about (which are the only ones left anyway)
   // all are appended with a 0 as they are signed and they are all positive
   assign rsin_15 = {0,rsin_15deg[10:0]};
   assign rsin_45 = {0,rsin_45deg[10:0]};
   assign rsin_75 = {0,rsin_75deg[10:0]};

endmodule
