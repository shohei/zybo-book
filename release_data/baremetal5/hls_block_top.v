`timescale 1ns / 1ps
//2015.11.07 k.yokomizo
module hls_block_top(
 reset,
 clk, 
 da_r_i,
 da_g_i,
 da_b_i,
 da_i_en,
 da_r_o,
 da_g_o,
 da_b_o,
 da_o_en,
 mode_sw
);

  input reset;
  input clk;
  input [7:0]da_r_i;
  input [7:0]da_g_i;
  input [7:0]da_b_i;
  input da_i_en;
  output [7:0]da_r_o;
  output [7:0]da_g_o;
  output [7:0]da_b_o;
  output da_o_en;
  input [1:0]mode_sw;
  //  
  reg [7:0]da_r_o;
  reg [7:0]da_g_o;
  reg [7:0]da_b_o;
  reg da_o_en;
  reg [7:0]da_r_d1;
  reg [7:0]da_g_d1;
  reg [7:0]da_b_d1;
  //
  wire [31:0]ap_return;
  wire ap_start;
  wire ap_done;
  wire [7:0]mode_sw_8b;
  //
  always @(posedge clk)                                                                              
    begin                                                                                                     
      if (reset==1'b1)
	    begin
		  da_r_d1 <= 8'h00;
		  da_g_d1 <= 8'h00;
		  da_b_d1 <= 8'h00;
		end
      else
	    begin
		  da_r_d1 <= da_r_i;
		  da_g_d1 <= da_g_i;
		  da_b_d1 <= da_b_i;
	    end
	end
	
  assign ap_start = da_i_en;
  assign mode_sw_8b = {6'b0000,mode_sw};
 
  hls_block_0 hls_block_i(
   .ap_start(ap_start),
   .ap_done(ap_done),
   .ap_idle(),
   .ap_ready(),
   .da_r_i( da_r_i),
   .da_g_i( da_g_i),
   .da_b_i( da_b_i),
   .da_r_d1( da_r_d1),
   .da_g_d1( da_g_d1),
   .da_b_d1( da_b_d1),
   .mode_sw( mode_sw_8b),
   .ap_return(ap_return)
  );
  
  always @(posedge clk)                                                                              
    begin                                                                                                     
      if (reset==1'b1)
	    begin
		  da_o_en <= 1'b0;
		  da_r_o <= 8'h00;
		  da_g_o <= 8'h00;
		  da_b_o <= 8'h00;
		end
      else
	    begin
		  da_o_en <= ap_done;
		  da_r_o <= ap_return[7:0];
		  da_g_o <= ap_return[15:8];
		  da_b_o <= ap_return[23:16];;
	    end
	end
	
endmodule
