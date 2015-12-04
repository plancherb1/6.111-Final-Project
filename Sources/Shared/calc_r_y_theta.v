`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        MIT 6.111 Final Project
// Engineer:       Brian Plancher
// 
// Module Name:    Calculate R from Y and Theta
// Project Name:   FPGA Phone Home
//
// Note1: R = y / sin(theta)
//
// Note2: We are assuming 1 distance move unit equals 4 inches as we can possibly
//        have an output that is 4 times bigger than we have space for so we divide by 4
//        therefore we shift by 10 instead of 8
//
//////////////////////////////////////////////////////////////////////////////////
module calc_r_y_theta(
   input [7:0] y,
   input [7:0] x, // need x incase angle is 0 and then all in x
   input [3:0] theta,
   output reg [7:0] r);
   
   // if 0 then all x
   // 1/sin 15 is about 989/256 ~ 4
   // 1/sin 30 is exactly 2
   // 1/sin 45 is about 362/256 ~ 2
   // 1/sin 60 is about 296/256 ~ 1
   // 1/sin 75 is about 265/256 ~ 1
   // if 90 then all y
   wire [31:0] r_15deg; // large bit size to multiply and shift 
   wire [31:0] r_30deg; // large bit size to multiply and shift 
   wire [31:0] r_45deg; // large bit size to multiply and shift 
   wire [31:0] r_60deg; // large bit size to multiply and shift 
   wire [31:0] r_75deg; // large bit size to multiply and shift 
   assign r_15deg = (y*989) >> 10;
   assign r_30deg = y >> 9;
   assign r_45deg = (y*362) >> 10;
   assign r_60deg = (y*296) >> 10;
   assign r_75deg = (y*265) >> 10;
   
   always @(*) begin
      case(theta)
         1: r = r_15deg[7:0];
         2: r = r_30deg[7:0];
         3: r = r_45deg[7:0];
         4: r = r_60deg[7:0];
         5: r = r_75deg[7:0];
         6: r = y; // 90
         default: r = x; // 0
      endcase
   end
   
endmodule