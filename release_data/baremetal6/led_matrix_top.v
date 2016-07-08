`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//date 2015/09/24 yokomizo
//////////////////////////////////////////////////////////////////////////////////
module led_matrix_top(
    //wishbone bus
    input  clk,
	input  reset,
	//led matrix
	output led_clk,
	output lat,
	output oeb,
	output r1,
	output g1,
	output b1,
	output r2,
	output g2,
	output b2,
	output [2:0] line,
	output led
    );
wire [31:0] data_in;
reg data_in_en;
reg [8:0]adr;
reg  [7:0]init_cnt;
reg  [23:0]led_cnt;
//
always@(posedge clk )
  if( reset==1'b1)
    init_cnt <= 8'h00;
  else
    if(init_cnt == 8'hff)
	  init_cnt <= 8'hff;
	else
      init_cnt <= init_cnt +8'h1;
	  
always@(posedge clk )
  if( reset==1'b1)
    adr <= 9'h000;
  else
  if(init_cnt == 8'hff)
    if(adr == 9'h1ff)
	  adr <= 9'h1ff;
	else
      adr <= adr +9'h1;
   else	  
	adr <= adr;
/*	  
always@(posedge clk )
  if( reset==1'b1)
    data_in<= 12'h000;
  else
    data_in <= {adr[3:0],8'h0};
*/
assign 	data_in = (adr[4]==1'b0)?{7'b0000000,adr,4'b000,adr[8:5],4'h0,adr[3:0]}:{7'b0000000,adr,4'b000,adr[8:5],adr[3:0],4'h0};
	  
always@(posedge clk )
  if( reset==1'b1)
    data_in_en<=1'b0;
  else
  if((adr == 9'h000)&&(init_cnt == 8'hfe))
    data_in_en <= 1'b1;
  else  if((adr == 9'h1ff)&&(init_cnt == 8'hff))
    data_in_en <= 1'b0;
  else 
    data_in_en <= data_in_en;
	  
always@(posedge clk )
  if( reset==1'b1)
    led_cnt <= 0;
  else
    led_cnt <= led_cnt + 1;
	
assign led = led_cnt[23];

led_matrix_ctrl led_matrix_ctrl(
.clk(clk),
.reset(reset),
.data_in(data_in),
.data_in_en(data_in_en),
.led_clk( led_clk),
.lat(     lat),
.oeb(     oeb),
.r1(      r1),
.g1(      g1),
.b1(      b1),
.r2(      r2),
.g2(      g2),
.b2(      b2),
.line(line)
	);
endmodule
