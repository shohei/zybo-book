`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//date 2015/10/29 yokomizo
//////////////////////////////////////////////////////////////////////////////////
module led_matrix_ctrl(
    //wishbone bus
    input  clk,
	input  reset,
    input  [31:0] data_in,
    input  data_in_en,
	//led matrix
	output reg led_clk,
	output reg lat,
	output reg oeb,
	output reg r1,
	output reg g1,
	output reg b1,
	output reg r2,
	output reg g2,
	output reg b2,
	output reg [2:0] line
    );
parameter p_base_cnt_t = 480;
parameter p_base_cnt_max = (p_base_cnt_t-1); //sysyclk:96MHz 5us	
parameter p_base_cnt_led_clk = (p_base_cnt_t/2-1) ; //led_clk	
parameter p_line_cnt_max = 7 ; //line_cnt最大値
parameter p_bl_cnt_max = 3;  //bl_cn最大値
parameter p_delay_cnt_0 = 1 ; //輝度ビット0の遅延時間
parameter p_delay_cnt_1 = 4 ; //輝度ビット1の遅延時間
parameter p_delay_cnt_2 = 18 ; //輝度ビット2の遅延時間
parameter p_delay_cnt_3 = 40 ; //輝度ビット3の遅延時間
parameter p_led_clk_cnt_max = 31 ; //led_clk_cnt最大
parameter p_led_clk_cnt_lat_s = 31; //lat start	
parameter p_led_clk_cnt_lat_e = 0 ; //lat end
parameter p_led_clk_cnt_oeb_s = 27 ; //oeb start	
parameter p_led_clk_cnt_oeb_e = 30 ;//oen end
reg [16:0]base_cnt;	
reg tmg_sig;
reg led_clk_sig;
reg [2:0]line_cnt;	
reg [9:0]delay_cnt;	
wire [9:0]delay_cnt_max;	
reg [1:0]bl_cnt;	
reg [1:0]bl_cnt_hold;	
reg [4:0]led_clk_cnt;	
reg [8:0]w_adr;
reg data_in_en_d1;
wire wea_1;
wire wea_2;
reg [11:0]dina;
wire [7:0]r_adr;
wire [11:0]r_data_1;
wire [11:0]r_data_2;
//
// WISHBONE BUS インターフェース
//

//bram 書き込みデータ
always@(posedge clk )
  if( reset==1'b1)
    dina <= 12'h000;
  else
    if(data_in_en == 1'b1)
	  dina <= data_in[11:0];
	else
      dina <= dina;
	  
//bram 書き込みイネーブル
always@(posedge clk )
  if( reset==1'b1)
    data_in_en_d1 <=1'b0; 
  else 
    data_in_en_d1 <= data_in_en;
	
assign wea_1 =((data_in_en_d1 == 1'b1)&&(w_adr[8]==1'b0))?1'b1:1'b0;
assign wea_2 =((data_in_en_d1 == 1'b1)&&(w_adr[8]==1'b1))?1'b1:1'b0;
	 
//bram 書き込みアドレス 
/*
always@(posedge clk )
  if( reset==1'b1)
    w_adr <=9'h000; 
  else 
    if((wea_1== 1'b1)||(wea_2== 1'b1))
      w_adr  <=w_adr + 9'd1; 
	else
      w_adr <= w_adr;
*/

always@(posedge clk )
  if( reset==1'b1)
    w_adr <=9'h000; 
  else 
	//if((wea_1== 1'b1)||(wea_2== 1'b1))
	if(data_in_en==1'b1)
      w_adr <= data_in[24:16];
    else
      w_adr <= w_adr;	
    

//ライン0-7 表示パタンデータ	  
ram_12b_256w ram_1 (
  .clka(clk), // input clka
  .wea(wea_1), // input [0 : 0] wea
  .addra(w_adr), // input [7 : 0] addra
  .dina(dina), // input [11 : 0] dina
  .clkb(clk), // input clkb
  .addrb(r_adr[7:0]), // input [7 : 0] addrb
  .doutb(r_data_1) // output [11 : 0] doutb
);

//ライン8-15 表示パタンデータ	  
ram_12b_256w ram_2 (
  .clka(clk), // input clka
  .wea(wea_2), // input [0 : 0] wea
  .addra(w_adr), // input [7 : 0] addra
  .dina(dina), // input [11 : 0] dina
  .clkb(clk), // input clkb
  .addrb(r_adr[7:0]), // input [7 : 0] addrb
  .doutb(r_data_2) // output [11 : 0] doutb
);

//
//カウンタ
//
//ベースカウンタ
always@(posedge clk )
  if( reset==1'b1)
    base_cnt <= 17'd0;
  else
    if(base_cnt == p_base_cnt_max)
      base_cnt <= 17'd0;
	else
      base_cnt <= base_cnt + 14'd1;

always@(posedge clk )
  if( reset==1'b1)
    tmg_sig <= 1'b0;
  else
    if(base_cnt == p_base_cnt_max)
      tmg_sig <= 1'b1;
	else
      tmg_sig <= 1'b0;
	  
always@(posedge clk )
  if( reset==1'b1)
    led_clk_sig <= 1'b0;
  else
    if(base_cnt == p_base_cnt_led_clk)
      led_clk_sig <= 1'b1;
	else
      led_clk_sig <= 1'b0;
//遅延カウンタ
//bl_cnt_holdの値によってdelay_cntの最大値を変える
assign delay_cnt_max=(bl_cnt_hold==2'd0)?	p_delay_cnt_0:
                      (bl_cnt_hold==2'd1)?	p_delay_cnt_1:
                      (bl_cnt_hold==2'd2)?	p_delay_cnt_2:
                                        p_delay_cnt_3;
					
always@(posedge clk )
  if( reset==1'b1)
    bl_cnt_hold <= 2'd0;
  else
    if(tmg_sig== 1'b1)
	  if(led_clk_cnt==31)
        bl_cnt_hold <= bl_cnt;
	  else
        bl_cnt_hold <= bl_cnt_hold;
	else
      bl_cnt_hold <= bl_cnt_hold;	
										
//遅延カウンタ
always@(posedge clk )
  if( reset==1'b1)
    delay_cnt <= 10'd0;
  else
    if(tmg_sig== 1'b1)
	  if(led_clk_cnt==28)
        delay_cnt <= 10'd1;
	  else if (delay_cnt==0)
        delay_cnt <= 10'd0;
      else if(delay_cnt==delay_cnt_max)
        delay_cnt <= 10'd0;
	  else
        delay_cnt <= delay_cnt + 10'd1;
	else
      delay_cnt <= delay_cnt ;
	  
//クロックカウンタ	  
always@(posedge clk )
  if( reset==1'b1)
    led_clk_cnt <= 5'd0;
  else
    if((tmg_sig== 1'b1)&&(delay_cnt==0))
	  if(led_clk_cnt==p_led_clk_cnt_max)
        led_clk_cnt <= 5'd0;
	  else
        led_clk_cnt <= led_clk_cnt + 5'd1;
    else
        led_clk_cnt <= led_clk_cnt;
//輝度カウンタ	  
always@(posedge clk )
  if( reset==1'b1)
    bl_cnt <= 2'd0;
  else
    if((tmg_sig== 1'b1)&&
	   (led_clk_cnt==p_led_clk_cnt_max))
	  if(bl_cnt==p_bl_cnt_max)
        bl_cnt <= 2'd0;
	  else
        bl_cnt <= bl_cnt + 2'd1;
	else
        bl_cnt <= bl_cnt ;
		
//ラインカウンタ	  
always@(posedge clk )
  if( reset==1'b1)
    line_cnt <= 3'd0;
  else
    if((tmg_sig== 1'b1)&&(led_clk_cnt==p_led_clk_cnt_max)&&(bl_cnt==p_bl_cnt_max))
	  if(line_cnt==p_line_cnt_max)
        line_cnt <= 3'd0;
	  else
        line_cnt <= line_cnt + 3'd1;
	else
      line_cnt <= line_cnt ;

//制御信号生成	  
always@(posedge clk )
  if( reset==1'b1)
    line <= 3'd0;
  else
    if((tmg_sig== 1'b1)&&(led_clk_cnt==p_led_clk_cnt_max)&&(bl_cnt==2'b00))
    //if((tmg_sig== 1'b1)&&(led_clk_cnt==p_led_clk_cnt_max))
      line <= line_cnt;
	else
      line <= line ;
 
always@(posedge clk )
  if( reset==1'b1)
    led_clk <= 1'b0;
  else
    if(delay_cnt==0)
      if(tmg_sig== 1'b1)
        led_clk <= 1'b0;
	  else if(led_clk_sig==1'b1)
        led_clk <= 1'b1;
	  else	
        led_clk <= led_clk;
	else	
      led_clk <= led_clk;

always@(posedge clk )
  if( reset==1'b1)
    lat <= 1'b0;
  else
    if(tmg_sig== 1'b1)
	  if(led_clk_cnt==p_led_clk_cnt_lat_s)
        lat <= 1'b1;
	  else if(led_clk_cnt==p_led_clk_cnt_lat_e)
      lat <= 1'b0;
	else	
      lat <= lat;

always@(posedge clk )
  if( reset==1'b1)
    oeb <= 1'b1;
  else
    if(tmg_sig== 1'b1)
	  if(led_clk_cnt==p_led_clk_cnt_oeb_s)
        oeb <= 1'b0;
	  else if(led_clk_cnt==p_led_clk_cnt_oeb_e)
        oeb <= 1'b1;
	else	
      oeb <= oeb;

 assign r_adr ={line_cnt,led_clk_cnt};
 
//シリアルデータ
always@(posedge clk )
  if( reset==1'b1)
    begin
      r1<= 1'b0;
      g1<= 1'b0;
      b1<= 1'b0;
      r2<= 1'b0;
      g2<= 1'b0;
      b2<= 1'b0;
	end
  else
  if((delay_cnt==0)&&(tmg_sig== 1'b1))
    begin
      r1<= r_data_1[bl_cnt];
      g1<= r_data_1[bl_cnt+4];
      b1<= r_data_1[bl_cnt+8];
      r2<= r_data_2[bl_cnt];
      g2<= r_data_2[bl_cnt+4];
      b2<= r_data_2[bl_cnt+8];
	end
  else
    begin
      r1<= r1;
      g1<= g1;
      b1<= b1;
      r2<= r2;
      g2<= g2;
      b2<= b2;
	end
	
endmodule
