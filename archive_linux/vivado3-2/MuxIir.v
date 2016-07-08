//------------------------------------------------
// IIR filter
// by Toshio Iwata at digitalfilter.com 2015/06/02

module MuxIir(
  RST_N,
  MCLK,
  FSCLK,
  A0, 
  A1, 
  A2, 
  B1, 
  B2, 
  XIN,
  YOUT
);

input RST_N;
input MCLK;
input FSCLK;
input[15:0] A0;
input[15:0] A1;
input[15:0] A2;
input[15:0] B1;
input[15:0] B2;
input[15:0] XIN;
output[15:0] YOUT;

wire   RST_N;
wire   MCLK;
wire   FSCLK;
wire  [15:0] XIN;
reg   [15:0] YOUT;


reg signed [15:0] X0;
reg signed [15:0] X1;
reg signed [15:0] X2;
reg signed [15:0] Y1;
reg signed [15:0] Y2;
wire signed [15:0] A0_sig;
wire signed [15:0] A1_sig;
wire signed [15:0] A2_sig;
wire signed [15:0] B1_sig;
wire signed [15:0] B2_sig;
wire signed [31:0] HnXn;
reg signed [19:0] HnXn_20b;
reg signed [15:0] XIN_sig;
reg signed [21:0] YOUT_sig;
wire signed [21:0] ADDOUT;
reg  [7:0] counter8b;
reg signed [15:0] MuxXn;
reg signed [15:0] MuxHn;
reg   fsclk_dly1;
reg   fsclk_dly2;
wire  counter8b_clr;

// MuxIir
assign A0_sig = {A0};
assign A1_sig = {A1};
assign A2_sig = {A2};
assign B1_sig = {B1};
assign B2_sig = {B2};

//-----------------------------------------------------------------
always@(posedge MCLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    fsclk_dly2 <= 1'b0;
    fsclk_dly1 <= 1'b0;
  end
  else  begin
    fsclk_dly2 <= fsclk_dly1;
    fsclk_dly1 <= FSCLK;
  end
end

//-----------------------------------------------------------------
assign counter8b_clr = (fsclk_dly2 == 1'b0 && fsclk_dly1 == 1'b1)? 1'b1 : 1'b0;
//-----------------------------------------------------------------
always@(posedge MCLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    counter8b <= {5{1'b0}};
  end
  else  begin
    if ((counter8b_clr == 1'b1)  )  begin
      counter8b <= {5{1'b0}};
    end
    else  begin
      counter8b <= counter8b + 1;
    end
  end
end

//-----------------------------------------------------------------
always@(X0 or X1 or X2 or Y1 or Y2 or counter8b)  begin
  if ((counter8b == 0)  )  begin
    MuxXn <= X0;
  end
  else if ((counter8b == 1)  )  begin
    MuxXn <= X1;
  end
  else if ((counter8b == 2)  )  begin
    MuxXn <= X2;
  end
  else if ((counter8b == 3)  )  begin
    MuxXn <= Y1;
  end
  else if ((counter8b == 4)  )  begin
    MuxXn <= Y2;
  end
  else  begin
    MuxXn <= {16{1'b0}};
  end
end

//-----------------------------------------------------------------
always@(A0_sig or A1_sig or A2_sig or B1_sig or B2_sig or counter8b)  begin
  if ((counter8b == 0)  )  begin
    MuxHn <= A0_sig;
  end
  else if ((counter8b == 1)  )  begin
    MuxHn <= A1_sig;
  end
  else if ((counter8b == 2)  )  begin
    MuxHn <= A2_sig;
  end
  else if ((counter8b == 3)  )  begin
    MuxHn <= B1_sig;
  end
  else if ((counter8b == 4)  )  begin
    MuxHn <= B2_sig;
  end
  else  begin
    MuxHn <= {16{1'b0}};
  end
end

//-----------------------------------------------------------------
assign HnXn = MuxXn * MuxHn;
//-----------------------------------------------------------------
always@(XIN)  begin
  XIN_sig[0]  <= XIN[0] ;
  XIN_sig[1]  <= XIN[1] ;
  XIN_sig[2]  <= XIN[2] ;
  XIN_sig[3]  <= XIN[3] ;
  XIN_sig[4]  <= XIN[4] ;
  XIN_sig[5]  <= XIN[5] ;
  XIN_sig[6]  <= XIN[6] ;
  XIN_sig[7]  <= XIN[7] ;
  XIN_sig[8]  <= XIN[8] ;
  XIN_sig[9]  <= XIN[9] ;
  XIN_sig[10]  <= XIN[10] ;
  XIN_sig[11]  <= XIN[11] ;
  XIN_sig[12]  <= XIN[12] ;
  XIN_sig[13]  <= XIN[13] ;
  XIN_sig[14]  <= XIN[14] ;
  XIN_sig[15]  <= XIN[15] ;
end

//--------------------------------------------------
always@(posedge FSCLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    X2 <= {16{1'b0}};
    X1 <= {16{1'b0}};
    X0 <= {16{1'b0}};
  end
  else  begin
    X2 <= X1;
    X1 <= X0;
    X0 <= XIN_sig;
  end
end

//--------------------------------------------------
always@(HnXn)  begin
  HnXn_20b[19:0]  <= HnXn[30:11] ;
end

//--------------------------------------------------
assign ADDOUT = HnXn_20b + YOUT_sig;
//--------------------------------------------------
always@(posedge MCLK or negedge RST_N)  begin : P1
    reg [21:0] tmpint;

  if ((RST_N == 1'b0)  )  begin
    YOUT_sig <= {22{1'b0}};
  end
  else  begin
    if ((counter8b_clr == 1'b1)  )  begin
      YOUT_sig <= {22{1'b0}};
    end
    else  begin
      YOUT_sig <= ADDOUT;
    end
  end
end

//-----------------------------------------------------------------
always@(posedge FSCLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    Y1 <= {16{1'b0}};
  end
  else  begin
    if ((YOUT_sig[21]  == 1'b0 && (YOUT_sig[20]  == 1'b1 || YOUT_sig[19]  == 1'b1 || YOUT_sig[18]  == 1'b1)  )  )  begin
      // overflow
      Y1 <= 16'b0111111111111111;
    end
    else if ((YOUT_sig[21]  == 1'b1 && (YOUT_sig[20]  == 1'b0 || YOUT_sig[19]  == 1'b0 || YOUT_sig[18]  == 1'b0)  )  )  begin
      // underflow
      Y1 <= 16'b1000000000000000;
    end
    else  begin
      Y1[15:0]  <= YOUT_sig[18:3] ;
    end
  end
end

//--------------------------------------------------
always@(posedge FSCLK or negedge RST_N)  begin
  if ((RST_N == 1'b0)  )  begin
    Y2 <= {16{1'b0}};
  end
  else  begin
    Y2 <= Y1;
  end
end

//--------------------------------------------------
always@(Y1)  begin
  YOUT[0]  <= Y1[0] ;
  YOUT[1]  <= Y1[1] ;
  YOUT[2]  <= Y1[2] ;
  YOUT[3]  <= Y1[3] ;
  YOUT[4]  <= Y1[4] ;
  YOUT[5]  <= Y1[5] ;
  YOUT[6]  <= Y1[6] ;
  YOUT[7]  <= Y1[7] ;
  YOUT[8]  <= Y1[8] ;
  YOUT[9]  <= Y1[9] ;
  YOUT[10]  <= Y1[10] ;
  YOUT[11]  <= Y1[11] ;
  YOUT[12]  <= Y1[12] ;
  YOUT[13]  <= Y1[13] ;
  YOUT[14]  <= Y1[14] ;
  YOUT[15]  <= Y1[15] ;
end

endmodule
