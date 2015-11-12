`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        MIT 6.111 Final Project
// Engineer:       Brian Plancher
// 
// Module Name:    Abs Value 10bit
// Project Name:   FPGA Phone Home
//
//////////////////////////////////////////////////////////////////////////////////

module abs_val_10
    (input signed [10:0] v,
     output wire [9:0] absv);
     
     assign absv = (v[10] == 1) ? ((~v)+1) : v;
     
endmodule