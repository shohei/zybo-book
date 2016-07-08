//-----------------------------
// Serial-Parallel Converter
// by Toshio Iwata at digitalfilter.com 2015/06/02

module S_P(
  RST_N,
  MCLK,
  SDATA,
  LRCLK,
  BCLK,
  LDATA,
  RDATA
);

input RST_N;
input MCLK;
input SDATA;
input LRCLK;
input BCLK;
output[15:0] LDATA;
output[15:0] RDATA;

wire   RST_N;
wire   MCLK;
wire   SDATA;
wire   LRCLK;
wire   BCLK;
reg   [15:0] LDATA;
reg   [15:0] RDATA;


reg  [15:0] pdata_tmp;
wire  rdata_latch;
wire  ldata_latch;
reg  [7:0] counter256;

// architecture S_P
//-----------------------------------------------------------------
always@(posedge MCLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    pdata_tmp <= {16{1'b0}};
  end
  else  begin
    if ((BCLK == 1'b1)  )  begin
      pdata_tmp <= {pdata_tmp[14:0] ,SDATA};
    end
  end
end

//-----------------------------------------------------------------
always@(posedge MCLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    LDATA <= {0{1'b0}};
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
    RDATA <= {16{1'b0}};
  end
  else  begin
    if ((rdata_latch == 1'b1)  )  begin
      RDATA <= pdata_tmp;
    end
  end
end

//-----------------------------------------------------------------
always@(posedge MCLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    counter256 <= {8{1'b0}};
  end
  else  begin
    if ((LRCLK == 1'b1)  )  begin
      counter256 <= {8{1'b0}};
    end
    else if ((BCLK == 1'b1)  )  begin
      counter256 <= counter256 + 1;
    end
  end
end

//-----------------------------------------------------------------
assign ldata_latch = (counter256 == 16)? 1'b1 : 1'b0;
assign rdata_latch = (counter256 == (125 + 16))? 1'b1 : 1'b0;
// architecture S_P

endmodule
