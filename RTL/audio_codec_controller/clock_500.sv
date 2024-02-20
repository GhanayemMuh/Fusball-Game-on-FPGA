// ============================================================================
// Copyright (c) 2012 by Terasic Technologies Inc.
// ============================================================================
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altrea Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL or Verilog source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// ============================================================================
//           
//  Terasic Technologies Inc
//  9F., No.176, Sec.2, Gongdao 5th Rd, East Dist, Hsinchu City, 30070. Taiwan
//
//
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// ============================================================================
//
// Major Functions: I2C output data
//
// ============================================================================
//
// Revision History :
// ============================================================================
//   Ver  :| Author             :| Mod. Date :| Changes Made:
//   V1.0 :| Allen Wang         :| 03/24/10  :| Initial Revision
//   V3.0 :| Young       		  :| 01/05/13  :| version 12.1
// ============================================================================
//`define rom_size 6'd8
`define rom_size 6'd10  //Alex Grinshpun (algrin) Nov 2017
// May 2018 Sv version Alex Grinshpun
					
module CLOCK_500(

	input logic CLOCK_50,
	input logic rst_n,
	input logic NEXT_WORD,	
	input logic KEY0_EDGE,
	input logic MICROPHON_ON,
	
	output logic	[23:0]	DATA,
	output logic 			TRANSACTION_REQ,
	output logic CLOCK_500,
	output logic CLOCK_500_ena,	
	output logic CLOCK_SDAT_ena,			  
	output logic AUD_XCK,           // AUD_XCK
	output logic MICROPHON_LED

	);

//=======================================================                
logic  	[10:0]	COUNTER_500;
logic  	[15:0]	ROM[`rom_size:0];
logic  	[15:0]	DATA_A;
logic  	[5:0]		address;
logic		CLOCK_SDAT;

logic		CLOCK_500_del;
logic		CLOCK_SDAT_del;



assign DATA = {8'h34, DATA_A};		//slave address + sub_address + register_data
assign TRANSACTION_REQ = (address < `rom_size); //algrin
assign AUD_XCK	= COUNTER_500[1];   // AUD_XCK
//=============================================================================
// Structural coding
//=============================================================================

always_ff @(posedge CLOCK_50 or negedge rst_n ) //algrin) 
begin
	if ( !rst_n ) //algrin
	begin
		COUNTER_500		<=0;
		CLOCK_500_del	<=0;
		CLOCK_500 		<= 0;
		CLOCK_SDAT 		<= 0;
	end
	else
        begin
		COUNTER_500		<=COUNTER_500+1;
		CLOCK_500_del	<= CLOCK_500;

		CLOCK_500 		<= (COUNTER_500 >= 800 && COUNTER_500 < 1820   ) ? 1 : 0; // algrin
		CLOCK_SDAT		<= (COUNTER_500 >= 450 &&  COUNTER_500 < 1990 ) ? 1 : 0; // algrin
	end
end
assign CLOCK_500_ena = (CLOCK_500) && ( ! CLOCK_500_del);

////
always_ff @(posedge CLOCK_50 or negedge rst_n ) //algrin) 
begin
	if ( !rst_n ) //algrin
	begin
		CLOCK_SDAT_del	<=0;
		CLOCK_SDAT_ena	<= 0;
	end
	else
        begin
		CLOCK_SDAT_del	<= CLOCK_SDAT;
		CLOCK_SDAT_ena	<= (CLOCK_SDAT) && ( ! CLOCK_SDAT_del);
	end
end


////


always_ff @(negedge KEY0_EDGE or posedge CLOCK_50 or negedge rst_n) //algrin
begin
	if (!KEY0_EDGE | !rst_n ) //algrin
	begin
		address	<=0;
	end
	else if ( TRANSACTION_REQ == 1 && NEXT_WORD == 1) begin
	
		if (address <= `rom_size)
		begin
			address	<=address+1;
		end
	end
end




always_ff @(posedge CLOCK_50 )		// algrin 
begin
	ROM[0]	<= 16'h1201;					//algrin not active h1200
	ROM[1]	<= 16'h1201;	    			//power down h0c00
	ROM[2]	<= 16'h0e42;	   //42		   		//algrin master and no bclk inverse. I2S mode 
				
   if (MICROPHON_ON	== 1 ) begin
		ROM[3] 			<= 16'h0815;	//algrin. sound select  Reg8 Bypass Off DACSEL and MICROPHONE INPUT SELECTED to ADC + BOOST
		MICROPHON_LED	<= 1;
		end
	else begin
		ROM[3]			<= 16'h0810;	//algrin sound select  Reg8 Bypass Off DACSEL and disable SIDETONE 
		MICROPHON_LED 	<= 0;
	end	
 	ROM[4]				<= 16'h1000;//1C;//00;	//agrin mclk  48 Khz, disable oversampling ; can try 3C
//		ROM[4]				<= 16'h103E;//1C;//00;	//agrin mclk  96 Khz, disable oversampling ; can try 3C
  
//   ROM[3] = 16'h101C;					//agrin mclk 96KHz,xclk 12288 Mhz
	
	ROM[5]				<= 16'h007F;	//7F	-max			//algrin input max volume
	ROM[6]				<= 16'h027F;	// 7F - max				//algrin input max volume
	ROM[7]				<= {8'h04,1'b1,7'h7F};	//	//algrin left channel headphone output volume
	ROM[8]				<= {8'h06,1'b0,7'h7F};	//	//algrin right channel headphone output volume	
	ROM[9]				<= 16'h0A01;  					// algrin data=01; disable highpass, disable 48kHz filter

	//ROM[`rom_size] = 16'h1201;       //active
	
end

assign DATA_A = ROM[address];

endmodule
