// (c) Technion IIT, Department of Electrical Engineering 2021 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018
// updaed Eyal Lev Feb 2021


module	ballMovement	(	
 
					input	logic	clk,
					input	logic	resetN,
					input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
					input	logic	Y_direction,  //change the direction in Y to up  
					input	logic	toggleX, 	//toggle the X direction 
					input logic collision,  //collision if smiley hits an object
					input logic collisionWithTeamPlayers, // collision if ball hits the players.
					input logic Key_2_is_pressed,	// 1 when key 2 is pressed
					input logic Key_4_is_pressed, // 1 when key 4 is pressed
					input logic Key_6_is_pressed, // 1 when key 6 is pressed
					input logic Key_8_is_pressed,	// 1 when key 8 is pressed
					input	logic	[3:0] HitEdgeCode, //one bit per edge
					input logic [1:0] goalWasScored, // 1 when teamGoal scored, 2 when oppGoal scored, 0 otherwise.
					input logic key6WasReleased, 
					input logic oppKey6WasReleased, // artificial key releasing used in oppTeamMove module.
					input logic oppKey_6_is_pressed, // arrtificial key pressing used in oppTeamMove module.
					input logic collisionWithOppPlayers,
					input logic key4WasReleased,
					input logic max_rotate6,
					
					output	 logic signed 	[10:0]	topLeftX, // output the top left corner 
					output	 logic signed	[10:0]	topLeftY,  // can be negative , if the object is partliy outside 
					output	 logic signed  [10:0]   BallXSpeed
);

// a module used to generate the  ball trajectory.  

parameter int INITIAL_X = 280;
parameter int INITIAL_Y = 185;
parameter int INITIAL_X_SPEED = 150;
parameter int INITIAL_Y_SPEED = 150;
parameter int MAX_Y_SPEED = 300;
parameter int MAX_X_SPEED = 300;
parameter int Y_ACCEL = 1;
parameter int X_ACCEL = 1;

const int	FIXED_POINT_MULTIPLIER	=	64;
// FIXED_POINT_MULTIPLIER is used to enable working with integers in high resolution so that 
// we do all calculations with topLeftX_FixedPoint to get a resolution of 1/64 pixel in calcuatuions,
// we devide at the end by FIXED_POINT_MULTIPLIER which must be 2^n, to return to the initial proportions
const int	x_FRAME_SIZE	=	639 * FIXED_POINT_MULTIPLIER; // note it must be 2^n 
const int	y_FRAME_SIZE	=	479 * FIXED_POINT_MULTIPLIER;
const int	bracketOffset =	30;
const int   OBJECT_WIDTH_X = 64;

int Xspeed, topLeftX_FixedPoint; // local parameters 
int Yspeed, topLeftY_FixedPoint;
int AccelCount = 0; //AccelCount
int ballExtraSpeed = 0;
int simultCollAndKeyRel = 0;
int counter = 0;
int key6IsPressedFlag = 0;

//////////--------------------------------------------------------------------------------------------------------------=
//  calculation 0f Y Axis speed using gravity or colision

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin 
		Yspeed	<= INITIAL_Y_SPEED;
		topLeftY_FixedPoint	<= INITIAL_Y * FIXED_POINT_MULTIPLIER;
		Xspeed	<= INITIAL_X_SPEED;
		topLeftX_FixedPoint	<= INITIAL_X * FIXED_POINT_MULTIPLIER;
		simultCollAndKeyRel <= 0;
		ballExtraSpeed <= 0;
	end 
	
	else begin
		//collision with edges
		if (collision && Xspeed > 0 && Yspeed >= 0 && HitEdgeCode == 2) // hits right while moving downwards
			Xspeed <= -Xspeed;
			
		else if (collision && Xspeed > 0 && Yspeed <= 0 && HitEdgeCode == 2) // hits right while moving upwards
			Xspeed <= -Xspeed;
			
		else if (collision && Xspeed < 0 && Yspeed >= 0 && HitEdgeCode == 8) // hits left while moving downwards
			Xspeed <= -Xspeed;
		
		else if (collision && Xspeed < 0 && Yspeed <= 0 && HitEdgeCode == 8) // hits left while moving upwards
			Xspeed <= -Xspeed;
			
		else if (collision && Xspeed > 0 && Yspeed <= 0 && HitEdgeCode == 4) // hits top while moving upwards-right
			Yspeed <= -Yspeed;
			
		else if (collision && Xspeed < 0 && Yspeed <= 0 && HitEdgeCode == 4) // hits top while moving upwards-left
			Yspeed <= -Yspeed;
			
		else if (collision && Xspeed > 0 && Yspeed >= 0 && HitEdgeCode == 1) // hits bottom while moving downwards-right
			Yspeed <= -Yspeed;
			
		else if (collision && Xspeed < 0 && Yspeed > 0 && HitEdgeCode == 1) // hits bottom while moving downwards-left
			Yspeed <= -Yspeed;
	
		
		else if(simultCollAndKeyRel == 1) begin 
			Xspeed <= Xspeed;
			Yspeed <= Yspeed;
				counter <= counter + 1;
				if (counter == 20000) begin
					simultCollAndKeyRel <= 0;
				end
		end //simultCollAndKeyRel == 1
		
		/*ADDING SPEED TO BALL WHEN OPPONENT KICKS THE BALL*/
		else if (collisionWithOppPlayers && oppKey6WasReleased) begin
			//increment Xspeed
			topLeftX_FixedPoint <= topLeftX_FixedPoint + 1000;
			if(Xspeed < 0 && (Xspeed - 80 < -MAX_X_SPEED)) begin
				Xspeed <= -MAX_X_SPEED;
			end
			else if (Xspeed < 0) begin
				Xspeed <= Xspeed - 80;
			end
			else if(Xspeed > 0 && (Xspeed + 80 > MAX_X_SPEED)) begin
				Xspeed <= -MAX_X_SPEED;
			end	
			else if (Xspeed > 0) begin
				Xspeed <= -Xspeed - 80;
			end
			
			//increment Yspeed
			if(Yspeed < 0 && (Yspeed - 80 < -MAX_Y_SPEED)) begin
				Yspeed <= MAX_Y_SPEED;
			end
			else if (Yspeed < 0) begin
				Yspeed <= -Yspeed + 80;
			end
			else if (Yspeed > 0 && (Yspeed + 80 > MAX_Y_SPEED)) begin
				Yspeed <= -MAX_Y_SPEED;
			end
			else if (Yspeed > 0) begin
				Yspeed <= -Yspeed - 80;
			end
		end // end of adding speed to the ball when opp kicks it.
	
		
		else if ((collisionWithTeamPlayers && key6WasReleased)) begin
			if (simultCollAndKeyRel == 0) begin
				simultCollAndKeyRel <= 1;
				key6IsPressedFlag <= 0; 
				counter <= 0;
			end
			
			//increment Xspeed
			if(Xspeed < 0 && (Xspeed - ballExtraSpeed < -MAX_X_SPEED)) begin
				Xspeed <= -MAX_X_SPEED;
			end
			else if (Xspeed < 0) begin
				Xspeed <= Xspeed - ballExtraSpeed;
			end
			else if(Xspeed > 0 && (Xspeed + ballExtraSpeed > MAX_X_SPEED)) begin
				Xspeed <= -MAX_X_SPEED;
			end	
			else if (Xspeed > 0) begin
				Xspeed <= -Xspeed - ballExtraSpeed;
			end
			
			//increment Yspeed
			if(Yspeed < 0 && (Yspeed - ballExtraSpeed < -MAX_Y_SPEED)) begin
				if ( Yspeed % 2 == 0) begin
					Yspeed <= MAX_Y_SPEED;
				end
				else
					Yspeed <= -MAX_Y_SPEED;
			end
			else if (Yspeed < 0) begin
				if (Yspeed % 2 == 0)
					Yspeed <= -Yspeed + ballExtraSpeed;
				else
					Yspeed <= Yspeed - ballExtraSpeed;
			end
			else if (Yspeed > 0 && (Yspeed + ballExtraSpeed > MAX_Y_SPEED)) begin
				if (Yspeed % 2 == 0)
					Yspeed <= -MAX_Y_SPEED;
				else
					Yspeed <= MAX_Y_SPEED;
			end
			else if (Yspeed > 0) begin
				if ( Yspeed % 2 == 0) begin
					Yspeed <= -Yspeed - ballExtraSpeed;
				end
				else
					Yspeed <= Yspeed + ballExtraSpeed;
			end
			
			ballExtraSpeed <= 0;
		end //end of collisionWithPlayers && key6WasReleased
		
		else if ((collisionWithTeamPlayers && (Key_6_is_pressed || Key_4_is_pressed)) || (collisionWithOppPlayers && oppKey_6_is_pressed)) begin 
			Xspeed <= Xspeed;
			Yspeed <= Yspeed;
		end
		
		else if (collisionWithTeamPlayers && Key_8_is_pressed && Yspeed >= 0 && !collision) begin
			Yspeed <= -Yspeed;
			if(Xspeed > 0) begin
				Xspeed <= -Xspeed;
			end
		end
		else if (collisionWithTeamPlayers && Key_8_is_pressed && Yspeed >= 0 && !collision) begin
			Yspeed <= -Yspeed;
			if(Xspeed > 0) begin
				Xspeed <= -Xspeed;
			end
		end
		else if (collisionWithTeamPlayers && Key_8_is_pressed && Yspeed <= 0 && !collision) begin

			Xspeed <= -Xspeed;
		end
		
		else if (collisionWithTeamPlayers && Key_2_is_pressed && Yspeed <= 0 && !collision) begin
			Yspeed <= -Yspeed;
			Xspeed <= -Xspeed;
		end
		else if (collisionWithTeamPlayers && Key_2_is_pressed && Yspeed >= 0 && !collision) begin
			Yspeed <= -Yspeed;
			if(Xspeed >= 0) begin
				Xspeed <= -Xspeed;
			end
		end
		
		else if ((collisionWithTeamPlayers && !Key_6_is_pressed) || collisionWithOppPlayers) begin
			Xspeed <= -Xspeed;
			Yspeed <= -Yspeed;
		end
		
		else begin//if (Key_6_is_pressed && !collisionWithPlayers) begin
			Xspeed <= Xspeed; 
			Yspeed <= Yspeed;
		end
		
		if(Key_6_is_pressed) begin
			key6IsPressedFlag <= 1; 
		end
		
		if (goalWasScored == 2'b01 || goalWasScored == 2'b10) begin
			topLeftX_FixedPoint <= 10000;
			topLeftY_FixedPoint <= 10000;
			Xspeed <= 160;
			Yspeed <= 150;
		end
		if (toggleX) begin
			topLeftX_FixedPoint <= 32300;
			topLeftY_FixedPoint <= 14300;
			Xspeed <= 10;
			Yspeed <= 10;
		end
		
		if (startOfFrame == 1'b1) begin
			AccelCount <= AccelCount + 1;
				topLeftX_FixedPoint  <= topLeftX_FixedPoint + Xspeed;		
				topLeftY_FixedPoint  <= topLeftY_FixedPoint + Yspeed; // position interpolation 
			if (AccelCount == 30) begin
					if (Yspeed <= MAX_Y_SPEED && Yspeed > 0 ) //  limit the spped while going down 
							Yspeed <= Yspeed  - Y_ACCEL ; // deAccelerate : slow the speed down every clock tick
					else if (Yspeed >= -MAX_Y_SPEED && Yspeed < 0 )
							Yspeed <= Yspeed + Y_ACCEL;
					if (Xspeed <= MAX_X_SPEED && Xspeed > 0 )
							Xspeed <= Xspeed - X_ACCEL;
					else if (Xspeed >= -MAX_X_SPEED && Xspeed < 0 )
							Xspeed <= Xspeed + X_ACCEL;			
				AccelCount <= 0;
				BallXSpeed <= Xspeed;
			end // end of Acceleration control
			
			if(key6IsPressedFlag == 1) begin
				ballExtraSpeed <= ballExtraSpeed + 1;
			end

		end // end of frame.
	end //end of clock
end // end of always_ff.

//get a better (64 times) resolution using integer   
assign 	topLeftX = topLeftX_FixedPoint / FIXED_POINT_MULTIPLIER ;   // note it must be 2^n 
assign 	topLeftY = topLeftY_FixedPoint / FIXED_POINT_MULTIPLIER ;    


endmodule
