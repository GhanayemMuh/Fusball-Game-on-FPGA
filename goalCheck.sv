module goalCheck (

input logic clk,
input logic resetN,
input logic [1:0] goalWasScored,
output int ourScore,
output int oppScore,
output logic [1:0] Level
);

/*Ball Parameters*/
parameter ballWidth = 32; 
parameter ballHeight = 64;

/*Goal parameters*/
parameter goalWidth = 32;
parameter goalHeight = 64;
parameter ourGoalX = 603;
parameter oppGoalX = 32;
parameter goalTopY = 205;
parameter goalBottomY = 269;



always_ff@(posedge clk or negedge resetN) begin
	if(!resetN) begin
		ourScore <= 0;
		oppScore <= 0;
		Level <= 2'b01;
	end // end !resetN.
	else begin
		
		if (goalWasScored == 2'b01) begin
			ourScore <= ourScore + 1;
			
		end // team goal scored.
		
		if (goalWasScored == 2'b10) begin
			oppScore <= oppScore + 1; 
		end // opp goal scoreed.
		
		if (goalWasScored && Level != 2'b11)
			Level <= Level + 1;
	end // end of main begin.
end // end ff.



endmodule // module end.