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
    (input [7:0] r,
     output wire [7:0] rsin_00,
     output wire [7:0] rsin_15,
     output wire [7:0] rsin_30,
     output wire [7:0] rsin_45,
     output wire [7:0] rsin_60,
     output wire [7:0] rsin_75,
     output wire [7:0] rsin_90);
	
   // continuously create the values we could need
   // sin 00 = cos 90 = -sin 180 // is 1
   // sin 90 = cos 00 = -cos 180 // is 0
   // sin 30 = cos 60 = sin 150 = - cos 120 // is 1/2
   assign rsin_00 = 1;
   assign rsin_90 = 0;
   assign rsin_30 = r >> 1;
   
   // only sin 60 needs math and then a recast
   // sin 60 = cos 30 = sin 120 = - cos 150 // is about 222/256
   wire signed [31:0] rsin_60deg; // large bit size to multiply and shift 
   assign rsin_60deg = (r*222) >> 8;  
   assign rsin_60 = rsin_60deg[7:0];
   
   // use the helper function to get the other three
   calc_rsin_15_165_30 helper (.r(r),.rsin_15(rsin_15),.rsin_45(rsin_45),.rsin_75(rsin_75));

endmodule
