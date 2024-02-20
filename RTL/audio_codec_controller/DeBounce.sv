// DeBounce_v.v


//////////////////////// Button Debounceer ///////////////////////////////////////
//***********************************************************************
// FileName: DeBounce_v.v
// FPGA: MachXO2 7000HE
// IDE: Diamond 2.0.1 
//
// HDL IS PROVIDED "AS IS." DIGI-KEY EXPRESSLY DISCLAIMS ANY
// WARRANTY OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
// PARTICULAR PURPOSE, OR NON-INFRINGEMENT. IN NO EVENT SHALL DIGI-KEY
// BE LIABLE FOR ANY INCIDENTAL, SPECIAL, INDIRECT OR CONSEQUENTIAL
// DAMAGES, LOST PROFITS OR LOST DATA, HARM TO YOUR EQUIPMENT, COST OF
// PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY OR SERVICES, ANY CLAIMS
// BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF),
// ANY CLAIMS FOR INDEMNITY OR CONTRIBUTION, OR OTHER SIMILAR COSTS.
// DIGI-KEY ALSO DISCLAIMS ANY LIABILITY FOR PATENT OR COPYRIGHT
// INFRINGEMENT.
//
// Version History
// Version 1.0 04/11/2013 Tony Storey
// Initial Public Release
// Small Footprint Button Debouncer
// -- Alex Grinshpun May 2018 */

`timescale 1 ns / 100 ps
module DeBounce(
					input logic clk,         //clk 50MHz
					input logic resetN,       //reset					
					input logic button_in,        //IR code input
					output logic DB_out,  //data ready
					output logic KEY0_EDGE,
					output logic resetSyncN         //decode data output
					);
					

//// ---------------- internal constants --------------
	parameter N = 11 ;		// (2^ (21-1) )/ 38 MHz = 32 ms debounce time
////---------------- internal variables ---------------
	logic	[N-1 : 0]	q_reg;							// timing regs
	logic	[N-1 : 0]	q_next;
	logic	DFF1, DFF2;									// input flip-flops
	logic	q_add;											// control flags
	logic	q_reset;
	logic	DB_out_delayed;
//// ------------------------------------------------------

////contenious assignment for counter control
	assign q_reset = (DFF1  ^ DFF2);		// xor input flip flops to look for level chage to reset counter
	assign  q_add = ~(q_reg[N-1]);			// add to counter when q_reg msb is equal to 0
	
//// combo counter to manage q_next	
	always_comb 
		begin
			case( {q_reset , q_add})
				2'b00 :
						q_next <= q_reg;
				2'b01 :
						q_next <= q_reg + 1;
				default :
						q_next <= { N {1'b0} };
			endcase 	
		end
	
//// Flip flop inputs and q_reg update
	always_ff @ ( posedge clk )
		begin
			if(resetN ==  1'b0)
				begin
					DFF1 <= 1'b0;
					DFF2 <= 1'b0;
					q_reg <= { N {1'b0} };
				end
			else
				begin
					DFF1 <= button_in;
					DFF2 <= DFF1;
					q_reg <= q_next;
				end
		end
	

//// counter control
	always @ ( posedge clk )
		begin
			if(q_reg[N-1] == 1'b1)
					DB_out <= DFF2;
			else
					DB_out <= DB_out;
		end

// Alex Grinshpun Dec 2017
always_ff @(posedge clk or negedge resetN )	
		if (!resetN ) begin
			DB_out_delayed	<= 1'b0;
			resetSyncN		<= 1'b0;
		end
		else	begin
			DB_out_delayed	<= DB_out;
			resetSyncN		<= KEY0_EDGE && resetN;
		end

	assign KEY0_EDGE	= ~((DB_out && ~DB_out_delayed) || (~DB_out && DB_out_delayed));

			

	
		
	endmodule
	
	


