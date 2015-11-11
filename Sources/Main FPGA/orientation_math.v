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
     output reg [3:0] orientation);
	
   // use helper module to do some of the math for us
   // we know we need in the end r_final*cos(theta_final) - r_original*cos(theta_original)
   // all divided by the sqrt(r_original^2 + r_final^2 - 2r_original*r_final*cos(theta_original-theta_final))
   // which is also delta_x / sqrt(delta_x^2+delta_y^2)
   // so we need to calculate 15,45,75deg rsines of theta_final and theta_original
   wire signed [11:0] rsin_15_orig;
   wire signed [11:0] rsin_45_orig;
   wire signed [11:0] rsin_75_orig;
   wire signed [11:0] rsin_15_final;
   wire signed [11:0] rsin_45_final;
   wire signed [11:0] rsin_75_final;
   // instantiate the helper modules
   calc_rsin_15_165_30 rsin_original (.r_theta(r_theta_original),.rsin_15(rsin_15),.rsin_45(rsin_45),.rsin_75(rsin_75))
   calc_rsin_15_165_30 helper (.r_theta(r_theta_final),.rsin_15(rsin_15_final),.rsin_45(rsin_45_final),.rsin_75(rsin_75_final))
   
   // then we can use case statements to find the correct values to use and do the math with them
   wire signed [31:0] delta_x;
   wire signed [31:0] x_original;
   wire signed [31:0] x_final;
   wire signed [31:0] delta_y;
   wire signed [31:0] y_original;
   wire signed [31:0] y_final;
   assign delta_x = x_final - x_original;
   
   always @(*) begin
      // use a case statement to continuously assign the correct value to the output
      // note right now when we are doing the 15 + 30n up to 165 we have 6 different possible angles
      // for each angle
      
      // TBD assign the xs and compute the big 2r1r2cos(theta-phi)
      
      
      case (r_theta[11:8])
         4'h1: begin // 15deg
            x_value <= rsin_75deg[11:0]; 
            y_value <= rsin_15deg[11:0];
         end
         4'h2: begin // 45deg
            x_value <= rsin_45deg[11:0]; 
            y_value <= rsin_45deg[11:0];
         end
         4'h3: begin // 75deg
            x_value <= rsin_15deg[11:0]; 
            y_value <= rsin_75deg[11:0];
         end
         4'h4: begin // 105deg
            x_value <= -1*rsin_15deg[11:0]; 
            y_value <= rsin_75deg[11:0];
         end
         4'h5: begin // 135deg
            x_value <= -1*rsin_45deg[11:0]; 
            y_value <= rsin_45deg[11:0];
         end
         default: begin // 165deg
            x_value <= -1*rsin_75deg[11:0]; 
            y_value <= rsin_15deg[11:0];
         end
      endcase
   end

endmodule
