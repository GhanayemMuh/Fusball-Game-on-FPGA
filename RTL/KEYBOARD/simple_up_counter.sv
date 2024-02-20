// (c) Technion IIT, Department of Electrical Engineering  2021

// Implements a simple up-counter for demonstration purposes only


module simple_up_counter 
	(
   // Input, Output Ports
   input logic clk, 
   input logic resetN,
	input logic one_sec,
	
	
   output logic [3:0] firstSecondsDig,
	output logic [3:0] secondSecondsDig,
	output logic [3:0] minutesDig,
	output logic game_over
   );
	
	 
   always_ff @( posedge clk or negedge resetN )
   begin
      
      if ( !resetN ) begin // Asynchronic reset
			game_over <= 1'b0;
			firstSecondsDig <= 0;
			secondSecondsDig <= 0;
			minutesDig <= 2;
		end
      else 	begin			// Synchronic logic	
			if (!game_over) begin
				if (firstSecondsDig == 0) begin
					if(secondSecondsDig == 0) begin
						if(minutesDig == 0) begin
							game_over <= 1'b1;
						end // finished Counting
						
						else begin
							minutesDig <= minutesDig - 1;
							secondSecondsDig <= 5;
							firstSecondsDig <= 9;
						end // not finished Counting
						
					end // secondSecondsDig == 0
					
					else begin
						firstSecondsDig <= 9;
						secondSecondsDig <= secondSecondsDig - 1;
					end // secondSecondsDig != 0
					
				end // firstSecondsDig == 0
				
				else begin
					firstSecondsDig <= firstSecondsDig - 1;
				end
			end // !game_over
		end // main else
	 end // always
	 
endmodule

