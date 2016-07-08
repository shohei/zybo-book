//-----------------------------
// Parallel-Serial Converter
// by Toshio Iwata at digitalfilter.com 2015/06/02

module P_S(
  RST_N,
  MCLK,
  LATCH_L,
  LATCH_R,
  BCLK,
  LDATA,
  RDATA,
  SDATA
);

input RST_N;
input MCLK;
input LATCH_L;
input LATCH_R;
input BCLK;
input[15:0] LDATA;
input[15:0] RDATA;
output SDATA;

wire   RST_N;
wire   MCLK;
wire   LATCH_L;
wire   LATCH_R;
wire   BCLK;
wire  [15:0] LDATA;
wire  [15:0] RDATA;
wire   SDATA;


reg  [15:0] rdata_tmp;
reg  [7:0] counter256;

// architecture P_S
//-----------------------------------------------------------------
always@(posedge MCLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    rdata_tmp <= {16{1'b0}};
  end
  else  begin
    if ((LATCH_L == 1'b1)  )  begin
      rdata_tmp <= LDATA;
    end
    else if ((LATCH_R == 1'b1)  )  begin
      rdata_tmp <= RDATA;
    end
    else if ((BCLK == 1'b1)  )  begin
      rdata_tmp <= {rdata_tmp[14:0] ,1'b0};
    end
  end
end

//-----------------------------------------------------------------
assign SDATA = rdata_tmp[15] ;

//-----------------------------------------------------------------
always@(posedge MCLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    counter256 <= {8{1'b0}};
  end
  else  begin
    if ((LATCH_R == 1'b1)  )  begin
      counter256 <= {8{1'b0}};
    end
    else if ((BCLK == 1'b1)  )  begin
      counter256 <= counter256 + 1;
    end
  end
end

// architecture P_S

endmodule
