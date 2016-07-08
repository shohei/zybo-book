`timescale 1ns / 1ps
//******************************************************************************
// File Name            : i2c_trc.v
//------------------------------------------------------------------------------
// Function             : i2c master if
//                        
//------------------------------------------------------------------------------
// Designer             : yokomizo 
//------------------------------------------------------------------------------
// History
// -.-- 2015/10/02
//******************************************************************************
module i2c_trc ( 
  clk, rstb,
  s_scl,s_sda_i,s_sda_o,   
  m_scl,m_sda_i,m_sda_o
);
  input clk;
  input rstb;  
  input s_scl;
  output s_sda_o;
  input  s_sda_i;
  output m_scl;
  output m_sda_o;
  input  m_sda_i;
  
   
  reg m_sda_o;
  reg s_sda_o;
  
  reg s_scl_d1;  
  reg s_scl_d2;
  wire s_scl_f;
  wire s_scl_r;
  reg s_sda_d1;  
  reg s_sda_d2;
  wire s_sda_f;
  wire s_sda_r;
  reg [3:0]data_cnt;
  reg [7:0]rd_adr;
  
  reg mr_mode_p;  
  reg mr_mode;  
  reg mode_set;  
   
always @ (posedge clk or negedge rstb )
  if (rstb==1'b0) begin 
     s_scl_d1 <= 1'b1;
     s_scl_d2 <= 1'b1;
  end
  else begin
     s_scl_d1 <= s_scl;
     s_scl_d2 <= s_scl_d1;
  end

  
assign m_scl = s_scl_d1;

assign s_scl_f = ((s_scl_d2==1'b1)&&(s_scl_d1==1'b0))?1'b1:1'b0;
assign s_scl_r = ((s_scl_d2==1'b0)&&(s_scl_d1==1'b1))?1'b1:1'b0;

always @ (posedge clk or negedge rstb )
  if (rstb==1'b0) begin 
     s_sda_d1 <= 1'b1;
     s_sda_d2 <= 1'b1;
  end
  else begin
     s_sda_d1 <= s_sda_i;
     s_sda_d2 <= s_sda_d1;
  end
  
assign s_sda_f = ((s_sda_d2==1'b1)&&(s_sda_d1==1'b0))?1'b1:1'b0;
assign s_sda_r = ((s_sda_d2==1'b0)&&(s_sda_d1==1'b1))?1'b1:1'b0;

always @ (posedge clk or negedge rstb )
  if (rstb==1'b0)  
    data_cnt <= 8'h0;
  else
    if (data_cnt==4'h0)
	  if((s_scl_f==1'b1)&&(s_sda_i==1'b0))
        data_cnt <= 8'h1;
	  else   
       data_cnt <= 8'h0;
	else if(data_cnt==4'h9)
	  if(s_scl_f==1'b1)
        data_cnt <= 8'h1;
	  else
	    data_cnt <= data_cnt;	 
    else if((s_scl==1'b1)&&(s_sda_f==1'b1))	
      data_cnt <= 8'h0;	
	else
	  if(s_scl_f==1'b1)
        data_cnt <= data_cnt + 8'h1;
	  else
	    data_cnt <= data_cnt;
 
always @ (posedge clk or negedge rstb )
  if (rstb==1'b0)  
    rd_adr <= 8'hff;
  else
    if (mr_mode_p==1'b1)
	  if((data_cnt==4'h9)&&(s_scl_f==1'b1))
       rd_adr <= rd_adr + 8'h1;
	  else
       rd_adr <= rd_adr ;
	else
      rd_adr <= 8'hff;
	       
always @ (posedge clk or negedge rstb )
  if (rstb==1'b0)  
    mode_set <= 1'b0;
  else    
	if ((data_cnt==4'h8)&&(s_scl_r==1'b1))
      mode_set <= 1'b1;
    //else if ((data_cnt==4'h0)&&(s_scl==1'b1)&&(s_sda_i==1'b1))
    else if ((s_scl==1'b1)&&(s_sda_f==1'b1))	
      mode_set <= 1'b0;
	  
  
always @ (posedge clk or negedge rstb )
  if (rstb==1'b0)  
    mr_mode_p <= 1'b0;
  else
    //if((data_cnt==4'h0)&&(s_scl==1'b1)&&(s_sda_i==1'b1))	
    if ((s_scl==1'b1)&&(s_sda_f==1'b1))	  
      mr_mode_p <= 1'b0; //write
	else
	  if ((mode_set==1'b0)&&(data_cnt==4'h8)&&(s_scl_r==1'b1))
	    mr_mode_p <=s_sda_i;
	  else
	    mr_mode_p <= mr_mode_p;
		

always @ (posedge clk or negedge rstb )
  if (rstb==1'b0)  
    mr_mode <= 1'b0;
  else
    //if((data_cnt==4'h0)&&(s_scl==1'b1)&&(s_sda_i==1'b1))	
    if ((s_scl==1'b1)&&(s_sda_f==1'b1))		
      mr_mode <= 1'b0;  
    else if((data_cnt==4'h9)&&(s_scl_f==1'b1)) 
      mr_mode <= mr_mode_p;
	else 
      mr_mode <= mr_mode;	
	
always @ (posedge clk or negedge rstb )
  if (rstb==1'b0)  
    m_sda_o <= 1'b1;
  else
    if (mr_mode ==1'b0) //write mode
	  if (data_cnt==4'h9) //ack
        m_sda_o <= 1'b1;
	  else
        m_sda_o <= s_sda_i;
    else                // read mode
	  if (data_cnt==4'h9)
        m_sda_o <= s_sda_i;
	  else
        m_sda_o <= 1'b1;
	    
always @ (posedge clk or negedge rstb )
  if (rstb==1'b0)  
    m_sda_o <= 1'b1;
  else
    if (mr_mode ==1'b0) //write mode
	  if (data_cnt==4'h9) //ack
        m_sda_o <= 1'b1;
	  else
        m_sda_o <= s_sda_i;
    else                // read mode
	  if (data_cnt==4'h9)
        m_sda_o <= s_sda_i;
	  else
        m_sda_o <= 1'b1;
	    
always @ (posedge clk or negedge rstb )
  if (rstb==1'b0)  
    s_sda_o <= 1'b1;
  else
    if (mr_mode ==1'b0) //write mode
	  if (data_cnt==4'h9) //ack
        //s_sda_o <= m_sda_i;
        s_sda_o <= 1'b0;
	  else
        s_sda_o <= 1'b1;
    else                // read mode
	  if (data_cnt==4'h9)
        s_sda_o <=  1'b1;
	  else
	    if(rd_adr==8'h20)
		  if(data_cnt==4'h1)
            s_sda_o <= 1'b1;
          else			
            s_sda_o <= 1'b0;
		else
          s_sda_o <=  m_sda_i;
                       
endmodule






