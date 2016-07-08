`timescale 1ns / 1ps
//2015.11.07 k.yokomizo
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
	mon_pclk,
    //mem_if_sys add trg_2015_12
	DDR_addr,
	DDR_ba,
	DDR_cas_n,
	DDR_ck_n,
	DDR_ck_p,
	DDR_cke,
	DDR_cs_n,
	DDR_dm,
	DDR_dq,
	DDR_dqs_n,
	DDR_dqs_p,
	DDR_odt,
	DDR_ras_n,
	DDR_reset_n,
	DDR_we_n,
	FIXED_IO_ddr_vrn,
	FIXED_IO_ddr_vrp,
	FIXED_IO_mio,
	FIXED_IO_ps_clk,
	FIXED_IO_ps_porb,
	FIXED_IO_ps_srstb,
	sw_stop,
	in_vram_no
	//mode_sw //hls
	//mem_if_sys add trg_2015_12 end
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
  //mem_if_sys add trg_2015_12 start 
  inout [14:0]DDR_addr;
  inout [2:0]DDR_ba;
  inout DDR_cas_n;
  inout DDR_ck_n;
  inout DDR_ck_p;
  inout DDR_cke;
  inout DDR_cs_n;
  inout [3:0]DDR_dm;
  inout [31:0]DDR_dq;
  inout [3:0]DDR_dqs_n;
  inout [3:0]DDR_dqs_p;
  inout DDR_odt;
  inout DDR_ras_n;
  inout DDR_reset_n;
  inout DDR_we_n;
  inout FIXED_IO_ddr_vrn;
  inout FIXED_IO_ddr_vrp;
  inout [53:0]FIXED_IO_mio;
  inout FIXED_IO_ps_clk;
  inout FIXED_IO_ps_porb;
  inout FIXED_IO_ps_srstb;
  input sw_stop;
  input [1:0]in_vram_no;
  //input [1:0]mode_sw;
  //mem_if_sys add trg_2015_12 end
  //
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
  wire [23:0] v_wr_data;
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
  //i2c
  wire sda_o;
  wire i2c_led;
  //
  //mem_if_sys add trg_2015_12 start 
  wire [ 7:0] red_da_8; // RGB color signals
  wire [ 7:0] green_da_8; // RGB color signals
  wire [ 7:0] blue_da_8; // RGB color signals
  wire [14:0]DDR_addr;
  wire [2:0]DDR_ba;
  wire DDR_cas_n;
  wire DDR_ck_n;
  wire DDR_ck_p;
  wire DDR_cke;
  wire DDR_cs_n;
  wire [3:0]DDR_dm;
  wire [31:0]DDR_dq;
  wire [3:0]DDR_dqs_n;
  wire [3:0]DDR_dqs_p;
  wire DDR_odt;
  wire DDR_ras_n;
  wire DDR_reset_n;
  wire DDR_we_n;
  wire FCLK_CLK0;
  wire FCLK_RESET0_N;
  wire FIXED_IO_ddr_vrn;
  wire FIXED_IO_ddr_vrp;
  wire [53:0]FIXED_IO_mio;
  wire FIXED_IO_ps_clk;
  wire FIXED_IO_ps_porb;
  wire FIXED_IO_ps_srstb;
  wire [7:0]gpio_rtl_tri_o;
  wire [7:0]gpio_rtl_0_tri_i;
  wire [23:0] v_wr_data;
  wire [31:0]line_data;
  wire line_data_en;
  wire [11:0]line_no;
  wire [1:0]vram_no;
  wire line_req;
  wire line_req_dmy;
  wire pclk;
  wire u_rack;
  wire [19:0]u_radr;
  wire [31:0]u_rd_da;
  wire u_rd_da_en;
  wire u_rreq;
  wire u_wack;
  wire [21:0]u_wadr;
  wire [31:0]u_wr_da;
  wire u_wr_da_en;
  wire u_wreq;
  wire sys_reset;   
  reg [23:0] stop_n_rstb_cnt;
  wire stop_n;
  wire stop_n_rstb;
  reg stop_n_rstb_reg1;
  reg stop_n_rstb_reg2;
  //wire hsl_de;             // hls data enable
  //wire [7:0] hls_red;      // hls pixel data out
  //wire [7:0] hls_green;    // hls pixel data out
  //wire [7:0] hls_blue;     // hls pixel data out
  //mem_if_sys add trg_2015_12 end
  
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
  //mem_if_sys add trg_2015_12 start 
 assign stop_n = ~sw_stop;
 assign stop_n_rstb=((stop_n==1'b0)||(FCLK_RESET0_N==1'b0))?1'b0:1'b1;
   
always @ (posedge FCLK_CLK0 or negedge stop_n_rstb )
  if (stop_n_rstb==1'b0)
    stop_n_rstb_cnt <= 24'd0;
  else
    if (stop_n_rstb_cnt==24'hffffff)
      stop_n_rstb_cnt <=24'hffffff;
    else
      stop_n_rstb_cnt <= stop_n_rstb_cnt + 24'd1;
      
always @ (posedge FCLK_CLK0 or negedge stop_n_rstb )
  if (stop_n_rstb==1'b0)
    stop_n_rstb_reg1 <=  1'b0;
  else
    if(stop_n_rstb_cnt==24'h7fffff)
      stop_n_rstb_reg1 <= 1'b1;
    else
      stop_n_rstb_reg1 <=  stop_n_rstb_reg1 ;
      
always @ (posedge FCLK_CLK0 or negedge stop_n_rstb )
  if (stop_n_rstb==1'b0)
    stop_n_rstb_reg2 <=  1'b0;
  else
    if(stop_n_rstb_cnt==24'hffffff)
      stop_n_rstb_reg2 <= 1'b1;
    else
      stop_n_rstb_reg2 <=  stop_n_rstb_reg2 ; 
          
assign reset_n = ~reset;

/*
    hls_block_top hls_block_top ( //hsl
    .clk(rxclk),
    .reset(reset_o),
    .da_i_en     (rx0_de),
    .da_r_i      (rx0_red),
    .da_g_i      (rx0_green),
    .da_b_i      (rx0_blue),
    .da_o_en     (hls_de),
    .da_r_o      (hls_red),
    .da_g_o      (hls_green),
    .da_b_o      (hls_blue),
    .mode_sw     (mode_sw)
    ); 
*/
assign v_wr_data ={rx0_blue,rx0_green,rx0_red};
//assign v_wr_data ={hls_blue,hls_green,hls_red}; //hls

   line_buf_in line_buf_in (
     .pclk(             rxclk),
     .ram_clk(          FCLK_CLK0),
     .reset_n(          stop_n_rstb_reg1), 
     .v_wr(             rx0_de), 
    // .v_wr(             hls_de), 
     .v_wr_vsync(       rx0_vsync),
     .v_wr_data(        v_wr_data),
     //                    
     .u_wreq(           u_wreq),   
     .u_wack(           u_wack),    
     .u_wr_da_en(       u_wr_da_en),    
     .u_wadr(           u_wadr),    
     .u_wr_da(          u_wr_da )
   );
 
mem_if_sys mem_if_sys_i
       (.DDR_addr(DDR_addr),
        .DDR_ba(DDR_ba),
        .DDR_cas_n(DDR_cas_n),
        .DDR_ck_n(DDR_ck_n),
        .DDR_ck_p(DDR_ck_p),
        .DDR_cke(DDR_cke),
        .DDR_cs_n(DDR_cs_n),
        .DDR_dm(DDR_dm),
        .DDR_dq(DDR_dq),
        .DDR_dqs_n(DDR_dqs_n),
        .DDR_dqs_p(DDR_dqs_p),
        .DDR_odt(DDR_odt),
        .DDR_ras_n(DDR_ras_n),
        .DDR_reset_n(DDR_reset_n),
        .DDR_we_n(DDR_we_n),
        .FCLK_CLK0(FCLK_CLK0),
        .FCLK_RESET0_N(FCLK_RESET0_N),
        .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
        .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
        .FIXED_IO_mio(FIXED_IO_mio),
        .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),
        .line_data(line_data),
        .line_data_en(line_data_en),
        .line_no(line_no),
        .vram_no(vram_no),
        .line_req(line_req),
        .u_wack(u_wack),
        .u_wadr(u_wadr),
        .u_wr_da(u_wr_da),
        .u_wr_da_en(u_wr_da_en),
        .u_wreq(u_wreq));

//assign gpio_rtl_0_tri_i = gpio_rtl_tri_o;
assign sys_reset = ~stop_n_rstb_reg2;
        
v480p_24b_out v480p_24b_out(
 .reset(sys_reset),
 .clk_125m(clk), 
 .aclk(FCLK_CLK0), 
 .hsync(hsync), 
 .vsync(vsync), 
 .red_da_8(red_da_8), 
 .green_da_8(green_da_8), 
 .blue_da_8(blue_da_8),
 .line_no(line_no),
 .in_vram_no(in_vram_no),
 .vram_no(vram_no),
 .line_req(line_req),
 .line_data_en(line_data_en),
 .line_data(line_data),
 .led(led_vo)
 );
assign     line_req_dmy =1'b0;
assign red_da = red_da_8[7:3]; 
assign green_da =green_da_8[7:2]; 
assign blue_da = blue_da_8[7:3];      
	  
  //mem_if_sys add trg_2015_12 end

        i2c_trc_top i2c_trc_top (
                .clk(clk), 
                .rst(reset), 
                .s_scl(scl), 
				.s_sda(sda),
                .m_scl(m_scl),  
                .m_sda(m_sda),
				.led(i2c_led)
        ) ;
		
          //mem_if_sys adel trg_2015_12 start
            /*    
            assign  hsync = rx0_hsync;
	assign  hsync = rx0_hsync;
	assign  vsync = rx0_vsync;
	assign  red_da = (rx0_de==1'b0)?5'b00000:rx0_red[7:3];
	assign  green_da = (rx0_de==1'b0)?6'b000000:rx0_green[7:2];
	assign  blue_da = (rx0_de==1'b0)?5'b00000:rx0_blue[7:3];
	 
        */ 
      //mem_if_sys adel trg_2015_12 end
	 
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


