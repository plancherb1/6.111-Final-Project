`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        MIT 6.111 Final Project
// Engineer:       Brian Plancher
// 
// Module Name:    Abs Value 10bit
// Project Name:   FPGA Radar Guidance
//
//////////////////////////////////////////////////////////////////////////////////

module abs_val_8
    (input signed [8:0] v,
     output wire [7:0] absv);
     
     assign absv = (v[8] == 1) ? ((~v)+1) : v;
     
endmodule