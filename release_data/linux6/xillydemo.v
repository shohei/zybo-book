module xillydemo
  (
  input  clk_100,
  input  otg_oc,   
  //inout [55:0] PS_GPIO,
  inout [31:0] PS_GPIO,
  output [3:0] GPIO_LED,
  output [4:0] vga4_blue,
  output [5:0] vga4_green,
  output [4:0] vga4_red,
  output  vga_hsync,
  output  vga_vsync,
  output  audio_mclk,
  output  audio_dac,
  input  audio_adc,
  input  audio_bclk,
  input  audio_adc_lrclk,
  input  audio_dac_lrclk,
  output  audio_mute,
  output  hdmi_clk_p,
  output  hdmi_clk_n,
  output [2:0] hdmi_d_p,
  output [2:0] hdmi_d_n,
  output  hdmi_out_en,
  inout  smb_sclk,
  inout  smb_sdata,
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
  output [2:0] line
  ); 

   // Clock and quiesce
   wire    bus_clk;
   wire    quiesce;
   
   wire [1:0] smbus_addr;

   // Memory arrays
   reg [7:0] demoarray[0:31];
   
   reg [7:0] litearray0[0:31];
   reg [7:0] litearray1[0:31];
   reg [7:0] litearray2[0:31];
   reg [7:0] litearray3[0:31];

   // Wires related to /dev/xillybus_mem_8
   wire      user_r_mem_8_rden;
   wire      user_r_mem_8_empty;
   reg [7:0] user_r_mem_8_data;
   wire      user_r_mem_8_eof;
   wire      user_r_mem_8_open;
   wire      user_w_mem_8_wren;
   wire      user_w_mem_8_full;
   wire [7:0] user_w_mem_8_data;
   wire       user_w_mem_8_open;
   wire [4:0] user_mem_8_addr;
   wire       user_mem_8_addr_update;

   // Wires related to /dev/xillybus_read_32
   wire       user_r_read_32_rden;
   wire       user_r_read_32_empty;
   wire [31:0] user_r_read_32_data;
   wire        user_r_read_32_eof;
   wire        user_r_read_32_open;

   // Wires related to /dev/xillybus_read_8
   wire        user_r_read_8_rden;
   wire        user_r_read_8_empty;
   wire [7:0]  user_r_read_8_data;
   wire        user_r_read_8_eof;
   wire        user_r_read_8_open;

   // Wires related to /dev/xillybus_write_32
   wire        user_w_write_32_wren;
   wire        user_w_write_32_full;
   wire [31:0] user_w_write_32_data;
   wire        user_w_write_32_open;

   // Wires related to /dev/xillybus_write_8
   wire        user_w_write_8_wren;
   wire        user_w_write_8_full;
   wire [7:0]  user_w_write_8_data;
   wire        user_w_write_8_open;

   // Wires related to /dev/xillybus_audio
   wire        user_r_audio_rden;
   wire        user_r_audio_empty;
   wire [31:0] user_r_audio_data;
   wire        user_r_audio_eof;
   wire        user_r_audio_open;
   wire        user_w_audio_wren;
   wire        user_w_audio_full;
   wire [31:0] user_w_audio_data;
   wire        user_w_audio_open;
 
   // Wires related to /dev/xillybus_smb
   wire        user_r_smb_rden;
   wire        user_r_smb_empty;
   wire [7:0]  user_r_smb_data;
   wire        user_r_smb_eof;
   wire        user_r_smb_open;
   wire        user_w_smb_wren;
   wire        user_w_smb_full;
   wire [7:0]  user_w_smb_data;
   wire        user_w_smb_open;

   // Wires related to Xillybus Lite
   wire        user_clk;
   wire        user_wren;
   wire [3:0]  user_wstrb;
   wire        user_rden;
   reg [31:0]  user_rd_data;
   wire [31:0] user_wr_data;
   wire [31:0] user_addr;
   wire        user_irq;

   wire  [55:32]PS_GPIO_DM;
   // Note that none of the ARM processor's direct connections to pads is
   // attached in the instantion below. Normally, they should be connected as
   // toplevel ports here, but that confuses Vivado 2013.4 to think that
   // some of these ports are real I/Os, causing an implementation failure.
   // This detachment results in a lot of warnings during synthesis and
   // implementation, but has no practical significance, as these pads are
   // completely unrelated to the FPGA bitstream.

   xillybus xillybus_ins (

    // Ports related to /dev/xillybus_mem_8
    // FPGA to CPU signals:
    .user_r_mem_8_rden(user_r_mem_8_rden),
    .user_r_mem_8_empty(user_r_mem_8_empty),
    .user_r_mem_8_data(user_r_mem_8_data),
    .user_r_mem_8_eof(user_r_mem_8_eof),
    .user_r_mem_8_open(user_r_mem_8_open),

    // CPU to FPGA signals:
    .user_w_mem_8_wren(user_w_mem_8_wren),
    .user_w_mem_8_full(user_w_mem_8_full),
    .user_w_mem_8_data(user_w_mem_8_data),
    .user_w_mem_8_open(user_w_mem_8_open),

    // Address signals:
    .user_mem_8_addr(user_mem_8_addr),
    .user_mem_8_addr_update(user_mem_8_addr_update),


    // Ports related to /dev/xillybus_read_32
    // FPGA to CPU signals:
    .user_r_read_32_rden(user_r_read_32_rden),
    .user_r_read_32_empty(user_r_read_32_empty),
    .user_r_read_32_data(user_r_read_32_data),
    .user_r_read_32_eof(user_r_read_32_eof),
    .user_r_read_32_open(user_r_read_32_open),


    // Ports related to /dev/xillybus_read_8
    // FPGA to CPU signals:
    .user_r_read_8_rden(user_r_read_8_rden),
    .user_r_read_8_empty(user_r_read_8_empty),
    .user_r_read_8_data(user_r_read_8_data),
    .user_r_read_8_eof(user_r_read_8_eof),
    .user_r_read_8_open(user_r_read_8_open),


    // Ports related to /dev/xillybus_write_32
    // CPU to FPGA signals:
    .user_w_write_32_wren(user_w_write_32_wren),
    .user_w_write_32_full(user_w_write_32_full),
    .user_w_write_32_data(user_w_write_32_data),
    .user_w_write_32_open(user_w_write_32_open),


    // Ports related to /dev/xillybus_write_8
    // CPU to FPGA signals:
    .user_w_write_8_wren(user_w_write_8_wren),
    .user_w_write_8_full(user_w_write_8_full),
    .user_w_write_8_data(user_w_write_8_data),
    .user_w_write_8_open(user_w_write_8_open),

    // Ports related to /dev/xillybus_audio
    // FPGA to CPU signals:
    .user_r_audio_rden(user_r_audio_rden),
    .user_r_audio_empty(user_r_audio_empty),
    .user_r_audio_data(user_r_audio_data),
    .user_r_audio_eof(user_r_audio_eof),
    .user_r_audio_open(user_r_audio_open),

    // CPU to FPGA signals:
    .user_w_audio_wren(user_w_audio_wren),
    .user_w_audio_full(user_w_audio_full),
    .user_w_audio_data(user_w_audio_data),
    .user_w_audio_open(user_w_audio_open),

    // Ports related to /dev/xillybus_smb
    // FPGA to CPU signals:
    .user_r_smb_rden(user_r_smb_rden),
    .user_r_smb_empty(user_r_smb_empty),
    .user_r_smb_data(user_r_smb_data),
    .user_r_smb_eof(user_r_smb_eof),
    .user_r_smb_open(user_r_smb_open),

    // CPU to FPGA signals:
    .user_w_smb_wren(user_w_smb_wren),
    .user_w_smb_full(user_w_smb_full),
    .user_w_smb_data(user_w_smb_data),
    .user_w_smb_open(user_w_smb_open),

    // Xillybus Lite signals:
    .user_clk ( user_clk ),
    .user_wren ( user_wren ),
    .user_wstrb ( user_wstrb ),
    .user_rden ( user_rden ),
    .user_rd_data ( user_rd_data ),
    .user_wr_data ( user_wr_data ),
    .user_addr ( user_addr ),
    .user_irq ( user_irq ),
			  			  
    // General signals
    .clk_100(clk_100),
    .otg_oc(otg_oc),
    .PS_GPIO({PS_GPIO_DM,PS_GPIO}),
    .GPIO_LED(GPIO_LED),
    .bus_clk(bus_clk),
    .quiesce(quiesce),

    // HDMI (DVI) related signals
    .hdmi_clk_p(hdmi_clk_p),
    .hdmi_clk_n(hdmi_clk_n),
    .hdmi_d_p(hdmi_d_p),
    .hdmi_d_n(hdmi_d_n),
    .hdmi_out_en(hdmi_out_en),			  

    // VGA port related outputs			    
    .vga4_blue(vga4_blue),
    .vga4_green(vga4_green),
    .vga4_red(vga4_red),
    .vga_hsync(vga_hsync),
    .vga_vsync(vga_vsync)
  );

   assign      user_irq = 0; // No interrupts for now
   
   always @(posedge user_clk)
     begin
	if (user_wstrb[0])
	  litearray0[user_addr[6:2]] <= user_wr_data[7:0];

	if (user_wstrb[1])
	  litearray1[user_addr[6:2]] <= user_wr_data[15:8];

	if (user_wstrb[2])
	  litearray2[user_addr[6:2]] <= user_wr_data[23:16];

	if (user_wstrb[3])
	  litearray3[user_addr[6:2]] <= user_wr_data[31:24];
	
	if (user_rden)
	  user_rd_data <= { litearray3[user_addr[6:2]],
			    litearray2[user_addr[6:2]],
			    litearray1[user_addr[6:2]],
			    litearray0[user_addr[6:2]] };
     end
   
   // A simple inferred RAM
   always @(posedge bus_clk)
     begin
	if (user_w_mem_8_wren)
	  demoarray[user_mem_8_addr] <= user_w_mem_8_data;
	
	if (user_r_mem_8_rden)
	  user_r_mem_8_data <= demoarray[user_mem_8_addr];	  
     end

   assign  user_r_mem_8_empty = 0;
   assign  user_r_mem_8_eof = 0;
   assign  user_w_mem_8_full = 0;

   // 32-bit loopback
   fifo_32x512 fifo_32
     (
      .clk(bus_clk),
      .srst(!user_w_write_32_open && !user_r_read_32_open),
      .din(user_w_write_32_data),
      .wr_en(user_w_write_32_wren),
      .rd_en(user_r_read_32_rden),
      .dout(user_r_read_32_data),
      .full(user_w_write_32_full),
      .empty(user_r_read_32_empty)
      );
 
   assign  user_r_read_32_eof = 0;
   
   //led_matrix_ctrl ’Ç‰Á
   led_matrix_ctrl led_matrix_ctrl(
      .clk(bus_clk),
      .reset(!user_w_write_32_open && !user_r_read_32_open),
      .data_in(user_w_write_32_data),
      .data_in_en(user_w_write_32_wren),
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
   
   // 8-bit loopback
   fifo_8x2048 fifo_8
     (
      .clk(bus_clk),
      .srst(!user_w_write_8_open && !user_r_read_8_open),
      .din(user_w_write_8_data),
      .wr_en(user_w_write_8_wren),
      .rd_en(user_r_read_8_rden),
      .dout(user_r_read_8_data),
      .full(user_w_write_8_full),
      .empty(user_r_read_8_empty)
      );

   assign  user_r_read_8_eof = 0;

   i2s_audio audio
     (
      .bus_clk(bus_clk),
      .clk_100(clk_100),
      .quiesce(quiesce),

      .audio_mclk(audio_mclk),
      .audio_dac(audio_dac),
      .audio_adc(audio_adc),
      .audio_adc_lrclk(audio_adc_lrclk),
      .audio_dac_lrclk(audio_dac_lrclk),
      .audio_mute(audio_mute),
      .audio_bclk(audio_bclk),
      
      .user_r_audio_rden(user_r_audio_rden),
      .user_r_audio_empty(user_r_audio_empty),
      .user_r_audio_data(user_r_audio_data),
      .user_r_audio_eof(user_r_audio_eof),
      .user_r_audio_open(user_r_audio_open),
      
      .user_w_audio_wren(user_w_audio_wren),
      .user_w_audio_full(user_w_audio_full),
      .user_w_audio_data(user_w_audio_data),
      .user_w_audio_open(user_w_audio_open)
      );
   
   smbus smbus
     (
      .bus_clk(bus_clk),
      .quiesce(quiesce),

      .smb_sclk(smb_sclk),
      .smb_sdata(smb_sdata),
      .smbus_addr(smbus_addr),

      .user_r_smb_rden(user_r_smb_rden),
      .user_r_smb_empty(user_r_smb_empty),
      .user_r_smb_data(user_r_smb_data),
      .user_r_smb_eof(user_r_smb_eof),
      .user_r_smb_open(user_r_smb_open),
      
      .user_w_smb_wren(user_w_smb_wren),
      .user_w_smb_full(user_w_smb_full),
      .user_w_smb_data(user_w_smb_data),
      .user_w_smb_open(user_w_smb_open)
      );

endmodule
