//Copyright 1986-2015 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2015.4 (win64) Build 1412921 Wed Nov 18 09:43:45 MST 2015
//Date        : Mon Jan 11 17:12:49 2016
//Host        : M-PC running 64-bit Service Pack 1  (build 7601)
//Command     : generate_target user_ip_sys_wrapper.bd
//Design      : user_ip_sys_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module user_ip_sys_top
   (DDR_addr,
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
    sl_user_data, //�ǉ�
    clk_125m, //�ǉ�
    reset, //�ǉ�
    hsync, vsync, red_da, green_da, blue_da //�ǉ�
    );
    
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
  output [3:0]sl_user_data; //�ǉ�
  input clk_125m;//�ǉ�
  input reset;//�ǉ�
  output        hsync;               // horizontal sync �ǉ�
  output        vsync;               // vertical sync �ǉ�
  output [ 4:0] red_da; // RGB color signals �ǉ�
  output [ 5:0] green_da; // RGB color signals �ǉ�
  output [ 4:0] blue_da; // RGB color signals �ǉ�

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
  wire FIXED_IO_ddr_vrn;
  wire FIXED_IO_ddr_vrp;
  wire [53:0]FIXED_IO_mio;
  wire FIXED_IO_ps_clk;
  wire FIXED_IO_ps_porb;
  wire FIXED_IO_ps_srstb;
  wire [31:0]line_data; //�ǉ�
  wire line_data_en; //�ǉ�
  wire [11:0]line_no; //�ǉ�
  wire line_req; //�ǉ�
  wire [3:0]sl_user_data; //�ǉ�
  wire aclk; //�ǉ�

 // user_ip_sys user_ip_sys_i
 user_ip_sys_wrapper user_ip_sys_wrapper_i
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
        .FCLK_CLK0(aclk), //�ǉ�
        .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
        .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
        .FIXED_IO_mio(FIXED_IO_mio),
        .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),
        .sl_user_data(sl_user_data),
        .line_data(line_data),
        .line_data_en(line_data_en),
        .line_no(line_no),
        .line_req(line_req)
        );
        
  //�ǉ� v720p_out
 v720p_out v720p_out(
       .reset(reset),
       .clk(clk_125m), 
       .aclk(aclk), 
       .hsync(hsync), 
       .vsync(vsync), 
       .red_da(red_da), 
       .green_da(green_da), 
       .blue_da(blue_da),
       .line_no(line_no),
       .line_req(line_req),
       .line_data_en(line_data_en),
       .line_data(line_data),
       .led(led_vo)
       );
endmodule
