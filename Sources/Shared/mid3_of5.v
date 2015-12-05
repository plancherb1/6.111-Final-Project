`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        MIT 6.111 Final Project
// Engineer:       Brian Plancher
// 
// Module Name:    Mid3_of5
// Project Name:   FPGA Phone Home
//
//////////////////////////////////////////////////////////////////////////////////

module mid3_of5
	(input [7:0] data1,
	 input [7:0] data2,
	 input [7:0] data3,
	 input [7:0] data4,
	 input [7:0] data5,
	 output [7:0] mid1,
	 output [7:0] mid2,
	 output [7:0] mid3);
	 
	 wire min1;
	 wire max1;
	 wire min2;
	 wire max2;
	 wire min3;
	 wire max3;
	 wire min4;
	 wire max4;
	 wire min5;
	 wire max5;
	 assign min1 = (data2 > data1) && (data3 > data1) &&
						 (data4 > data1) && (data5 > data1);
	 assign min2 = (data1 > data2) && (data3 > data2) &&
						 (data4 > data2) && (data5 > data2);
	 assign min3 = (data1 > data3) && (data2 > data3) &&
						 (data4 > data3) && (data5 > data3);
	 assign min4 = (data1 > data4) && (data2 > data4) &&
						 (data3 > data4) && (data5 > data4);
	 assign max1 = (data2 < data1) && (data3 < data1) &&
						 (data4 < data1) && (data5 < data1);
	 assign max2 = (data1 < data2) && (data3 < data2) &&
						 (data4 < data2) && (data5 < data2);
	 assign max3 = (data1 < data3) && (data2 < data3) &&
						 (data4 < data3) && (data5 < data3);
	 assign max4 = (data1 < data4) && (data2 < data4) &&
						 (data3 < data4) && (data5 < data4);
	 assign min5 = !min1&!min2&!min3&!min4;
	 assign max5 = !max1&!max2&!max3&!max4;
	 
	 wire boundry1;
	 wire boundry2;
	 wire boundry3;
	 wire boundry4;
	 wire boundry5;
	 assign boundry1 = min1 | max1;
	 assign boundry2 = min2 | max2;
	 assign boundry3 = min3 | max3;
	 assign boundry4 = min4 | max4;
	 assign boundry5 = min5 | max5;
	
	 assign mid1 = !boundry1 ? data1 : (!boundry2 ? data2 : data3);
	 assign mid2 = !boundry4 ? data4 : (!boundry3 ? data3 : data2);
	 assign mid3 = !boundry5 ? data5 : (!boundry1&!boundry2 ? data2 : data3);
	 
endmodule
