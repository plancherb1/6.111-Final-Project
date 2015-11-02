///////////////////////////////////////////////////////////////////////////////
// enable goes high every 75us, providing 8x oversampling for 
// 600us width signal (parameter: 27mhz clock: 2024, 25mhz clock: 1875)
// Updated November 1, 2015 - added in parameter for multiple clock driving output (Brian Plancher)
///////////////////////////////////////////////////////////////////////////////
module divider_600us #(parameter COUNT_GOAL=2024)
					  (input wire clk,
					   input wire reset,
					   output wire enable);

  reg [10:0] count;

  always@(posedge clk) 
  begin
	 if (reset)
		count <= 0;
	 else if (count == COUNT_GOAL)
		count <= 0;
	 else
		count <= count + 1;
  end
  assign enable = (count == COUNT_GOAL);  
endmodule 