module adc2parallel (

	//////////// CLOCK //////////
	input		logic	CLOCK_50,
	input		logic	resetn,
               
	input		logic	left_channel,
	input		logic	AUD_ADCDAT,
	
	input		logic	AUD_BCLK,
	input		logic	AUD_ADCLRCK,
	output	logic	ADCDATA_VALID,
	output	logic	[15:0] ADCDATA
);


integer serial_cnt;
logic AUD_ADCLRCK_tmp;
logic serial_rdy;

logic serial_rdy_tmp; 

logic adcdata_bit_clk50 ;
logic [15:0] adcdata_tmp;
logic adc_rdempty;

logic serial_rdy_50_ena;
//
logic serial_rdy_50_ff1;
logic serial_rdy_50_ff2;
logic serial_rdy_50_ff3;
const int numbits = 16;

assign AUD_ADCLRCK_VAL = (left_channel) ? AUD_ADCLRCK : ! AUD_ADCLRCK; 


always_ff @(posedge CLOCK_50 or negedge resetn) begin
  if (!resetn) begin
			adcdata_tmp	<= 16'b0;
	end
	else begin
		if ( !adc_rdempty) begin
			adcdata_tmp <= { adcdata_tmp[14:0], adcdata_bit_clk50 };
		end
		
		if (serial_rdy_50_ena) begin
				 ADCDATA	<= adcdata_tmp ; // Correct offset in CODEC due to high pass filter + 800
		end
		ADCDATA_VALID	<=	serial_rdy_50_ena;
	end

end

assign adc_wrreq = !AUD_ADCLRCK_tmp  & serial_rdy ;
//synch between bclk and clock_50
synch_fifo	adc_synch_fifo_inst (
	.data ( AUD_ADCDAT ),
	.rdclk ( CLOCK_50 ),
	.rdreq ( 1'b1 ),
	.wrclk ( AUD_BCLK ),
	.wrreq ( adc_wrreq ),
	.q ( adcdata_bit_clk50 ),
	.rdempty ( adc_rdempty ),
	.wrfull ( adc_wrfull )
	);

	
always_ff @(posedge AUD_BCLK or negedge resetn) begin
  if (!resetn) begin
		serial_cnt <= numbits;
		serial_rdy <= 1'b1;
	end
	else begin
		serial_rdy_tmp	<= serial_rdy;
		AUD_ADCLRCK_tmp <= AUD_ADCLRCK_VAL;
		if (!AUD_ADCLRCK_tmp & serial_rdy) begin
		   if (serial_cnt == 0) begin
				serial_rdy <= 1'b0;
			end
   	  	else if (serial_cnt > 0)  begin
				serial_cnt <= serial_cnt - 1;
		   end ;
		end
		else if (AUD_ADCLRCK_tmp) begin
			serial_rdy <= 1'b1;
			serial_cnt <= numbits;
		end;
	end

end

always_ff @(posedge CLOCK_50 or negedge resetn) begin
 if (!resetn) begin
			serial_rdy_50_ff1	<= 1'b0;
			serial_rdy_50_ff2	<= 1'b0;
			serial_rdy_50_ff3	<= 1'b0;
	end
	else begin
	// synch 3 cycles to prevent metastability
			serial_rdy_50_ff1	<= serial_rdy;
			serial_rdy_50_ff2	<= serial_rdy_50_ff1;
			serial_rdy_50_ff3	<= serial_rdy_50_ff2;
	end

end
  
assign serial_rdy_50_ena = serial_rdy_50_ff2 & !serial_rdy_50_ff3;

endmodule