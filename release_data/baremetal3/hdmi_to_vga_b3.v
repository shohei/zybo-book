`timescale 1ns / 1ps
//date 2015/10/02 yokomizo
module hdmi_to_vga
   (
    clk,
    reset,
    data_in_from_pins_n,
    data_in_from_pins_p,
    diff_clk_in_clk_n,
    diff_clk_in_clk_p,
	//
	scl,sda,
	m_scl,m_sda,
	hdmi_out_en,hdmi_hpd,
	hsync, vsync, red_da, green_da, blue_da,
    led,
    led2,
    i2c_led,
    mon_hsync,mon_vsync,mon_data,
	mon_pclk
	);
  input clk;
  input reset;
  input [2:0]data_in_from_pins_n;
  input [2:0]data_in_from_pins_p;
  input diff_clk_in_clk_n;
  input diff_clk_in_clk_p;
  
  input      scl; 
  inout      sda;
  output      m_scl; 
  inout      m_sda;
  output  hdmi_out_en;
  output  hdmi_hpd;
output        hsync;               // horizontal sync
output        vsync;               // vertical sync
output [ 4:0] red_da; // RGB color signals
output [ 5:0] green_da; // RGB color signals
output [ 4:0] blue_da; // RGB color signals
output       led;
output led2;
output i2c_led;
output mon_hsync;
output mon_vsync;
output [3:0]  mon_data;
output        mon_pclk;

  wire [2:0]bitslip;
  wire clk_div_out;
  wire [2:0]data_in_from_pins_n;
  wire [2:0]data_in_from_pins_p;
  wire [29:0]data_in_to_device;
  wire diff_clk_in_clk_n;
  wire diff_clk_in_clk_p;

    /////////////////////////
  wire rx0_pclk, rx0_pclkx2, rx0_pclkx10, rx0_pllclk0;
  wire rx0_plllckd;
  wire rx0_reset;
  wire rx0_serdesstrobe;
  wire rx0_hsync;          // hsync data
  wire rx0_vsync;          // vsync data
  wire rx0_de;             // data enable
  wire rx0_psalgnerr;      // channel phase alignment error
  wire [7:0] rx0_red;      // pixel data out
  wire [7:0] rx0_green;    // pixel data out
  wire [7:0] rx0_blue;     // pixel data out
  wire [29:0] rx0_sdata;
  wire rx0_blue_vld;
  wire rx0_green_vld;
  wire rx0_red_vld;
  wire rx0_blue_rdy;
  wire rx0_green_rdy;
  wire rx0_red_rdy;
  wire rxclk;
  
  reg [23:0]cnt;
  reg led;

  wire [29:0] data_in_to_device;

  reg [23:0]cnt2;
  reg   mon_hsync;
  reg   mon_vsync;
  reg [9:0]  mon_data;
  reg [9:0]  data_0_d;
  reg [9:0]  data_1_d;
  reg [9:0]  data_2_d;
  
  //assign bitslip = 0;
  assign hdmi_out_en = 1'b0;
  assign hdmi_hpd = 1'b1;
  
dvi_dec dvi_dec_i
       (.bitslip(bitslip),
        .clk_dvi_out(rxclk),
        .data_in_from_pins_n(data_in_from_pins_n),
        .data_in_from_pins_p(data_in_from_pins_p),
        .data_in_to_device(data_in_to_device),
        .CLK_IN1_D_clk_n(diff_clk_in_clk_n),
        .CLK_IN1_D_clk_p(diff_clk_in_clk_p),
        .io_reset(reset));
		
		
	wire [9:0] data_0;
	wire [9:0] data_1;
	wire [9:0] data_2;
	
    assign data_0 = {data_in_to_device[27],
	                  data_in_to_device[24],
	                  data_in_to_device[21],
	                  data_in_to_device[18],
	                  data_in_to_device[15],
	                  data_in_to_device[12],
	                  data_in_to_device[9],
	                  data_in_to_device[6],
	                  data_in_to_device[3],
	                  data_in_to_device[0]}	;
					  
    assign data_1 = {data_in_to_device[28],
	                  data_in_to_device[25],
	                  data_in_to_device[22],
	                  data_in_to_device[19],
	                  data_in_to_device[16],
	                  data_in_to_device[13],
	                  data_in_to_device[10],
	                  data_in_to_device[7],
	                  data_in_to_device[4],
	                  data_in_to_device[1]}	;
					  
    assign data_2 = {data_in_to_device[29],
	                  data_in_to_device[26],
	                  data_in_to_device[23],
	                  data_in_to_device[20],
	                  data_in_to_device[17],
	                  data_in_to_device[14],
	                  data_in_to_device[11],
	                  data_in_to_device[8],
	                  data_in_to_device[5],
	                  data_in_to_device[2]}	;		  
	
	hdmi_to_rgb hdmi_to_rgb (
	.rxclk(rxclk),
	.data_in(data_in_to_device), 
    .exrst       (reset),
    .hsync       (rx0_hsync),
    .vsync       (rx0_vsync),
    .de          (rx0_de),
    .red         (rx0_red),
    .green       (rx0_green),
    .blue        (rx0_blue),
	.bitslip(bitslip)
	); 


wire sda_o;
wire i2c_led;
        i2c_trc_top i2c_trc_top (
                .clk(clk), 
                .rst(reset), 
                .s_scl(scl), 
				.s_sda(sda),
                .m_scl(m_scl),  
                .m_sda(m_sda),
				.led(i2c_led)
        ) ;
		
	assign  hsync = rx0_hsync;
	assign  vsync = rx0_vsync;
	assign  red_da = (rx0_de==1'b0)?5'b00000:rx0_red[7:3];
	assign  green_da = (rx0_de==1'b0)?6'b000000:rx0_green[7:2];
	assign  blue_da = (rx0_de==1'b0)?5'b00000:rx0_blue[7:3];
	 
	 
	always@(posedge clk)
	  if(reset==1'b1)
        cnt <= 24'd0;
      else
        cnt <= cnt + 24'd1;

	
	always@(posedge rxclk)
	  if(reset==1'b1)
        cnt2 <= 24'd0;
      else
        cnt2 <= cnt2 + 24'd1;

    assign led2 = cnt2[23];		
	
	
	always@(posedge clk)
	begin
	  mon_hsync <= rx0_hsync;
	  mon_vsync <= rx0_vsync;
	  mon_data <={red_da,blue_da};
	 end
	  
	always@(posedge rxclk)
	begin	 
	  data_0_d <= data_0;
	  data_1_d <= data_1;
	  data_2_d <= data_2;	  
	end
	
	
	always@(posedge clk)
	  led <= ((^data_0_d)^(^data_1_d)^(^data_2_d))&cnt[23] & (^rx0_blue);
	  
	reg [3:0]mon_clk_cnt; 
 
    always@(posedge rx0_pclk)
      if(reset==1'b1)
        mon_clk_cnt <= 4'd0;
      else
        if(mon_clk_cnt==4'd9)	  
          mon_clk_cnt <= 4'd0;
		else
          mon_clk_cnt <= mon_clk_cnt + 4'd1;
		  
	assign mon_pclk =mon_clk_cnt[3];
	
endmodule


