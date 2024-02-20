// (c) Technion IIT, Department of Electrical Engineering 2020 

// Implements a slow clock as an one-second counter
// Turbo input sets output 10 times faster
// Updated by Mor Dahan - January 2022

 
 module keyPressing_one_sec_counter     	
	(
   // Input, Output Ports
	input  logic clk, 
	input  logic resetN, 
	input  logic turbo,
	input  logic key6Pressed,
	input  logic key4Pressed,

	
	output logic max_rotate_6,
	output logic max_rotate_4
   );
	
	int oneSecCount ;
	int sec ;		 // gets either one seccond or Turbo top value
	logic [1:0] seconds;
// counter limit setting 
	
//       ----------------------------------------------	
	localparam oneSecVal = 26'd50_000_000; // for DE10 board un-comment this line 
//	localparam oneSecVal = 26'd20; // for quartus simulation un-comment this line 
//       ----------------------------------------------	
	
	assign  sec = turbo ? oneSecVal/10 : oneSecVal;  // it is legal to devide by 10, as it is done by the complier not by logic (actual transistors) 


	
   always_ff @( posedge clk or negedge resetN )
   begin
	
		// asynchronous reset
		if ( !resetN ) begin
			oneSecCount <= 26'd0;
			max_rotate_6 <= 1'b0;
			max_rotate_4 <= 1'b0;
			
		end // if reset
		
		// executed once every clock 	
		else begin
			if (key6Pressed) begin
				max_rotate_4 <= 1'b0;
				oneSecCount <= oneSecCount + 1;
				if(oneSecCount >= 5*sec)
					max_rotate_6 <= 1'b1;
				else 
					max_rotate_6 <= 1'b0;
			end
			else if (key4Pressed) begin
				max_rotate_6 <= 1'b0;
				oneSecCount <= oneSecCount + 1;
				if(oneSecCount >= 5*sec)
					max_rotate_4 <= 1'b1;
				else
					max_rotate_4 <= 1'b0;
			end
			else begin
				oneSecCount <= 26'd0;
				max_rotate_4 <= 1'b0;
				max_rotate_6 <= 1'b0;
			end
		end
	end // always
endmodule