//-----------------------------
// Initial DF/F to latch serial data
// by Toshio Iwata at digitalfilter.com 2015/06/02

module initial_latch(
  RST_N,
  MCLK,
  ADATA,
  ADATAO,
  ABCLK,
  ABCLKO,
  ALRCLK,
  DLRCLK,
  ALRCLKO,
  DLRCLKO_L,
  DLRCLKO_R
);

input RST_N;
input MCLK;
input ADATA;
output ADATAO;
input ABCLK;
output ABCLKO;
input ALRCLK;
input DLRCLK;
output ALRCLKO;
output DLRCLKO_L;
output DLRCLKO_R;

wire   RST_N;
wire   MCLK;
wire   ADATA;
wire   ADATAO;
wire   ABCLK;
wire   ABCLKO;
wire   ALRCLK;
wire   DLRCLK;
wire   ALRCLKO;
wire   DLRCLKO_L;
wire   DLRCLKO_R;


reg   ADATA_delay0;
reg   ADATA_delay1;
reg   ALRCLK_delay0;
reg   ALRCLK_delay1;
reg   DLRCLK_delay0;
reg   DLRCLK_delay1;
reg   ABCLK_delay0;
reg   ABCLK_delay1;
wire [1:0] COEFFSEL_delay0;
wire [1:0] COEFFSEL_delay1;

//-----------------------------------------------------------------
always@(posedge MCLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    ADATA_delay1 <= 1'b0;
    ADATA_delay0 <= 1'b0;
  end
  else  begin
    ADATA_delay1 <= ADATA_delay0;
    ADATA_delay0 <= ADATA;
  end
end

//-----------------------------------------------------------------
always@(posedge MCLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    ALRCLK_delay1 <= 1'b0;
    ALRCLK_delay0 <= 1'b0;
  end
  else  begin
    ALRCLK_delay1 <= ALRCLK_delay0;
    ALRCLK_delay0 <= ALRCLK;
  end
end

//-----------------------------------------------------------------
always@(posedge MCLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    DLRCLK_delay1 <= 1'b0;
    DLRCLK_delay0 <= 1'b0;
  end
  else  begin
    DLRCLK_delay1 <= DLRCLK_delay0;
    DLRCLK_delay0 <= DLRCLK;
  end
end

//-----------------------------------------------------------------
always@(posedge MCLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    ABCLK_delay1 <= 1'b0;
    ABCLK_delay0 <= 1'b0;
  end
  else  begin
    ABCLK_delay1 <= ABCLK_delay0;
    ABCLK_delay0 <= ABCLK;
  end
end

//-----------------------------------------------------------------
assign ADATAO = ADATA_delay0;
assign ALRCLKO = ALRCLK_delay0 &  ~ALRCLK_delay1;
assign ABCLKO = ABCLK_delay0 &  ~ABCLK_delay1;
assign DLRCLKO_L = DLRCLK_delay0 &  ~DLRCLK_delay1;
assign DLRCLKO_R =  ~DLRCLK_delay0 & DLRCLK_delay1;

endmodule
