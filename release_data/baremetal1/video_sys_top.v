//*****************************************************************************
// File Name            : video_sys_top.v
//-----------------------------------------------------------------------------
// Function             : video_sys_top
//
//-----------------------------------------------------------------------------
// Designer             : yokomizo
//-----------------------------------------------------------------------------
// History
// -.-- 2015/07/31
//*****************************************************************************
`timescale 1 ps / 1 ps

module video_sys_top
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
    //gpio_rtl_tri_o
    led,
    vo_vsync,
    vo_hsync,
    vo_r_data,
    vo_g_data,
    vo_b_data
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
  //output FCLK_CLK0;
  //output FCLK_RESET0_N;
  inout FIXED_IO_ddr_vrn;
  inout FIXED_IO_ddr_vrp;
  inout [53:0]FIXED_IO_mio;
  inout FIXED_IO_ps_clk;
  inout FIXED_IO_ps_porb;
  inout FIXED_IO_ps_srstb;
  //output [31:0]gpio_rtl_tri_o;
  output [3:0]led;
  output vo_vsync; //’Ç‰Á
  output vo_hsync; //’Ç‰Á
  output [4:0]vo_r_data; //’Ç‰Á
  output [5:0]vo_g_data; //’Ç‰Á
  output [4:0]vo_b_data; //’Ç‰Á

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
  wire [31:0]gpio_rtl_tri_o;
  wire vid_io_out_active_video; //’Ç‰Á
  wire [23:0]vid_io_out_data; //’Ç‰Á
  wire vid_io_out_field; //’Ç‰Á
  wire vid_io_out_hblank; //’Ç‰Á
  wire vid_io_out_hsync; //’Ç‰Á
  wire vid_io_out_vblank; //’Ç‰Á
  wire vid_io_out_vsync; //’Ç‰Á
  wire vo_en; //’Ç‰Á

  //video_sys video_sys_i
  video_sys_wrapper video_sys_wrapper_i
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
        .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
        .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
        .FIXED_IO_mio(FIXED_IO_mio),
        .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),
        .gpio_rtl_tri_o(gpio_rtl_tri_o),
        .vid_io_out_active_video(vid_io_out_active_video), //’Ç‰Á
        .vid_io_out_data(vid_io_out_data), //’Ç‰Á
        .vid_io_out_field(vid_io_out_field), //’Ç‰Á
        .vid_io_out_hblank(vid_io_out_hblank), //’Ç‰Á
        .vid_io_out_hsync(vid_io_out_hsync), //’Ç‰Á
        .vid_io_out_vblank(vid_io_out_vblank), //’Ç‰Á
        .vid_io_out_vsync(vid_io_out_vsync) //’Ç‰Á
        );
		
   assign led = {gpio_rtl_tri_o[3:0]};
   assign vo_vsync = vid_io_out_vsync; //’Ç‰Á
   assign vo_hsync = vid_io_out_hsync; //’Ç‰Á
   assign vo_en=((vid_io_out_vblank==1'b1)||(vid_io_out_hblank==1'b1))?1'b0:1'b1; //’Ç‰Á
   assign vo_r_data=(vo_en==1'b0)?5'b00000:vid_io_out_data[7:3]; //’Ç‰Á
   assign vo_g_data=(vo_en==1'b0)?6'b000000:vid_io_out_data[15:10]; //’Ç‰Á
   assign vo_b_data=(vo_en==1'b0)?5'b00000:vid_io_out_data[23:19]; //’Ç‰Á
   
endmodule
