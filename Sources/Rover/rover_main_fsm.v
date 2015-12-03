`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        MIT 6.111 Final Project
// Engineer:       Brian Plancher
// 
// Module Name:    Rover Main FSM
// Project Name:   FPGA Phone Home
//
//////////////////////////////////////////////////////////////////////////////////
module rover_main_fsm(
    input clock,
    input reset,
    input move_done,
    input move_ready,
    input [11:0] move_data_t,
    output reg [11:0] move_data,
    output reg start_move,
    output reg [3:0] state // exposed for debug
   );	                    
     
   parameter ON = 1'b1;
   parameter OFF = 1'b0;
     
   // small fsm to control everything
   parameter WAITING = 4'h0;
   parameter MOVING  = 4'h1;
     
   always @(posedge clock) begin
        if (reset) begin
            move_data <= 12'h000;
            start_move <= OFF;
            state <= WAITING;
        end
        else begin
            case (state)
            
                // when moving wait for move to be done
                MOVING: begin
                    start_move <= OFF;
                    if (move_done) begin
                        state <= WAITING;
                        move_data <= 12'h000;
                    end
                end
                
                // default to wating for a valid command and then
                // use it to activate the move
                default: begin
                    if (move_ready) begin
                        state <= MOVING;
                        start_move <= ON;
                        move_data <= move_data_t;
                    end
                end
                
            endcase
        end
     end
endmodule