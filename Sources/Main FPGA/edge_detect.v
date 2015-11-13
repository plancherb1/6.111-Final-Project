`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        MIT 6.111 Final Project
// Engineer:       Brian Plancher
// 
// Module Name:    Edge Detect
// Project Name:   FPGA Phone Home
//
/////////////////////////////////////////////////////////////////////////////////
module edge_detect(
    input in,
    input clock,
	 input reset,
    output reg out
    );
	 
	 reg prev_in;
	 
	 always @(posedge clock) begin
		if (reset) begin
			prev_in <= 0;
		end
		else begin
			if ((prev_in == 0) && (in == 1)) begin
				out <= 1;
			end
			else begin
				out <= 0;
			end
			prev_in <= in;
		end
	 end

endmodule
