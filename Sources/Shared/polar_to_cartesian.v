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
     output reg signed [8:0] x_value, // 1 for sign and 7 for the value as the sin could be a 1 theoretically
     output reg signed [8:0] y_value);
   
	parameter POS = 1'b0;
	parameter NEG = 1'b1;
	
   // use helper module to do the math
   wire [7:0] rsin_15;
   wire [7:0] rsin_45;
   wire [7:0] rsin_75;
   // we don't need the other outputs so we will allow them to be attached to nothing
   calc_rsin_15_165_30 helper (.r(r_theta[7:0]),.rsin_15(rsin_15),.rsin_45(rsin_45),.rsin_75(rsin_75));
   
   always @(*) begin
      // use a case statement to continuously assign the correct value to the output
      // note right now when we are doing the 15 + 30n up to 165 we have 6 different possible angles
      // but note that the theta is defined in 15 degree incriments and so we need to check on the right values
      case (r_theta[11:8])
         4'h1: begin // 15deg
            x_value = {POS,rsin_75}; 
            y_value = {POS,rsin_15};
         end
         4'h3: begin // 45deg
            x_value = {POS,rsin_45}; 
            y_value = {POS,rsin_45};
         end
         4'h5: begin // 75deg
            x_value = {POS,rsin_15}; 
            y_value = {POS,rsin_75};
         end
         4'h7: begin // 105deg
            x_value = {NEG,rsin_15}; 
            y_value = {POS,rsin_75};
         end
         4'h9: begin // 135deg
            x_value = {NEG,rsin_45}; 
            y_value = {POS,rsin_45};
         end
         default: begin // 165deg
            x_value = {NEG,rsin_75}; 
            y_value = {POS,rsin_15};
         end
      endcase
   end

endmodule
