// Alex Grinshpun 

module dac2serial (

	//////////// CLOCK //////////
	input		logic	CLOCK_50,
	input		logic	resetn,
               
	input		logic	left_channel,
	input		logic	AUD_ADCDAT,
	
	input		logic	AUD_BCLK,
	input		logic	AUD_DACLRCK,
	output	logic DACDATA_ACK,
	input		logic [15:0] DACDATA,
	output	logic	AUD_DACDAT
);

integer parallel_cnt;
integer parallel_cnt_del;

logic [15:0] dacdata_rev ;
logic AUD_DACLRCK_50_ff1;
logic AUD_DACLRCK_50_ff2;
logic AUD_DACLRCK_50_ff3;
logic AUD_DACLRCK_VAL;
logic enable;
const int numbits = 15;

//-- There exists offset causing assymitrical amplitude of negative and positive parts
//DACDATA_corrected	<= DACDATA + "0000001111111111" ; --1000;
assign AUD_DACLRCK_VAL = (left_channel) ? AUD_DACLRCK : !AUD_DACLRCK; 

//initial 
//begin 
//integer i;
//// reverse order of vector
//for (i=15; i >= 0; i=i-1)
//  dacdata_rev[15-i]=DACDATA[i];
//end 
 
always_comb 
begin 
integer i;
// reverse order of vector
for (i=15; i >= 0; i=i-1)
  dacdata_rev[15-i]=DACDATA[i];
end  

//	
assign dac_rdreq = (!AUD_DACLRCK_VAL & parallel_cnt >= 0) ? 1 : 0; 			
assign dac_wrreq	= AUD_DACLRCK_50_ff2 & !AUD_DACLRCK_50_ff3;	

dac_synchronizer	dac_synchronizer_inst (
	.data ( dacdata_rev ),
	.rdclk ( AUD_BCLK ),
	.rdreq ( dac_rdreq ),
	.wrclk ( CLOCK_50 ),
	.wrreq ( dac_wrreq ),
	.q ( AUD_DACDAT_t ),
	.rdempty ( dac_rdempty ),
	.wrfull ( dac_wrfull )
	);
	

always_ff @(posedge CLOCK_50 or negedge resetn) begin
 if (!resetn) begin
			AUD_DACLRCK_50_ff1	<= 1'b0;
			AUD_DACLRCK_50_ff2	<= 1'b0;
			AUD_DACLRCK_50_ff3	<= 1'b0;
			DACDATA_ACK				<= 1'b0;
	end
	else begin
	// synch 3 cycles to prevent metastability
			AUD_DACLRCK_50_ff1	<= AUD_DACLRCK_VAL;
			AUD_DACLRCK_50_ff2	<= AUD_DACLRCK_50_ff1;
			AUD_DACLRCK_50_ff3	<= AUD_DACLRCK_50_ff2;
			DACDATA_ACK				<=	dac_wrreq;
	end

end


always_ff @(posedge AUD_BCLK or negedge resetn) begin
 	if (!resetn) begin
		parallel_cnt		<= numbits;
		parallel_cnt_del	<= numbits;
	end
	else begin
		if (!AUD_DACLRCK_VAL & parallel_cnt >= 0) begin
		   	if (parallel_cnt > 0) begin
				parallel_cnt <= parallel_cnt - 1;
			end
		end
   	  	else if (AUD_DACLRCK_VAL )  begin
				parallel_cnt <= numbits;
	        end ;

		parallel_cnt_del	<= parallel_cnt;
	end

end


always_ff @(negedge AUD_BCLK or negedge resetn) begin
  if (!resetn) begin
		AUD_DACDAT	<= 0;
	end
	else begin
		AUD_DACDAT	<= AUD_DACDAT_t & enable;
	end

end
//====================================== 
// FSM  AUD_DACDAT ENABLE
enum logic [1:0] {idle, sig_en, zero} state, nextstate;

	always_ff @(posedge AUD_BCLK or negedge resetn)
		if (!resetn) 
			state <= idle;
		else 
			state <= nextstate;

	always_comb begin
		case (state)
		idle: 	
			enable	<= 0;
		sig_en:	
			enable	<= 1;
		zero:
			enable	<= 0;
		default: 
			enable	<= 0;
		endcase
	end

	// next state logic
	always_comb begin
		case (state)
		idle: 	if (!AUD_DACLRCK_VAL) 
						nextstate = sig_en;
					else 
						nextstate = idle;
		sig_en:	if (!parallel_cnt_del) 
						nextstate = zero;
					else 
						nextstate = sig_en;
		zero:	if (AUD_DACLRCK_VAL) 
						nextstate = idle;
					else 
						nextstate = zero;						
		default: nextstate = idle;
		endcase
	end

endmodule