//-----------------------------
// P_S.vhd
// Parallel-Serial Converter
// by Toshio Iwata at digitalfilter.com 2009/05/06

module P_S(
  RST_N,
  MCLK,
  BCLK,
  LDATA,
  STARTX,
  MOSI,
  CS_N,
  SCLK
);

input RST_N;
input MCLK;
input BCLK;
input STARTX;
input[15:0] LDATA;
output CS_N, MOSI, SCLK;

wire   RST_N;
wire   MCLK;
wire   BCLK;
wire  [15:0] LDATA;
reg    CS_N, SCLK, MOSI;


reg  [15:0] rdata_tmp;
reg  [7:0] counter256;
reg   STARTX_dly1;
reg   STARTX_dly2;
reg   STARTX_dly3;
wire  ldata_ld;
reg   bclk_dly1;
wire  bclk_edge;
reg  sclk_enb;

// architecture P_S
//-----------------------------------------------------------------
always@(posedge MCLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    rdata_tmp <= {16{1'b0}};
  end
  else  begin
    if ((bclk_edge == 1'b1)  )  begin
      if ((ldata_ld == 1'b1)  )  begin
        rdata_tmp <= LDATA;
      end
      else  begin
        rdata_tmp <= {rdata_tmp[14:0] ,1'b0};
      end
    end
  end
end

//-----------------------------------------------------------------
always@(posedge MCLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    MOSI <= 1'b0;
  end
  else  begin
    MOSI <= rdata_tmp[15];
  end
end

//-----------------------------------------------------------------
always@(posedge MCLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    STARTX_dly3 <= 1'b0;
    STARTX_dly2 <= 1'b0;
    STARTX_dly1 <= 1'b0;
  end
  else  begin
    if ((bclk_edge == 1'b1)  )  begin
      STARTX_dly3 <= STARTX_dly2;
      STARTX_dly2 <= STARTX_dly1;
      STARTX_dly1 <= STARTX;
    end
  end
end

assign ldata_ld = STARTX_dly2 &  ~STARTX_dly3;

//-----------------------------------------------------------------
always@(posedge MCLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    bclk_dly1 <= 1'b0;
  end
  else  begin
    bclk_dly1 <= BCLK;
  end
end

assign bclk_edge = BCLK &  ~bclk_dly1;

//-----------------------------------------------------------------
always@(posedge MCLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    counter256 <= {8{1'b1}};
  end
  else  begin
    if ((bclk_edge == 1'b1)  )  begin
      if ( STARTX_dly1 == 1'b1 && STARTX_dly2 == 1'b0 )  begin
        counter256 <= {8{1'b0}};
      end
      else if(counter256 != 16) begin
        counter256 <= counter256 + 1;
      end
    end
  end
end

//-----------------------------------------------------------------
always@(posedge MCLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    sclk_enb <= 1'b0;
  end
  else  begin
    if ((bclk_edge == 1'b1)  )  begin
      if( counter256 < 16 ) begin
        sclk_enb <= 1'b1;
      end else begin
        sclk_enb <= 1'b0;
      end
    end
  end
end

//-----------------------------------------------------------------
always@(posedge MCLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    SCLK <= 1'b1;
  end
  else  begin
    SCLK <= ~(bclk_dly1 & sclk_enb);
  end
end

//-----------------------------------------------------------------
always@(posedge MCLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    CS_N <= 1'b1;
  end
  else  begin
    CS_N <= ~(ldata_ld | sclk_enb);
  end
end

endmodule
