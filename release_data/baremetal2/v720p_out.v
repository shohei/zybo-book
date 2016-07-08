`timescale 1ns / 1ps
//*****************************************************************************
// File Name            : v720p_out.v
//-----------------------------------------------------------------------------
// Function             : v720p_out
//
//-----------------------------------------------------------------------------
// Designer             : yokomizo
//-----------------------------------------------------------------------------
// History
// -.-- 2015/09/06
//*****************************************************************************
module v720p_out(
 //clk,
 reset,
 clk, 
 aclk,
 hsync, vsync, red_da, green_da, blue_da,
 line_no,
 line_req,
 line_data_en,
 line_data,
 led 
);

  //input clk;
  input reset;
  input clk;
  input aclk;
  
  output        hsync;               // horizontal sync
  output        vsync;               // vertical sync
  output [ 4:0] red_da; // RGB color signals
  output [ 5:0] green_da; // RGB color signals
  output [ 4:0] blue_da; // RGB color signals
  //
  output [11:0]line_no;
  output  line_req;
  input   line_data_en;
  input  [31:0] line_data;
  output        led;
  /*
  //SVGA 800x600 
  parameter v_visible =600;
  parameter v_whole =628;
  parameter v_front_porch=1;
  parameter v_sync_pulse=4;
  parameter v_back_porch=23;
  parameter h_visible =800;
  parameter h_whole =1056;
  parameter h_front_porch=40;
  parameter h_sync_pulse=128;
  parameter h_back_porch=88;
  */
  //720p 1280x720 
  parameter v_visible =720;
  parameter v_whole =750;
  parameter v_front_porch=3;
  parameter v_sync_pulse=5;
  parameter v_back_porch=22;
  parameter h_visible =1280;
  parameter h_whole =1648;
  parameter h_front_porch=72;
  parameter h_sync_pulse=80;
  parameter h_back_porch=216;
  parameter h_line_req = 10;
  
  parameter v_max = v_whole -1 ; //V Whole frame -1 #1
  parameter v_sync_start = v_front_porch-1; //#0
  parameter v_sync_end = v_sync_start +v_sync_pulse ; //V Sync pulse-1
  parameter v_blank_off = v_sync_end + v_back_porch ; //#27
  parameter v_blank_off_end = v_blank_off + v_visible -1; //#626 
      
  parameter h_max = h_whole -1 ; //h Whole frame -1 #1055
  parameter h_sync_start = h_front_porch -1; //#39
  parameter h_sync_end= h_sync_start+ h_sync_pulse ;//H Sync #167
  parameter h_blank_off = h_sync_end+ h_back_porch; //#255
  parameter h_blank_on = h_blank_off + h_visible; //#1055
  parameter h_line_en_on =  h_blank_off -1;
  parameter h_line_en_off =  h_blank_on -1;
  wire  LOCKED;
  
   
reg            hsync;               // horizontal sync
reg            vsync;               // vertical sync
reg            blank;               // blanking signal
reg   [ 4:0]   red_da; // RGB color signals
reg   [ 5:0]   green_da; // RGB color signals
reg   [ 4:0]   blue_da; // RGB color signals
reg            da_en;
   
wire            pclk;   //72MHz CLK
wire            reset_locked;
reg [27:0]      clk_cnt=0;
   
//vga test
   reg   [11:0]     v_cnt_t;
   reg   [11:0]     h_cnt_t;
   reg              vsync_t;
   reg              hsync_t;
   reg              blank_t;
//line data

  reg [11:0]line_no;
  reg  line_req;
  reg  rd_fifo_en;

    wire [31:0] dout;
    wire [15:0] p_data;
    reg rd_t;
    wire rd_en;
    wire empty;
    wire full;
	reg [11:0]line_no_p;
	reg line_req_p;
	reg line_req_f1;
	reg line_req_f2;
	reg [12:0]data_cnt;
	wire wr_en;
	
assign reset_locked = ((reset==1'b1)||(LOCKED==1'b0))?1'b1:1'b0;
     
 clk_wiz_0 clk_gen
      (
      // Clock in ports
       .clk_in1(clk),      // input clk_in1
       // Clock out ports
       .clk_out1(pclk),     // output clk_out1
       // Status and control signals
       .reset(reset), // input reset
       .locked(LOCKED));      // output locked

 

always @ (posedge pclk )
  begin
     vsync <= vsync_t;
     hsync <= hsync_t;
     blank <= blank_t;
     da_en <= ~blank_t;
     if (blank_t==1'b0) begin
	 /*
        if(h_cnt_t[5:4]==2'b00)
          red_da <= 5'b11111;
        else
          red_da <= 5'b00000;
        if(h_cnt_t[5:4]==2'b01)
          green_da <= 6'b111111;
        else
          green_da <= 6'b000000;
        if(h_cnt_t[5:4]==2'b10)
          blue_da <= 5'b11111;
        else
          blue_da <= 5'b00000;
		  */
        red_da <= p_data[4:0];
        green_da <= p_data[10:5];
        blue_da <= p_data[15:11];  
     end
     else begin
        red_da <= 5'h0;
        green_da <= 6'h0;
        blue_da <= 5'h0;
     end        
  end // always @ (posedge pclk_i )
   
   
always @ (posedge pclk or posedge reset_locked )
  if (reset_locked==1'b1)begin
     v_cnt_t <= 12'h000;
     h_cnt_t <= 12'h000;
  end
  else
    //if (h_cnt_t==12'd1055) begin  // SVGA   
    if (h_cnt_t==h_max) begin      
       h_cnt_t <= 12'h000;
       //if (v_cnt_t==12'd627) //SVGA
       if (v_cnt_t==v_max)
         v_cnt_t <= 12'h000;
       else
         v_cnt_t <= v_cnt_t + 12'h001;
       end
    else 
       begin
         v_cnt_t <= v_cnt_t ;
         h_cnt_t <= h_cnt_t + 12'h001;
       end

  
always @ (posedge pclk or posedge reset_locked )
  if (reset_locked==1'b1)begin
     vsync_t <= 1'b1;
     hsync_t <= 1'b1;
     end
  else 
    begin
      if (h_cnt_t==h_sync_start) begin      
        hsync_t <= 1'b0;    
        //if(v_cnt_t==12'd627) //SVGA
        if (v_cnt_t==v_sync_start)
           vsync_t <= 1'b0;
        //else if (v_cnt_t==12'd3) // SVGA  
        else if (v_cnt_t==v_sync_end) 
           vsync_t <= 1'b1;
        else
           vsync_t <= vsync_t ;
        end
      //else if (h_cnt_t==12'd127)  // SVGA
      else if (h_cnt_t==h_sync_end)
	    begin    
        hsync_t <= 1'b1;    
        vsync_t <= vsync_t;
        end
      else begin    
        hsync_t <= hsync_t;    
        vsync_t <= vsync_t;
      end
   end

always @ (posedge pclk or posedge reset_locked )
  if (reset_locked==1'b1)
     blank_t <= 1'b1;
  else 
    //if (h_cnt_t==12'd212)   // SVGA 128+85-1
    if (h_cnt_t==h_blank_off)   //128+85-1
       //if (v_cnt_t==12'd26) //SVGA
       if((v_cnt_t>=v_blank_off)&&(v_cnt_t<=v_blank_off_end) )
          blank_t <= 1'b0;
	   else
         blank_t <=  1'b1;
    //else  if (h_cnt_t==12'd1012)// SVGA 
    else  if (h_cnt_t== h_blank_on) 
       blank_t <= 1'b1;
    else
      blank_t <=  blank_t;
       
          
always @ (posedge pclk  )
  if (reset_locked==1'b1)
    begin
	  line_no_p <=12'd0;
	  line_req_p <=1'b0;
	end
  else
    if((v_cnt_t>=v_blank_off)&&(v_cnt_t<=v_blank_off_end)&&(h_cnt_t== h_line_req) )
      begin
	    line_no_p <= v_cnt_t - v_blank_off ;
	    line_req_p <=1'b1;
	  end
	else
      begin
	    line_no_p <= line_no_p;
	    line_req_p <=1'b0;
      end
	  
always @ (posedge pclk or posedge reset_locked )
  if (reset_locked==1'b1)
     rd_fifo_en <= 1'b0;
  else 
    //if (h_cnt_t==12'd212)   // SVGA 128+85-1
    if (h_cnt_t==h_line_en_on)   //128+85-1
       //if (v_cnt_t==12'd26) //SVGA
       if((v_cnt_t>=v_blank_off)&&(v_cnt_t<=(v_blank_off_end+16)) )
          rd_fifo_en <= 1'b1;
	   else
         rd_fifo_en <=  1'b0;
    //else  if (h_cnt_t==12'd1012)// SVGA 
    else  if (h_cnt_t== h_line_en_off) 
       rd_fifo_en <= 1'b0;
    else
      rd_fifo_en <=  rd_fifo_en;
	  
   
always @ (posedge pclk  )
     clk_cnt <= clk_cnt + 28'd1;
    
assign led = clk_cnt[27];
   
   
always @ (posedge aclk  )
  if (reset_locked==1'b1)
    begin
      line_req_f1 <= 1'b0;
      line_req_f2 <= 1'b0;
      line_req <= 1'b0;
	end
  else 
    begin
      line_req_f1 <= line_req_p;
      line_req_f2 <= line_req_f1;
      line_req <= line_req_f2;
	end
  
always @ (posedge aclk  )
  if (reset_locked==1'b1)
    line_no <= 12'd0;
  else
    if(( line_req_f2==1'b1)&&(line_req==1'b0))
      line_no <= line_no_p;
	else
      line_no <= line_no;
   
   
always @ (posedge aclk  )
  if (reset_locked==1'b1)
    data_cnt <= 12'd0;
  else
    if(( line_req_f2==1'b1)&&(line_req==1'b0))
      data_cnt <= 12'd0;
	else if(line_data_en==1'b1)
      data_cnt <= data_cnt + 12'd1;
	else
      data_cnt <= data_cnt;
	  
assign wr_en = ((line_data_en==1'b1)&&(data_cnt<12'd640))?1'b1:1'b0;
	  
	  
 fifo_generator_0  fifo_generator_0(
        //.rst(reset_locked ),
        .wr_clk( aclk),
        .rd_clk(pclk),
        .din(line_data),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .dout(dout),
        .full(full),
        .empty (empty));
                         

  
  always @(posedge pclk)                                                                              
    begin                                                                                                     
      if (reset_locked==1'b1)
        rd_t <=0;
      else
       if(rd_fifo_en==1'b1)
         rd_t <= ~rd_t;
       else
         rd_t <= 1'b0;  
    end
	
   assign rd_en = ((rd_fifo_en==1'b1)&&(rd_t==1'b0))?1'b1:1'b0;      
   
   assign  p_data = (rd_t==1'b1)?dout[15:0]:dout[31:16];
   
endmodule
