`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        MIT 6.111 Final Project
// Engineer:       Brian Plancher
// 
// Module Name:    Polar to Cartesian
// Project Name:   FPGA Phone Home
//
// Notes: this relies on only using 12 angles values of 0deg + 15n up to 180
//        if you want to use more or different angles you need to update the code
//
//////////////////////////////////////////////////////////////////////////////////

module polar_to_cartesian
    (input [11:0] r_theta, // r is [7:0] theta is [11:8]
     output reg signed [8:0] x_value, // 1 for sign and 7 for the value as the sin could be a 1 theoretically
     output reg signed [8:0] y_value);
   
	parameter POS = 1'b0;
	parameter NEG = 1'b1;
   parameter ZERO = 8'h00;
	
   // do the math
   // sin 15 = cos 75 = sin 165 = - cos 105 // is about 66/256
   // sin 30 = cos 60 = sin 150 = - cos 120 // is exactly 1/2 
   // sin 45 = cos 45 = sin 135 = - cos 135 // is about 181/256
   // sin 60 = cos 30 = sin 120 = - cos 150 // is about 222/256
   // sin 75 = cos 15 = sin 105 = - cos 165 // is about 247/256
   wire [31:0] rsin_15deg; // large bit size to multiply and shift
   wire [31:0] rsin_30deg; // large bit size to multiply and shift
   wire [31:0] rsin_45deg; // large bit size to multiply and shift
   wire [31:0] rsin_60deg; // large bit size to multiply and shift
   wire [31:0] rsin_75deg; // large bit size to multiply and shift   
   assign rsin_15deg = (r_theta[7:0]*66) >> 8;  
   assign rsin_30deg = r_theta[7:0] >> 2;  
   assign rsin_45deg = (r_theta[7:0]*181) >> 8;             
   assign rsin_60deg = (r_theta[7:0]*222) >> 8;  
   assign rsin_75deg = (r_theta[7:0]*247) >> 8;
   
   always @(*) begin
      // use a case statement to continuously assign the correct value to the output
      // note right now when we are doing the 15 + 30n up to 165 we have 6 different possible angles
      // but note that the theta is defined in 15 degree incriments and so we need to check on the right values
		// also note that after the math only the lower 8 bits can possibly matter anyway so
		// nothing is lost in the math
      case (r_theta[11:8])
         4'h1: begin // 15deg
            x_value = {POS,rsin_75deg[7:0]}; 
            y_value = {POS,rsin_15deg[7:0]};
         end
         4'h2: begin // 30deg
            x_value = {POS,rsin_60deg[7:0]}; 
            y_value = {POS,rsin_30deg[7:0]};
         end
         4'h3: begin // 45deg
            x_value = {POS,rsin_45deg[7:0]}; 
            y_value = {POS,rsin_45deg[7:0]};
         end
         4'h4: begin // 60deg
            x_value = {POS,rsin_30deg[7:0]}; 
            y_value = {POS,rsin_60deg[7:0]};
         end
         4'h5: begin // 75deg
            x_value = {POS,rsin_15deg[7:0]}; 
            y_value = {POS,rsin_75deg[7:0]};
         end
         4'h6: begin // 90deg
            x_value = {POS,ZERO}; 
            y_value = {POS,r_theta[7:0]};
         end
         4'h7: begin // 105deg
            x_value = {NEG,rsin_15deg[7:0]}; 
            y_value = {POS,rsin_75deg[7:0]};
         end
         4'h8: begin // 120deg
            x_value = {NEG,rsin_30deg[7:0]}; 
            y_value = {POS,rsin_60deg[7:0]};
         end
         4'h9: begin // 135deg
            x_value = {NEG,rsin_45deg[7:0]}; 
            y_value = {POS,rsin_45deg[7:0]};
         end
         4'hA: begin // 150deg
            x_value = {NEG,rsin_60deg[7:0]}; 
            y_value = {POS,rsin_30deg[7:0]};
         end
         4'hB: begin // 165deg
            x_value = {NEG,rsin_75deg[7:0]}; 
            y_value = {POS,rsin_15deg[7:0]};
         end
         4'hC: begin // 180deg
            x_value = {NEG,r_theta[7:0]}; 
            y_value = {POS,ZERO};
         end
         default: begin // 0deg
            x_value = {POS,r_theta[7:0]}; 
            y_value = {POS,ZERO};
         end
      endcase
   end

endmodule
