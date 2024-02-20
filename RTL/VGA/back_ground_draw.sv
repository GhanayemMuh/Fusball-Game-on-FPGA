//-- feb 2021 add all colors square 
// (c) Technion IIT, Department of Electrical Engineering 2021


module	back_ground_draw	(	

					input	logic	clk,
					input	logic	resetN,
					input 	logic	[10:0]	pixelX,
					input 	logic	[10:0]	pixelY,
					input int firstYgoalOffset_team,
					input int secondYgoalOffset_team,
					input int firstYgoalOffset_opp,
					input int secondYgoalOffset_opp,

					output	logic	[7:0]	BG_RGB,
					output	logic		boardersDrawReq, 
					output	logic		teamGoalDrawReq,
					output	logic		oppGoalDrawReq
);

const int	xFrameSize	=	635;
const int	yFrameSize	=	475;
const int	bracketOffset =	30;
const int   firstYgoalOffset = 205;
const int	secondYgoalOffset = 269;
const int	firstXgoalOffset = 0;
const int	secondXgoalOffset = 603;
const int	goalWidth = 32;
const int	fixedMiddleXpoint = 315;
const int   fixedMiddleYpoint = 230;
const int 	fixedMiddleofBox_Ypoint = 237;
const int   COLOR_MARTIX_SIZE  = 16*8 ; // 128 \

logic [2:0] redBits;
logic [2:0] greenBits;
logic [1:0] blueBits;
logic [10:0] shift_pixelX;

localparam logic [2:0] DARK_COLOR = 3'b111 ;// bitmap of a dark color
localparam logic [2:0] LIGHT_COLOR = 3'b000 ;// bitmap of a light color

 
localparam  int RED_TOP_Y  = 156 ;
localparam  int RED_LEFT_X  = 256 ;
localparam  int GREEN_RIGHT_X  = 32 ;
localparam  int BLUE_BOTTOM_Y  = 300 ;
localparam  int BLUE_RIGHT_X  = 200 ;
 
parameter  logic [10:0] COLOR_MATRIX_TOP_Y  = 100 ; 
parameter  logic [10:0] COLOR_MATRIX_LEFT_X = 100 ;

 

// this is a block to generate the background 
//it has four sub modules : 

	// 1. draw the yellow borders
	// 2. draw four lines with "bracketOffset" offset from the border 
	// 3.  draw red rectangle at the bottom right,  green on the left, and blue on top left 
	// 4. draw a matrix of 16*16 rectangles with all the colors, each rectsangle 8*8 pixels  	

 
 
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
				redBits <= DARK_COLOR ;	
				greenBits <= DARK_COLOR  ;	
				blueBits <= DARK_COLOR ;	 
	end 
	else begin

	// defaults 
		greenBits <= 3'b110 ; 
		redBits <= 3'b010 ;
		blueBits <= LIGHT_COLOR;
		boardersDrawReq <= 	1'b0 ;
		oppGoalDrawReq <= 1'b0;
		teamGoalDrawReq <= 1'b0;

		
		

					
	// draw the yellow borders 
		/*if (pixelX == 0 || pixelY == 0  || pixelX == xFrameSize || pixelY == yFrameSize)
			begin 
				redBits <= DARK_COLOR ;	
				greenBits <= DARK_COLOR ;	
				blueBits <= LIGHT_COLOR ;	// 3rd bit will be truncated
			end */
		/*DRAW FIELD LINES*/ 
		if (       (pixelX == bracketOffset && (pixelY > bracketOffset && pixelY < firstYgoalOffset_opp)) ||
					  (pixelX == bracketOffset && (pixelY > secondYgoalOffset_opp && pixelY < yFrameSize - bracketOffset)) ||
					  (pixelY == bracketOffset && (pixelX > bracketOffset && pixelX <xFrameSize - bracketOffset)) ||
					  (pixelX == xFrameSize-bracketOffset && (pixelY > bracketOffset && pixelY < firstYgoalOffset_team))||
					  (pixelX == xFrameSize-bracketOffset && (pixelY > secondYgoalOffset_team && pixelY < yFrameSize - bracketOffset)) || 
					  (pixelY == yFrameSize-bracketOffset && (pixelX > bracketOffset && pixelX <xFrameSize - bracketOffset)) 
			)
			begin 
					redBits <= DARK_COLOR ;	
					greenBits <= DARK_COLOR  ;	
					blueBits <= DARK_COLOR ;
					boardersDrawReq <= 	1'b1 ; // pulse if drawing the boarders 
			end /*END OF DRAWING FIELD LINES*/
		//---------------------------------------------------------------------------------------------------------------------------------	
		if (pixelX < bracketOffset || pixelX > xFrameSize - bracketOffset || pixelY < bracketOffset || pixelY > yFrameSize - bracketOffset)
		begin
			redBits <= 3'b000;
			greenBits <= 3'b000;
			blueBits <= 2'b00;
		end
		else
			greenBits <= 3'b011 ; 

			
		//----------------------------------------------------------------------------------------------------------------------------------	
		/*DRAW LINES INSIDE THE GOALS SO THE BALL DOESN'T SURF INTO SPACE
		AND TO DETERMINE WHEN A GOAL IS SCORED AND BY WHO*/	
		if (		  (pixelY == firstYgoalOffset_team && (pixelX >= secondXgoalOffset && pixelX < secondXgoalOffset + goalWidth)) ||
					  (pixelY == secondYgoalOffset_team && (pixelX >= secondXgoalOffset && pixelX < secondXgoalOffset + goalWidth))
		   )
			/*DRAWS 2 PARALLEL Y LINES INSIDE TEAM GOAL */
			begin
				redBits <= 3'b000;
				greenBits <= 3'b000;
				blueBits <= 2'b00;
				boardersDrawReq <= 	1'b1 ;
			end
		if (pixelX == 632 && (pixelY > firstYgoalOffset_team && pixelY < secondYgoalOffset_team))
			/*DRAW A LINES REPRESENTING THE BACK OF OUR TEAM GOAL.*/
			begin
				teamGoalDrawReq <= 1'b1 ;
				redBits <= 3'b000;
				greenBits <= 3'b000;
				blueBits <= 2'b00;
				
			end
		if (		  (pixelY == firstYgoalOffset_opp && (pixelX > firstXgoalOffset && pixelX <= firstXgoalOffset + goalWidth)) ||
					  (pixelY == secondYgoalOffset_opp && (pixelX > firstXgoalOffset && pixelX <= firstXgoalOffset + goalWidth))
			)
			/*DRAW 2 PARALLEL Y LINES INSIDE OPPONENT GOAL.*/
			begin
				redBits <= 3'b000;
				greenBits <= 3'b000;
				blueBits <= 2'b00;
				boardersDrawReq <= 	1'b1 ;
					
			end
			
		if (pixelX == 5 && (pixelY > firstYgoalOffset_opp && pixelY < secondYgoalOffset_opp))
			/*DRAW A LINES REPRESENTING THE BACK OF OPPONENT GOAL.*/
			begin
				oppGoalDrawReq <= 1'b1 ;
				redBits <= 3'b000;
				greenBits <= 3'b000;
				blueBits <= 2'b00;
			end 
		//----------------------------------------------------------------------------------------------------------------------------------	
		/*DRAW GOAL BOXES */
		if ((pixelY == firstYgoalOffset_opp - 10 || pixelY == secondYgoalOffset_opp + 10) && (pixelX >= firstXgoalOffset + goalWidth) && (pixelX < firstXgoalOffset + goalWidth + 20)) 
			begin
				redBits <= DARK_COLOR ;	
				greenBits <= DARK_COLOR  ;	
				blueBits <= DARK_COLOR ;	
			end // draw 2 parallel Y lines for opponent goal.
		if ((pixelX == firstXgoalOffset + goalWidth + 20) && (pixelY >= firstYgoalOffset_opp - 10 && pixelY<= secondYgoalOffset_opp + 10))
			begin
				redBits <= DARK_COLOR ;	
				greenBits <= DARK_COLOR  ;	
				blueBits <= DARK_COLOR ;
			end // draw 1 X parallel line for opponent goal.
		if ((pixelY == firstYgoalOffset_team - 10 || pixelY == secondYgoalOffset_team + 10) && (pixelX <= secondXgoalOffset) && (pixelX > secondXgoalOffset - 20)) 
			begin
				redBits <= DARK_COLOR ;	
				greenBits <= DARK_COLOR  ;	
				blueBits <= DARK_COLOR ;	
			end // draw 2 parallel Y lines for team goal.
		if ((pixelX == secondXgoalOffset - 20) && (pixelY >= firstYgoalOffset_team - 10 && pixelY<= secondYgoalOffset_team + 10))
			begin
				redBits <= DARK_COLOR ;	
				greenBits <= DARK_COLOR  ;	
				blueBits <= DARK_COLOR ;
			end // draw 1 X parallel line for team goal.
			
			if ((pixelY == firstYgoalOffset_opp - 50 || pixelY == secondYgoalOffset_opp + 50) && (pixelX >= firstXgoalOffset + goalWidth) && (pixelX < firstXgoalOffset + goalWidth + 60)) 
			begin
				redBits <= DARK_COLOR ;	
				greenBits <= DARK_COLOR  ;	
				blueBits <= DARK_COLOR ;	
			end // draw 2 parallel Y lines for opponent goal.
		if ((pixelX == firstXgoalOffset + goalWidth + 60) && (pixelY >= firstYgoalOffset_opp - 50 && pixelY<= secondYgoalOffset_opp + 50))
			begin
				redBits <= DARK_COLOR ;	
				greenBits <= DARK_COLOR  ;	
				blueBits <= DARK_COLOR ;
			end // draw 1 X parallel line for opponent goal.
		if ((pixelY == firstYgoalOffset_team - 50 || pixelY == secondYgoalOffset_team + 50) && (pixelX <= secondXgoalOffset) && (pixelX > secondXgoalOffset - 60)) 
			begin
				redBits <= DARK_COLOR ;	
				greenBits <= DARK_COLOR  ;	
				blueBits <= DARK_COLOR ;	
			end // draw 2 parallel Y lines for team goal.
		if ((pixelX == secondXgoalOffset - 60) && (pixelY >= firstYgoalOffset_team - 50 && pixelY<= secondYgoalOffset_team + 50))
			begin
				redBits <= DARK_COLOR ;	
				greenBits <= DARK_COLOR  ;	
				blueBits <= DARK_COLOR ;
			end // draw 1 X parallel line for team goal.
		//----------------------------------------------------------------------------------------------------------------------------	
		/*DRAW BOTH PENALTY SPOTS.*/
		if ((pixelY == firstYgoalOffset_opp + 32 || pixelY == firstYgoalOffset_opp + 33) && (pixelX == 72 || pixelX == 73))
			begin
				redBits <= DARK_COLOR ;	
				greenBits <= DARK_COLOR  ;	
				blueBits <= DARK_COLOR ;
			end // for opp. 
		if ((pixelY == firstYgoalOffset_team + 32 || pixelY == firstYgoalOffset_team + 33) && (pixelX == 563 || pixelX == 562))
			begin
				redBits <= DARK_COLOR ;	
				greenBits <= DARK_COLOR  ;	
				blueBits <= DARK_COLOR ;
			end // for team
		//------------------------------------------------------------------------------------------------------------------------------
		/*DRAW MIDDLE PITCH LINE AND CIRCLE*/
		if ((pixelX == fixedMiddleXpoint) && (pixelY > bracketOffset && pixelY < yFrameSize - bracketOffset))
			begin
				redBits <= DARK_COLOR ;	
				greenBits <= DARK_COLOR  ;	
				blueBits <= DARK_COLOR ;
			end // draw a parallel X line in the middle of the screen.
		
		if ((pixelX - fixedMiddleXpoint)**2 + (pixelY - fixedMiddleYpoint)**2 <= 2500)
			begin
				redBits <= DARK_COLOR ;	
				greenBits <= DARK_COLOR  ;	
				blueBits <= DARK_COLOR ;
			end // draw a cicle in the  middle of the pitch.
		//------------------------------------------------------------------------------------------------------------------------------
			
			
		if ((pixelY == firstYgoalOffset_opp - 50 || pixelY == secondYgoalOffset_opp + 50) && (pixelX >= firstXgoalOffset + goalWidth) && (pixelX < firstXgoalOffset + goalWidth + 60)) 
			begin
				redBits <= DARK_COLOR ;	
				greenBits <= DARK_COLOR  ;	
				blueBits <= DARK_COLOR ;	
			end // draw 2 parallel Y lines for opponent goal.
		if ((pixelX == firstXgoalOffset + goalWidth + 60) && (pixelY >= firstYgoalOffset_opp - 50 && pixelY<= secondYgoalOffset_opp + 50))
			begin
				redBits <= DARK_COLOR ;	
				greenBits <= DARK_COLOR  ;	
				blueBits <= DARK_COLOR ;
			end // draw 1 X parallel line for opponent goal.
		if ((pixelY == firstYgoalOffset_team - 50 || pixelY == secondYgoalOffset_team + 50) && (pixelX <= secondXgoalOffset) && (pixelX > secondXgoalOffset - 60)) 
			begin
				redBits <= DARK_COLOR ;	
				greenBits <= DARK_COLOR  ;	
				blueBits <= DARK_COLOR ;	
			end // draw 2 parallel Y lines for team goal.
		if ((pixelX == secondXgoalOffset - 60) && (pixelY >= firstYgoalOffset_team - 50 && pixelY<= secondYgoalOffset_team + 50))
			begin
				redBits <= DARK_COLOR ;	
				greenBits <= DARK_COLOR  ;	
				blueBits <= DARK_COLOR ;
			end // draw 1 X parallel line for team goal.

		
		
	// END OF DRAWING *all* LINES FOR THE GOALS.


	
	// 3.  draw red rectangle at the bottom right,  green on the left, and blue on top left 
	//-------------------------------------------------------------------------------------
		
		//if (pixelY > RED_TOP_Y && pixelX >= RED_LEFT_X ) // rectangles on part of the screen 
				//redBits <= DARK_COLOR ; 
				 
	
		//if (pixelX <  GREEN_RIGHT_X  ) 
						
		//if (pixelX <  BLUE_RIGHT_X && pixelY < BLUE_BOTTOM_Y )   
					//blueBits <= 2'b10  ; 

				

	// 4. draw a matrix of 16*16 rectangles with all the colors, each rectsangle 8*8 pixels  	
   // ---------------------------------------------------------------------------------------
		/* if (( pixelY > 8 ) && (pixelY < 24 ) && (pixelX >30 )&& (pixelX <542 ))
		 begin
		        shift_pixelX<= pixelX-29;

             blueBits <= shift_pixelX[2:1] ; 
				 greenBits <= shift_pixelX[5:3] ; 
				 redBits <= shift_pixelX[8:6]; 
					
	
				
		 end */ 
		
//		if ((pixelX > COLOR_MATRIX_LEFT_X)  && (pixelX < COLOR_MATRIX_LEFT_X + COLOR_MARTIX_SIZE) 
//		&& ( pixelY > COLOR_MATRIX_TOP_Y) && (pixelY < COLOR_MATRIX_TOP_Y + COLOR_MARTIX_SIZE )) 
//		begin
//			 redBits <= pixelX[5:3] ; 
//			greenBits <= pixelY[5:3] ; 
//			blueBits <= { pixelX[6] , pixelY[6]} ; 
//			
//
//    
//				
//		end	

		
	BG_RGB =  {redBits , greenBits , blueBits} ; //collect color nibbles to an 8 bit word 
			


	end; 	
end 
endmodule

