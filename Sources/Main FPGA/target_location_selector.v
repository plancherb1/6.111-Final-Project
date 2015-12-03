`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        MIT 6.111 Final Project
// Engineer:       Brian Plancher
//
// Module Name: Target Location Selector
// Project Name:   FPGA Phone Home
//
//////////////////////////////////////////////////////////////////////////////////
module target_location_selector
    (input [2:0] switches,
     output [11:0] location); // r is [7:0] theta is [11:8]
	 
    parameter DEFAULT_LOCATION = {5'h06,7'h18}; //90 degrees 24 inches out
    parameter LOC_1 = {5'h01,7'h20}; //15 degrees 32 inches out
    parameter LOC_2 = {5'h07,7'h30}; //105 degrees 48 inches out
    parameter LOC_3 = {5'h08,7'h0A}; //120 degrees 10 inches out
    parameter LOC_4 = {5'h0B,7'h50}; //180 degrees 90 inches out
    //parameter LOC_5 = {5'h06,7'h18};
    //parameter LOC_6 = {5'h06,7'h18};
    //parameter LOC_7 = {5'h06,7'h18};
    
	 always @(*) begin
		case(switches)
         1: location <= LOC_1;
         2: location <= LOC_2;
         3: location <= LOC_3;
         4: location <= LOC_4;
         //5: location <= LOC_5;
         //6: location <= LOC_6;
         //7: location <= LOC_7;
         default: location <= DEFAULT_LOCATION;
      endcase
	 end

endmodule
