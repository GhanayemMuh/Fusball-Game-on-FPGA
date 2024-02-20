module key6WasReleased (

		input logic clk, 
		input logic resetN, 
		input logic Key_6_is_pressed, 
		input logic oneSecCounter,
		input logic startOfFrame,
		
		output logic wasReleased
		
);

//local parameters
int pressed6 =0;
int counter = 0;

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		pressed6 <= 0;
		wasReleased <= 0; 
		counter <= 0;
	end
	
	else begin
		if(Key_6_is_pressed) begin
			pressed6 <= 1;
			wasReleased <= 0;
		end
		
		//!Key_6_is_pressed
		else begin
			if(pressed6 ==1) begin
				if(oneSecCounter == 0) begin
					wasReleased <= 1;
				end
				else begin
					counter <= counter + 1;
					if(counter == 2) begin
					//if(counter == 1) begin
						wasReleased <= 0;
						pressed6 <= 0;
					end
				end
			end //pressed6 = 1
			
			else begin
				wasReleased <= 0;
				counter <= 0;
			end
		end //!Key_6_is_pressed
	end
end //always_ff

endmodule