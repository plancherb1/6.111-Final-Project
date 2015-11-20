`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        MIT 6.111 Final Project
// Engineer:       Brian Plancher
// 
// Module Name:    Median_3
// Project Name:   FPGA Phone Home
//
//////////////////////////////////////////////////////////////////////////////////

module median_3
	(input [19:0] data1,
	 input [19:0] data2,
	 input [19:0] data3,
	 output [19:0] median);
	 
	 wire min1;
	 wire max1;
	 wire comp23;
	 assign min1 = (data2 > data1) && (data3 > data1);
	 assign max1 = (data2 < data1) && (data3 < data1);
	 assign comp23 = data3 > data2;
	 
	 wire med1;
	 wire med2;
	 // if 1 is min or max not 1 else 1
	 // if 1 is min and 2<3 else if 1 is max and 3<2 then 2
	 assign med1 = !(min1 || max1);
	 assign med2 = (min1 && comp23) || (max1 && (!comp23));
	 
	 // then assign out value
	 assign median = med1 ? data1 : (med2 ? data2 : data3);
	 
endmodule
