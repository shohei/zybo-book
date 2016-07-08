//-----------------------------
// S_P.vhd
// Serial-Parallel Converter
// by Toshio Iwata at digitalfilter.com 2009/05/06

module S_P(
  RST_N,
  MCLK,
  MISO,
  CS_N,
  SCLK,
  LDATA
);

input RST_N;
input MCLK;
input MISO;
input CS_N;
input SCLK;
output[15:0] LDATA;

wire   RST_N;
wire   MCLK;
wire   MISO;
wire   SCLK;
reg   [15:0] LDATA;

reg  [15:0] pdata_tmp;
reg   CS_dly1;
reg   CS_dly2;
reg   CS_dly3;
wire  ldata_ld;
reg   ldata_latch;
reg  [7:0] counter208;
reg   SCLK_dly1;
wire  SCLK_edge;
wire  CS;

//-----------------------------------------------------------------
always@(posedge MCLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    SCLK_dly1 <= 1'b0;
  end
  else  begin
    SCLK_dly1 <= SCLK;
  end
end

assign SCLK_edge = SCLK &  ~SCLK_dly1;

assign CS = ~CS_N;

//-----------------------------------------------------------------
always@(posedge MCLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    CS_dly3 <= 1'b0;
    CS_dly2 <= 1'b0;
    CS_dly1 <= 1'b0;
  end
  else  begin
      CS_dly3 <= CS_dly2;
      CS_dly2 <= CS_dly1;
      CS_dly1 <= CS;
  end
end

assign ldata_ld = CS_dly2 &  ~CS_dly3;

//-----------------------------------------------------------------
always@(posedge MCLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    pdata_tmp <= {16{1'b0}};
  end
  else  begin
    if ((SCLK_edge == 1'b1)  )  begin
      pdata_tmp <= {pdata_tmp[14:0] ,MISO};
    end
  end
end

//-----------------------------------------------------------------
always@(posedge MCLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    LDATA <= {16{1'b0}};
  end
  else  begin
    if ((ldata_latch == 1'b1)  )  begin
      LDATA <= pdata_tmp;
    end
  end
end

//-----------------------------------------------------------------
always@(posedge MCLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    counter208 <= {8{1'b0}};
  end
  else  begin
    if ((ldata_ld == 1'b1)  )  begin
      counter208 <= {8{1'b0}};
    end
    else if ((SCLK_edge == 1'b1)  )  begin
      counter208 <= counter208 + 1;
    end
  end
end

//-----------------------------------------------------------------
always@(posedge MCLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    ldata_latch <= 1'b0;
  end
  else  begin
    if (SCLK_edge == 1'b1) begin
      if(counter208 == 15)  begin
         ldata_latch <= 1'b1;
      end
      else begin
         ldata_latch <= 1'b0;
      end
    end
  end
end

endmodule
