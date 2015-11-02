///////////////////////////////////////////////////////////////////////////////
// A programmable timer with 75us increments. When start_timer is asserted,
// the timer latches length, and asserts expired for one clock cycle 
// after 'length' 75us intervals have passed. e.g. if length is 10, timer will
// assert expired after 750us.
// Updated November 1, 2015 - added in parameter for multiple clock driving output (Brian Plancher)
///////////////////////////////////////////////////////////////////////////////
module timer   #(parameter COUNT_GOAL=2024) // set for 27mhz clock (for 25mhz clock use 1875)
				(input wire clk,
				 input wire reset,
				 input wire start_timer,
				 input wire [9:0] length,
				 output wire expired);
  
  wire enable;
  divider_600us sc #(.COUNT_GOAL(COUNT_GOAL))
					(.clk(clk),.reset(start_timer),.enable(enable));
  reg [9:0] count_length;
  reg [9:0] count;
  reg counting;
  
  always@(posedge clk) 
  begin
	 if (reset)
		counting <= 0;
	 else if (start_timer) 
	 begin
		count_length <= length;
		count <= 0;
		counting <= 1;
	 end
	 else if (counting && enable)
		count <= count + 1;
	 else if (expired)
		counting <= 0;
  end
  
  assign expired = (counting && (count == count_length));
endmodule	