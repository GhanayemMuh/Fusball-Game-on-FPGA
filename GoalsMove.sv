module GoalsMove (

			input logic clk,
			input logic resetN,
			input logic [1:0] Level,
			input logic startOfFrame,
			
			// output	 logic signed 	[10:0] topLeftX,
			output	 logic signed 	[10:0] topLeftY_teamGoal,
			output	 logic signed  [10:0] topLeftY_oppGoal,
			output	 int firstYgoalOffset_team,
			output    int secondYgoalOffset_team,
			output	 int firstYgoalOffset_opp,
			output    int secondYgoalOffset_opp

);
logic signed [10:0] counter_team = 0;
logic signed [10:0] counter_opp = 0;
logic teamgoal_up;
parameter int MAX_TOP = 255;
parameter int MAX_BOTTOM = 155;
parameter logic [10:0] speed = 1;
int firstY_team = 205;
int secondY_team = 269;
int firstY_opp = 205;
int secondY_opp = 269;

always_ff@(posedge clk or negedge resetN) 
begin
	if(!resetN) begin
		counter_team <= 205;
		counter_opp <= 205;
		teamgoal_up <= 1'b0;
		firstY_team <= 205;
		secondY_team <= 269;
		firstY_opp <= 205;
		secondY_opp <= 269;
	end
	else begin
		if(startOfFrame) begin	
			if (Level == 2'b11) begin
				case (teamgoal_up) 
					1'b0 : begin
						counter_team <= counter_team - speed;
						counter_opp <= counter_opp + speed;
						firstY_team <= firstY_team - speed;
						secondY_team <= secondY_team - speed;
						firstY_opp <= firstY_opp + speed;
						secondY_opp <= secondY_opp + speed;
						if (counter_team <= MAX_BOTTOM)
							teamgoal_up <= 1'b1;
					end
					
					1'b1: begin
						counter_team <= counter_team + speed;
						counter_opp <= counter_opp - speed;
						firstY_team <= firstY_team + speed;
						secondY_team <= secondY_team + speed;
						firstY_opp <= firstY_opp - speed;
						secondY_opp <= secondY_opp - speed;
						if (counter_team >= MAX_TOP)
							teamgoal_up <= 1'b0;
					end
				endcase
			end
			
			topLeftY_teamGoal <= counter_team;
			topLeftY_oppGoal <= counter_opp;
			firstYgoalOffset_team <= firstY_team;
			secondYgoalOffset_team <= secondY_team;
			firstYgoalOffset_opp <= firstY_opp;
			secondYgoalOffset_opp <= secondY_opp;
		end
	end	 
end //always_ff	

endmodule