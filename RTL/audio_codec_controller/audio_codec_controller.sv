
//=======================================================
// Alex. Grinshpun May 2018
//  Supports Wolfson WM8731 codec

//module audio_codec_controller(
//	//////////// CLOCK //////////
//	input		logic	CLOCK_50,
//	input		logic	resetN,
//   input 	logic AUD_ADCDAT,
//   inout 	logic AUD_ADCLRCK, //inout	
//	inout	   logic AUD_BCLK,   //inout
//	inout 	logic AUD_DACLRCK,  //inout
//	input		logic	[15:0]	dacdata_left,
//	input		logic	[15:0]	dacdata_right,
//	input		logic	MICROPHON_ON,
//	
//	output	logic    AUD_DACDAT,
//	output	logic    AUD_XCK,
//	output	logic    AUD_I2C_SCLK,
//	inout 	logic    AUD_I2C_SDAT,
//	output	logic	MICROPHON_LED,
//	output	logic	[31:0]	adcdata_out,
//	//output	logic	[15:0]	adcdata_right_out,
//	
//	output	logic	dacdata_left_ack,
//	
//	output	logic	dacdata_right_ack,
//	
//	output	logic				adcdata_left_valid,
//	
//	output	logic				adcdata_right_valid
//	
//
//	//////////// Audio //////////
//	
//	
//	
//		        
//	
//
//	
//	
//
//	
//	//////////// I2C for Audio and Video-In //////////
//	
//
//);
//
//
//
/////=======================================================
////  REG/WIRE declarations
////=======================================================
//logic [5:0]	PRESCALER_COUNTER;
////logic          AUD_ADCLRCK;
////logic          AUD_DACLRCK;
//logic			 	NEXT_WORD;
//logic			 	KEY0_EDGE;
//logic	[23:0] 	AUD_I2C_DATA;
//logic         	TRANSACTION_REQ;
//
//logic				AUD_DACDAT_left;
//logic				AUD_DACDAT_right;
//logic				CLOCK_500;
//logic				CLOCK_SDAT;
//logic				MICROPHON_ON_SETTLED;
//logic				resetSyncN;
//logic				SDO;
//logic	[15:0]	adcdata_left;
//logic	[15:0]	adcdata_right;
//localparam  logic [5:0] C_12P5MHZ_DIV_32 = 6'd32;
//   
////=======================================================
////  Structural coding
////=======================================================
//
//
//
//assign RESETn	= resetN;
//
////always_ff@(posedge AUD_BCLK or negedge resetN)
////begin
////	if(!resetN)
////	begin
////			PRESCALER_COUNTER	<= 16'b1;
////	//		SampleRt   			<= 1'b0;
////			AUD_ADCLRCK   			<= 1'b0;
////			AUD_DACLRCK   			<= 1'b0;
////			//prescaler_2			<= 1'b0;
////	end
////	else
////	begin
////		//prescaler_2	<=	prescaler_1; // 1 clk delay
////		//if (PRESCALER_COUNTER >= (count_limit<< 4) ) 
////		if (PRESCALER_COUNTER >= C_12P5MHZ_DIV_32 )
////		begin
////				PRESCALER_COUNTER <= 16'b1;
////				AUD_ADCLRCK	 <= !AUD_ADCLRCK;
////				AUD_DACLRCK  <= !AUD_DACLRCK;
////		end
////		else begin
////				PRESCALER_COUNTER <= PRESCALER_COUNTER + 1'b1;
////				//SampleRt			<= 1'b0;
////		end
////	end
////end
////
//
//// Debounce 	MICROPHON_ON and make short pulse on changes
//
//DeBounce DeBounce_inst (
//			.clk(CLOCK_50),
//			.resetN(RESETn),
//			.button_in(MICROPHON_ON),
//			.DB_out(MICROPHON_ON_SETTLED),
//			.KEY0_EDGE(KEY0_EDGE),
//			.resetSyncN(resetSyncN)
//        );
//
//
////I2C output data
//CLOCK_500		CLOCK_500_inst(
//	.CLOCK_50(CLOCK_50),
//	.rst_n(resetSyncN),					 
//	.NEXT_WORD(NEXT_WORD),
//	.KEY0_EDGE(KEY0_EDGE),
//	.CLOCK_500_ena(CLOCK_500_ena),	
//	.CLOCK_500(CLOCK_500),
//	.CLOCK_SDAT_ena(CLOCK_SDAT_ena),
//	.TRANSACTION_REQ(TRANSACTION_REQ), 
//	.AUD_XCK(AUD_XCK),
//	.DATA(AUD_I2C_DATA),
//
//	.MICROPHON_ON(MICROPHON_ON_SETTLED),
//	.MICROPHON_LED(MICROPHON_LED)
//	);
//	
//assign AUD_I2C_SDAT = SDO?1'bz:0 ;
//	
////i2c controller
//i2c				i2c_inst( 
//	// Host Side
//	.CLOCK_50(CLOCK_50),
//	.CLOCK_500(CLOCK_500),
//	.CLOCK_500_ena(CLOCK_500_ena),
//	.CLOCK_SDAT_ena(CLOCK_SDAT_ena),
//
//	.RESET(resetSyncN),
//	// I2C Side
//	.SDO(SDO),
//	.I2C_SDAT(AUD_I2C_SDAT),
//	.I2C_DATA(AUD_I2C_DATA),
//	.FPGA_I2C_SCLK(AUD_I2C_SCLK),
//	// Control Signals
//	.TRANSACTION_REQ(TRANSACTION_REQ),
//	.NEXT_WORD(NEXT_WORD)
//	);
//					 
//
//
//adc2parallel adc2parallel_left_inst (
//		.CLOCK_50(CLOCK_50),
//		.AUD_ADCDAT(AUD_ADCDAT),
//		.resetn(resetSyncN),
//		.left_channel(1'b1),
//		.AUD_ADCLRCK(AUD_ADCLRCK),
//		.AUD_BCLK(AUD_BCLK),
//		.ADCDATA_VALID(adcdata_left_valid),
//		.ADCDATA(adcdata_left)
//
//	);
//
//adc2parallel adc2parallel_right_inst (
//		.CLOCK_50(CLOCK_50),
//		.AUD_ADCDAT(AUD_ADCDAT),
//		.resetn(resetSyncN),
//		.left_channel(1'b1),
//		.AUD_ADCLRCK(AUD_ADCLRCK),
//		.AUD_BCLK(AUD_BCLK),
//		.ADCDATA_VALID(adcdata_right_valid),
//		.ADCDATA(adcdata_right)
//
//	);
//
//dac2serial dac2serial_left_inst (
//		.CLOCK_50(CLOCK_50),
//		.resetn(resetSyncN),
//		.left_channel(1'b1),
//		.AUD_BCLK(AUD_BCLK),
//		.AUD_DACLRCK(AUD_DACLRCK),
//		.DACDATA_ACK(dacdata_left_ack),
//		.DACDATA(~dacdata_left),
//		.AUD_DACDAT(AUD_DACDAT_left)
//	 
//	);
//
//dac2serial dac2serial_right_inst 
//	(
//		.CLOCK_50(CLOCK_50),
//		.resetn(resetSyncN),
//		.left_channel(1'b0),
//		.AUD_BCLK(AUD_BCLK),
//		.AUD_DACLRCK(AUD_DACLRCK),
//		.DACDATA_ACK(dacdata_right_ack),
//		.DACDATA(~dacdata_right),
//		.AUD_DACDAT(AUD_DACDAT_right)
//	 
//	);
//
//assign AUD_DACDAT = AUD_DACDAT_left  || AUD_DACDAT_right;
//assign adcdata_out = {{16{adcdata_left[15]}},adcdata_left[15:0]};  //^adcdata_right[15]  +adcdata_right[14:0]
//endmodule 
module audio_codec_controller(
	//////////// CLOCK //////////
	input		logic	CLOCK_50,
	input		logic	resetN,
               
	input		logic	MICROPHON_ON,
	output	logic	MICROPHON_LED,
	
	output	logic	dacdata_left_ack,
	input		logic	[15:0]	dacdata_left,
	output	logic	dacdata_right_ack,
	input		logic	[15:0]	dacdata_right,
	output	logic				adcdata_left_valid,
	output	logic	[15:0]	adcdata_left,
	output	logic				adcdata_right_valid,
	output	logic	[15:0]	adcdata_right,

	//////////// Audio //////////
	input 	logic    AUD_ADCDAT,
	inout 	logic    AUD_ADCLRCK,
	inout 	logic    AUD_BCLK,
		        
	output	logic    AUD_DACDAT,

	inout 	logic    AUD_DACLRCK,
	output	logic    AUD_XCK,

	
	//////////// I2C for Audio and Video-In //////////
	output	logic    AUD_I2C_SCLK,
	inout 	logic    AUD_I2C_SDAT

);



///=======================================================
//  REG/WIRE declarations
//=======================================================

logic			 	NEXT_WORD;
logic			 	KEY0_EDGE;
logic	[23:0] 	AUD_I2C_DATA;
logic         	TRANSACTION_REQ;

logic				AUD_DACDAT_left;
logic				AUD_DACDAT_right;
logic				CLOCK_500;
logic				CLOCK_SDAT;
logic				MICROPHON_ON_SETTLED;
logic				resetSyncN;
logic				SDO;
   
//=======================================================
//  Structural coding
//=======================================================



assign RESETn	= resetN;



// Debounce 	MICROPHON_ON and make short pulse on changes

DeBounce DeBounce_inst (
			.clk(CLOCK_50),
			.resetN(RESETn),
			.button_in(MICROPHON_ON),
			.DB_out(MICROPHON_ON_SETTLED),
			.KEY0_EDGE(KEY0_EDGE),
			.resetSyncN(resetSyncN)
        );


//I2C output data
CLOCK_500		CLOCK_500_inst(
	.CLOCK_50(CLOCK_50),
	.rst_n(resetSyncN),					 
	.NEXT_WORD(NEXT_WORD),
	.KEY0_EDGE(KEY0_EDGE),
	.CLOCK_500_ena(CLOCK_500_ena),	
	.CLOCK_500(CLOCK_500),
	.CLOCK_SDAT_ena(CLOCK_SDAT_ena),
	.TRANSACTION_REQ(TRANSACTION_REQ), 
	.AUD_XCK(AUD_XCK),
	.DATA(AUD_I2C_DATA),

	.MICROPHON_ON(MICROPHON_ON_SETTLED),
	.MICROPHON_LED(MICROPHON_LED)
	);
	
assign AUD_I2C_SDAT = SDO?1'bz:0 ;
	
//i2c controller
i2c				i2c_inst( 
	// Host Side
	.CLOCK_50(CLOCK_50),
	.CLOCK_500(CLOCK_500),
	.CLOCK_500_ena(CLOCK_500_ena),
	.CLOCK_SDAT_ena(CLOCK_SDAT_ena),

	.RESET(resetSyncN),
	// I2C Side
	.SDO(SDO),
	.I2C_SDAT(AUD_I2C_SDAT),
	.I2C_DATA(AUD_I2C_DATA),
	.FPGA_I2C_SCLK(AUD_I2C_SCLK),
	// Control Signals
	.TRANSACTION_REQ(TRANSACTION_REQ),
	.NEXT_WORD(NEXT_WORD)
	);
					 


adc2parallel adc2parallel_left_inst (
		.CLOCK_50(CLOCK_50),
		.AUD_ADCDAT(AUD_ADCDAT),
		.resetn(resetSyncN),
		.left_channel(1'b1),
		.AUD_ADCLRCK(AUD_ADCLRCK),
		.AUD_BCLK(AUD_BCLK),
		.ADCDATA_VALID(adcdata_left_valid),
		.ADCDATA(adcdata_left)

	);

adc2parallel adc2parallel_right_inst (
		.CLOCK_50(CLOCK_50),
		.AUD_ADCDAT(AUD_ADCDAT),
		.resetn(resetSyncN),
		.left_channel(1'b1),
		.AUD_ADCLRCK(AUD_ADCLRCK),
		.AUD_BCLK(AUD_BCLK),
		.ADCDATA_VALID(adcdata_right_valid),
		.ADCDATA(adcdata_right)

	);

dac2serial dac2serial_left_inst (
		.CLOCK_50(CLOCK_50),
		.resetn(resetSyncN),
		.left_channel(1'b1),
		.AUD_BCLK(AUD_BCLK),
		.AUD_DACLRCK(AUD_DACLRCK),
		.DACDATA_ACK(dacdata_left_ack),
		.DACDATA(~dacdata_left),
		.AUD_DACDAT(AUD_DACDAT_left)
	 
	);

dac2serial dac2serial_right_inst 
	(
		.CLOCK_50(CLOCK_50),
		.resetn(resetSyncN),
		.left_channel(1'b0),
		.AUD_BCLK(AUD_BCLK),
		.AUD_DACLRCK(AUD_DACLRCK),
		.DACDATA_ACK(dacdata_right_ack),
		.DACDATA(~dacdata_right),
		.AUD_DACDAT(AUD_DACDAT_right)
	 
	);

assign AUD_DACDAT = AUD_DACDAT_left  || AUD_DACDAT_right;
endmodule
                                            