module xillydemo
  (
  input  clk_100,
  input  otg_oc,   
  inout [55:0] PS_GPIO,
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
  inout  smb_sdata   
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

  reg [3:0] led_reg;

   wire        audio_adc_dly;
   wire        audio_bclk_dly;
   wire        audio_adc_lrclk_dly;
   wire        audio_dac_lrclk_l_dly;
   wire        audio_dac_lrclk_r_dly;

   wire [15:0] finterInL;
   wire [15:0] finterInR;
   wire [15:0] fromSPL;
   wire [15:0] fromSPR;
   wire [15:0] filterOutL, filterOutR;
         
   reg audio_dac_lrclk_l_dly1, audio_dac_lrclk_l_dly2, audio_dac_lrclk_l_dly3;
   reg TestMode, TestRead, TestWrite, TestReset;
   wire FifoWrEnb, FifoRdEnb;
   wire [31:0] fromFIFO;
   reg TestReset_dly1, TestReset_dly2, TestReset_dly3;
   wire LRCLK_edge, TestReset_edge;
   wire RST_N;
   
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
    .PS_GPIO(), //PS_GPIO),
    .GPIO_LED(),
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
//   always @(posedge bus_clk)
//     begin
//	   if (user_w_mem_8_wren) begin
//	     demoarray[user_mem_8_addr] <= user_w_mem_8_data;
//	   end
//	
//	   if (user_r_mem_8_rden && user_mem_8_addr != 0) begin
//	     user_r_mem_8_data <= demoarray[user_mem_8_addr];	  
//	   end
//	   else begin
//	     user_r_mem_8_data <= {4'b0000, PS_GPIO[14:11]};
//	   end
 //    end

   always @(posedge bus_clk)
     begin
	  if (user_w_mem_8_wren) begin
        if (user_mem_8_addr == 0) begin // enable fifo write by cpu
          TestMode  <= user_w_mem_8_data[0];  
          TestRead  <= user_w_mem_8_data[1];  
          TestWrite  <= user_w_mem_8_data[2];  
          TestReset  <= user_w_mem_8_data[3];  
        end 
      end
     end
   
   assign  user_r_mem_8_empty = 0;
   assign  user_r_mem_8_eof = 0;
   assign  user_w_mem_8_full = 0;

//-----------------------------------------------------------------
      always@(posedge bus_clk)  begin
        begin
          audio_dac_lrclk_l_dly3 <= audio_dac_lrclk_l_dly2;
          audio_dac_lrclk_l_dly2 <= audio_dac_lrclk_l_dly1;
          audio_dac_lrclk_l_dly1 <= audio_dac_lrclk_l_dly;
        end
      end
      
//-----------------------------------------------------------------
         always@(posedge bus_clk)  begin
           begin
             TestReset_dly3 <= TestReset_dly2;
             TestReset_dly2 <= TestReset_dly1;
             TestReset_dly1 <= TestReset;
           end
         end
         
   assign LRCLK_edge = (audio_dac_lrclk_l_dly3 == 1'b0 
                   && audio_dac_lrclk_l_dly2 == 1'b1) ? 1'b1 : 1'b0;
                   
   assign TestReset_edge = (TestReset_dly3 == 1'b0 
                             && TestReset_dly2 == 1'b1) ? 1'b1 : 1'b0;
                             
   //-----------------------------------------------------------------
   assign FifoWrEnb = (LRCLK_edge == 1'b1
                                    && TestWrite == 1'b1)? 1'b1 : 1'b0;
                                    
   assign FifoRdEnb = (LRCLK_edge == 1'b1
                                    && TestRead == 1'b1)? 1'b1 : 1'b0;
                                                                                                                                          
   assign RST_N = ! TestReset_edge;

   assign finterInL = (TestMode == 1'b1)? fromFIFO[15:0] : fromSPL;
   assign finterInR = fromSPR;
                                                                                                                                         
   // 32-bit loopback
   fifo_32x512 fifo_32_in
     (
      .clk(bus_clk),
      .srst(!user_w_write_32_open), // by iwata && !user_r_read_32_open),
      .din(user_w_write_32_data),
      .wr_en(user_w_write_32_wren),
      .rd_en(FifoRdEnb), // by iwata user_r_read_32_rden),
      .dout(fromFIFO), // by iwata user_r_read_32_data),
      .full(user_w_write_32_full),
      .empty() // by iwata user_r_read_32_empty)
      );

   // 32-bit loopback
   fifo_32x512 fifo_32_out
     (
      .clk(bus_clk),
      .srst( !user_r_read_32_open),
      .din({16'h0000, filterOutL}), // by iwata user_w_write_32_data),
      .wr_en(FifoWrEnb), // by iwata user_w_write_32_wren),
      .rd_en(user_r_read_32_rden),
      .dout(user_r_read_32_data),
      .full(), // by iwata user_w_write_32_full),
      .empty(user_r_read_32_empty)
      );

   assign  user_r_read_32_eof = 0;
   
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

   assign audio_mute = 1;

   i2s_audio audio
     (
      .bus_clk(bus_clk),
      .clk_100(clk_100),
      .quiesce(quiesce),

      .audio_mclk(audio_mclk),
      .audio_dac(), //audio_dac),
      .audio_adc(audio_adc),
      .audio_adc_lrclk(audio_adc_lrclk),
      .audio_dac_lrclk(audio_dac_lrclk),
      .audio_mute(), //audio_mute),
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
   
   initial_latch
   (
      .RST_N(1'b1),
      .MCLK(audio_mclk),
      .ADATA(audio_adc),
      .ADATAO(audio_adc_dly),
      .ABCLK(audio_bclk),
      .ABCLKO(audio_bclk_dly),
      .ALRCLK(audio_adc_lrclk),
      .DLRCLK(audio_dac_lrclk),
      .ALRCLKO(audio_adc_lrclk_dly),
      .DLRCLKO_L(audio_dac_lrclk_l_dly),
      .DLRCLKO_R(audio_dac_lrclk_r_dly)
    );

    S_P
    (
      .RST_N(1'b1),
      .MCLK(audio_mclk),
      .SDATA(audio_adc_dly),
      .LRCLK(audio_adc_lrclk_dly),
      .BCLK(1'b1),
      .LDATA(fromSPL),
      .RDATA(fromSPR)
    );

    P_S(
      .RST_N(1'b1),
      .MCLK(audio_mclk),
      .LATCH_L(audio_dac_lrclk_l_dly),
      .LATCH_R(audio_dac_lrclk_r_dly),
      .BCLK(1'b1),
      .LDATA(filterOutL),
      .RDATA(filterOutR),
      .SDATA(audio_dac)
    );
  
// cutoff 3k 
    MuxIir iir_l(
      .RST_N(RST_N), //by iwata 1'b1),
      .MCLK(audio_mclk),
      .FSCLK(audio_adc_lrclk_dly),
    .A0(16'b0000000111101011), 
    .A1(16'b0000001111010111), 
    .A2(16'b0000000111101011), 
    .B1(16'b0101110100001000), 
    .B2(16'b1101101101001001),
//    .A0(a0_sig),
//    .A1(a1_sig),
//    .A2(a2_sig),
//    .B1(b1_sig),
//    .B2(b2_sig),
      .XIN(finterInL),
      .YOUT(filterOutL)
    );
 
// cutoff 3k 
    MuxIir iir_r(
      .RST_N(RST_N),
      .MCLK(audio_mclk),
      .FSCLK(audio_adc_lrclk_dly),
      .A0(16'b0000000111101011), 
      .A1(16'b0000001111010111), 
      .A2(16'b0000000111101011), 
      .B1(16'b0101110100001000), 
      .B2(16'b1101101101001001),
//    .A0(a0_sig),
//    .A1(a1_sig),
//    .A2(a2_sig),
//    .B1(b1_sig),
//    .B2(b2_sig),
      .XIN(finterInR),
      .YOUT(filterOutR)
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
