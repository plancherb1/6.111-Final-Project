`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:        MIT 6.111 Final Project
// Engineer:       Brian Plancher
// 
// Module Name:    Median_5
// Project Name:   FPGA Phone Home
//
//////////////////////////////////////////////////////////////////////////////////

module median_5
	(input [7:0] data1,
	 input [7:0] data2,
	 input [7:0] data3,
	 input [7:0] data4,
	 input [7:0] data5,
	 input clock,
	 input reset,
	 input enable,
	 output reg done,
	 output reg [7:0] median);
	
	wire [7:0] mid1;
	wire [7:0] mid2;
	wire [7:0] mid3;
	mid3_of5 mid3o5 (.data1(data1),
					     .data2(data2),
						  .data3(data3),
						  .data4(data4),
						  .data5(data5),
						  .mid1(mid1),
						  .mid2(mid2),
						  .mid3(mid3));
						 
	reg [19:0] mid1_sized;
	reg [19:0] mid2_sized;
	reg [19:0] mid3_sized;
	wire [19:0] median_big;
	median_3 m3 (.data1(mid1_sized),
					 .data2(mid2_sized),
					 .data3(mid3_sized),
					 .median(median_big));
	
	reg [4:0] state;
	parameter IDLE 	= 4'h0;
	parameter MID		= 4'h1;
	parameter MEDIAN 	= 4'h2;
	
	// synchronize on the clock
	always @(posedge clock) begin
		// if reset set back to default
		if (reset) begin
         state <= IDLE;
			done <= 0;
			median <= 8'h00;
			mid1_sized <= 20'h00000;
			mid2_sized <= 20'h00000;
			mid2_sized <= 20'h00000;
      end
		else begin
			// fsm to control the operation
         case (state)
            
            // calc mid values
            MID: begin
               state <= MEDIAN;
					mid1_sized <= {12'h000,mid1};
					mid2_sized <= {12'h000,mid2};
					mid3_sized <= {12'h000,mid3};
            end
				
				// calc median values
				MEDIAN: begin
					median <= median_big[7:0];
					done <= 1;
					state <= IDLE;
				end
				
				// default to idle
				default: begin
					// if enabled then run
					if (enable) begin
						state <= MID;
						done <= 0;
						mid1_sized <= 20'h00000;
						mid2_sized <= 20'h00000;
						mid2_sized <= 20'h00000;
					end
				end
				
			endcase
		end
	end
endmodule
