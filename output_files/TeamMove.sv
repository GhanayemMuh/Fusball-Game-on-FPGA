module TeamMove (

			input logic clk,
			input logic resetN,
			input	logic	startOfFrame,
			input logic key8IsPressed,
			input logic key2IsPressed,
			
			// output	 logic signed 	[10:0] topLeftX,
			output	 logic signed 	[10:0] topLeftY_main,
			output	 logic signed  [10:0] topLeftY_top,
			output	 logic signed  [10:0] topLeftY_bottom

);
logic signed [10:0] counter_main = 0;
logic signed [10:0] counter_top = 0;
logic signed [10:0] counter_bottom = 0;
parameter  int OBJECT_HEIGHT_Y = 32;


always_ff@(posedge clk or negedge resetN) 
begin
	if(!resetN) begin
		counter_main <= 32;
		counter_top <= -32;
		counter_bottom <= 450;
	end
	else begin
	if(startOfFrame) begin
		if(key2IsPressed) begin
			counter_main <= counter_main + 4;
			counter_top <= counter_top + 4;
			counter_bottom <= counter_bottom + 4;
		end
		else if(key8IsPressed) begin
			counter_main <= counter_main - 4;
			counter_top <= counter_top - 4;
			counter_bottom <= counter_bottom - 4;
		end
		if(counter_main < -25) begin
			counter_main <= -25;
			counter_top <= -89;
			counter_bottom <= 390;
		end
		else if (counter_main + OBJECT_HEIGHT_Y > 120) begin
			counter_main <= 120 - OBJECT_HEIGHT_Y;
			counter_top <= 56 - OBJECT_HEIGHT_Y;
			counter_bottom <= 480 - OBJECT_HEIGHT_Y;
		end
	end //startOfFrame
	
	topLeftY_main <= counter_main;
	topLeftY_top <= counter_top;
	topLeftY_bottom <= counter_bottom;
	end 
end //always_ff	

endmodule