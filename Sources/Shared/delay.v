`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// 
// Engineer: Miren
// 
// Module Name:    delay 
//
//////////////////////////////////////////////////////////////////////////////////
module delayN
	#(parameter NDELAY = 4)
	(clk,in,out);
   input clk;
   input in;
   output out;

   reg [NDELAY-1:0] shiftreg;
   wire 	    out = shiftreg[NDELAY-1];

   always @(posedge clk)
     shiftreg <= {shiftreg[NDELAY-2:0],in};

endmodule // delayN
