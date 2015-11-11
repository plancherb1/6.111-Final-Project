`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        MIT 6.111 Final Project
// Engineer:       Brian Plancher
// 
// Module Name:    Polar to Cartesian
// Project Name:   FPGA Phone Home
//
// Notes: this relies on only using 6 angles values of 15deg + 30n up to 165
//        if you want to use more or different angles you need to update the code
//
//////////////////////////////////////////////////////////////////////////////////

module polar_to_cartesian
    (input [11:0] r_theta, // r is [7:0] theta is [11:8]
     output reg signed [11:0] x_value,
     output reg signed [11:0] y_value);
	
   // use helper module to do the math
   wire signed [11:0] rsin_15;
   wire signed [11:0] rsin_45;
   wire signed [11:0] rsin_75;
   // we don't need the other outputs so we will allow them to be attached to nothing
   calc_rsin_15_165_30 helper (.r_theta(r_theta),.rsin_15(rsin_15),.rsin_45(rsin_45),.rsin_75(rsin_75))
   
   always @(*) begin
      // use a case statement to continuously assign the correct value to the output
      // note right now when we are doing the 15 + 30n up to 165 we have 6 different possible angles
      case (r_theta[11:8])
         4'h1: begin // 15deg
            x_value <= rsin_75; 
            y_value <= rsin_15;
         end
         4'h2: begin // 45deg
            x_value <= rsin_45; 
            y_value <= rsin_45;
         end
         4'h3: begin // 75deg
            x_value <= rsin_15; 
            y_value <= rsin_75;
         end
         4'h4: begin // 105deg
            x_value <= -1*rsin_15; 
            y_value <= rsin_75;
         end
         4'h5: begin // 135deg
            x_value <= -1*rsin_45; 
            y_value <= rsin_45;
         end
         default: begin // 165deg
            x_value <= -1*rsin_75; 
            y_value <= rsin_15;
         end
      endcase
   end

endmodule
