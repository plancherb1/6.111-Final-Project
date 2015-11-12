`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        MIT 6.111 Final Project
// Engineer:       Brian Plancher
// 
// Module Name:    Orientation Math
// Project Name:   FPGA Phone Home
//
// Notes: this relies on only using 6 angles values of 15deg + 30n up to 165
//        if you want to use more or different angles you need to update the code
//
//////////////////////////////////////////////////////////////////////////////////

module orientation_math
    (input [11:0] r_theta_original, // r is [7:0] theta is [11:8]
     input [11:0] r_theta_final, // r is [7:0] theta is [11:8]
     input clock,
     input enable,
     input reset,
     output done,
     output reg [4:0] orientation);
	
   // use helper module to do the translation for us and then we need to solve
   // tan theta = delta_y / delta_x
   wire signed [8:0] x_original;
   wire signed [8:0] y_original;
   polar_to_cartesian ptc_original (.r_theta(r_theta_original),.x_value(x_original),.y_value(y_original))
   wire signed [8:0] x_final;
   wire signed [8:0] y_final;
   polar_to_cartesian ptc_final (.r_theta(r_theta_final),.x_value(x_final),.y_value(y_final))
   
   wire signed [8:0] delta_y;
   wire signed [8:0] delta_x;
   assign delta_x = x_final - x_original;
   assign delta_y = y_final - y_original;
   
   // we can determine quadrant with the following:
   // if delta y positive and delta x positive then Q1, both negative Q3 --> tan  positive
   // if delta y positive and delta x negative then Q2, inverse Q4 --> tan negative
   wire [1:0] quadrant;
   assign quadrant = ((delta_x > 0) && (delta_y > 0)) : 1 ? ((delta_y > 0) : 2 ? ((delta_x > 0) : 4 ? 3));
   
   // now we solve delta x tan theta = delta y by finding the closest match to base angles
   wire [7:0] abs7dxtan00;
   wire [7:0] abs7dxtan15;
   wire [7:0] abs7dxtan30;
   wire [7:0] abs7dxtan45;
   wire [7:0] abs7dxtan60;
   wire [7:0] abs7dxtan75;
   wire [7:0] abs7dxtan90;
   //use a helper function for the abs(delta x * theta)
   calc_abs7rtan_00_90_15(.r(delta_x),.abs7rtan_00(abs7dxtan00),.abs7rtan_15(abs7dxtan15),.abs7rtan_30(abs7dxtan30),
                          .abs7rtan_45(abs7dxtan45),.abs7rtan_60(abs7dxtan60),.abs7rtan_75(abs7dxtan75));
   
   // we then need to find abs value of the differences between the calcs and delta y
   // note 90 degrees is a single test
   wire test90 = (delta_x == 0) && (~(delta_y == 0));
   wire [7:0] diff00;
   wire [7:0] diff15;
   wire [7:0] diff30;
   wire [7:0] diff45;
   wire [7:0] diff60;
   wire [7:0] diff75;
   wire [7:0] absdelta_y;
   abs_val_8 abs1 (.v(delta_y),.absv(absdelta_y));
   abs_diff_7 abdiff1 (.x(delta_y),.y(abs7dxtan00),.absdiff(diff00)));
   abs_diff_7 abdiff2 (.x(delta_y),.y(abs7dxtan15),.absdiff(diff15)));
   abs_diff_7 abdiff3 (.x(delta_y),.y(abs7dxtan30),.absdiff(diff30)));
   abs_diff_7 abdiff4 (.x(delta_y),.y(abs7dxtan45),.absdiff(diff45)));
   abs_diff_7 abdiff5 (.x(delta_y),.y(abs7dxtan60),.absdiff(diff60)));
   abs_diff_7 abdiff6 (.x(delta_y),.y(abs7dxtan75),.absdiff(diff75)));
   
   // then we can find the smallest one which is the best angle approximation
   wire base_angle [2:0];
   wire comp00_15;
   wire comp15_30;
   wire comp30_45;
   wire comp45_60;
   wire comp60_75;
   assign comp00_15 = diff00 > diff15;
   assign comp15_30 = diff15 > diff30;
   assign comp30_45 = diff30 > diff45;
   assign comp45_60 = diff45 > diff60;
   assign comp60_75 = diff60 > diff75;
   assign base_angle = test90 ? 6 : comp00_15 + comp15_30 + comp30_45 + comp45_60 + comp60_75;
   
   // then we can find orientation based on the base angle and quadrant
   always @(*) begin
      case(quadrant):
         1: orientation = base_angle; // 15 = 15, 75 = 75
         2: orientation = 12 - base_angle // 75 = 180-75, 15 = 180-15
         3: orientation = 12 + base_angle // 15 = 180+15, 75 = 180+75
         4: orientation = 24 - base_angle // 75 = 360-75, 15 = 360-15
      endcase
   end
   
   // I clock / pipeline this by delaying the done signal by 5 clock cycles after the data is presented
   // to provide the algorithm extra time to complete since we are not under time pressure to return the value
   // total timing is cartesian to polar (1 mul, 1 shift, 1 comp) + convert to delta (1 add and cast to 2s compliment so 2 add 1 shift) +
   // calc abs rtan (1 mul, 1 shift + 2 add 1 shift) + quad (2 comp) + comps (1 comp + 1 add) + final (1 add) = (2 mul, 4 shift, 6 add, 6 comp)
   // this may actually clear in 1 clock cycle but if the compiler doesn't optimize right it could be slower so going to be safe
   
   reg state;
   parameter CONTINUOUS_CALC = 1'b0;
   parameter DELAY = 1'b1;
   reg [3:0] counter;
   parameter COUNTER_GOAL = 5;
   
   always @(posedge clock) begin
      if (reset) begin
         state <= CONTINUOUS_CALC;
         done <= 0;
      end
      else begin
         case(state)
         
            // count to goal to delay the done signal
            DELAY: begin
               if (counter == COUNTER_GOAL) begin
                  state <= CONTINUOUS_CALC;
                  done <= 1;
               end
               else begin
                  counter <= counter + 1;
               end
            end
            
            // default to continuous calculation and wait for enable to delay
            default: begin
               if (enable) begin
                  counter <= 1;
                  state <= DELAY;
               end
               done <= 0;
            end
         endcase
      end
   end

endmodule
