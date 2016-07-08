`timescale 1 ns / 1ps
//2015.11.07 k.yokomizo
module dec_sync (
  input  wire       clk,
  input  wire       rst,
  input  wire [9:0] data_in,
  output  reg       vsync,
  output  reg       hsync,
  output  reg bitslip,
  output  reg [7:0] data_out,
  output  reg doe
);

  parameter CTRLTOKEN0 = 10'b1101010100; //VSYNC,HSYNC
  parameter CTRLTOKEN1 = 10'b0010101011; //VSYNC
  parameter CTRLTOKEN2 = 10'b0101010100; //HSYNC
  parameter CTRLTOKEN3 = 10'b1010101011; //

  parameter p_idle = 0;
  parameter p_search = 1;
  parameter p_slip = 2;
  parameter p_hit = 3;
  parameter p_sync = 4;
  
  parameter p_search_cnt_max = 2047;
  parameter p_hit_cnt_max = 8;
  parameter p_sync_cnt_max = 4095;
  
  reg [9:0] da_10b;
  reg [3:0] state;
  reg ctrl_hit;
  reg [11:0] search_cnt;
  reg [3:0] hit_cnt;
  reg [11:0] sync_cnt;
  
  
  always @ (posedge clk) begin
    if(rst==1'b1)
      ctrl_hit <= 1'b0;
	else
	  if ((data_in==CTRLTOKEN0)||
	      (data_in==CTRLTOKEN1)||
		  (data_in==CTRLTOKEN2)||
		  (data_in==CTRLTOKEN3))
        ctrl_hit <= 1'b1;
	  else
        ctrl_hit <= 1'b0;   
  end

  
  always @ (posedge clk) begin
    if(rst==1'b1)
      search_cnt <= 12'd0;
	else
	  if(state==p_search)
	    if(search_cnt==p_search_cnt_max )
          search_cnt <= 12'd0;
		else
          search_cnt <=  search_cnt + 12'd1;
	  else
        search_cnt <= 12'd0;
  end
  
  
  always @ (posedge clk) begin
    if(rst==1'b1)
      sync_cnt <= 12'd0;
	else
	  if(state==p_sync)
	    if((ctrl_hit==1'b1)||(sync_cnt==p_sync_cnt_max ))
          sync_cnt <= 12'd0;
		else
          sync_cnt <=  sync_cnt + 12'd1;
	  else
	    sync_cnt <= 12'd0;
  end
  
  always @ (posedge clk) begin
    if(rst==1'b1)
      hit_cnt <= 4'd0;
	else
	  if(state==p_hit)
	    if(hit_cnt==p_hit_cnt_max )
          hit_cnt <= 4'd0;
		else
          hit_cnt <=  hit_cnt + 4'd1;
	  else
        hit_cnt <= 4'd0;
  end
  
  always @ (posedge clk) begin
    if(rst==1'b1)
      state <= p_idle;
	else
	  case(state)
	    p_idle:
		  state <= p_search;
		p_search:
		  //コントロールコード検出
		  if(ctrl_hit==1'b1)
		    state <= p_hit;
		  //一定期間コントロールコードを未検出
		  else if(search_cnt==p_search_cnt_max )
		    state <= p_slip;
		  else
		    state <= p_search;
		p_slip:		  
		  state <= p_search;
		p_hit:
		  //コントロールコード未検出
          if(ctrl_hit==1'b0)
		    state <= p_search;
		  //コントロールコードを連続検出
		  else if(hit_cnt==p_hit_cnt_max )
		    state <= p_sync;
          else		   
		    state <= p_hit;  
		p_sync:
		  //一定期間コントロールコードを未検出
		  //sync_cntはコントロールコード検出で0に戻る
		  if(sync_cnt==p_sync_cnt_max )
		    state <= p_search;
		  else
		    state <= p_sync;
	    default:
         state <= p_idle;
	  endcase
  end


  always @ (posedge clk) begin
    if(state==p_slip)
      bitslip <= 1'b1;
	else
      bitslip <= 1'b0;
  end
  
  always @ (posedge clk) begin
   da_10b <= data_in;
  end
  
  always @ (posedge clk) begin
    if(state==p_sync)
	  //コントロールコードが一致したらVSYNC,HSYNCを判定
      if(da_10b==CTRLTOKEN0)
	    begin
	      hsync <= 1'b0;
	      vsync <= 1'b0;
        end	  
      else if(da_10b==CTRLTOKEN1)
	    begin
	      hsync <= 1'b1;
	      vsync <= 1'b0;
        end	  
      else if(da_10b==CTRLTOKEN2)
	    begin
	      hsync <= 1'b0;
	      vsync <= 1'b1;
        end	  
      else if(da_10b==CTRLTOKEN3)
	    begin
	      hsync <= 1'b1;
	      vsync <= 1'b1;
        end	  
      else 
	    begin
	      hsync <= 1'b1;
	      vsync <= 1'b1;
        end
    else	
	  begin
        hsync <= 1'b1;
	    vsync <= 1'b1;
      end	
  end

  always @ (posedge clk) begin
    if(state==p_sync)
      //コントロールコードはブランクエリア
      if(ctrl_hit==1'b1 )begin
	    doe <= 1'b0;
	    data_out <= 8'h00;
	  end
	  //コントロールコード以外は8b10b変換を実施
	  else begin
	    doe <= 1'b1;
        data_out[0] <= da_10b[0];
        data_out[1] <= (da_10b[8]) ? (da_10b[1] ^ da_10b[0]) : (da_10b[1] ~^ da_10b[0]);
        data_out[2] <= (da_10b[8]) ? (da_10b[2] ^ da_10b[1]) : (da_10b[2] ~^ da_10b[1]);
        data_out[3] <= (da_10b[8]) ? (da_10b[3] ^ da_10b[2]) : (da_10b[3] ~^ da_10b[2]);
        data_out[4] <= (da_10b[8]) ? (da_10b[4] ^ da_10b[3]) : (da_10b[4] ~^ da_10b[3]);
        data_out[5] <= (da_10b[8]) ? (da_10b[5] ^ da_10b[4]) : (da_10b[5] ~^ da_10b[4]);
        data_out[6] <= (da_10b[8]) ? (da_10b[6] ^ da_10b[5]) : (da_10b[6] ~^ da_10b[5]);
        data_out[7] <= (da_10b[8]) ? (da_10b[7] ^ da_10b[6]) : (da_10b[7] ~^ da_10b[6]);
	   end
	 else begin
	    doe <= 1'b0;
	    data_out <= 8'h00;
	  end
  end
endmodule
