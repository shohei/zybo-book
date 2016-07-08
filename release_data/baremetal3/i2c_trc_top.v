`timescale 1ns / 1ps
//******************************************************************************
// File Name            : i2c_trc_top.v
//------------------------------------------------------------------------------
// Function             : i2c master if top
//                        
//------------------------------------------------------------------------------
// Designer             : yokomizo 
//------------------------------------------------------------------------------
// History
// -.-- 2015/10/02
//******************************************************************************
module i2c_trc_top ( 
  clk, rst,
  s_scl,
  s_sda,
  //s_sda_i,s_sda_o,   
  m_scl,m_sda,
  led
);
  input clk;
  input rst;  
  input s_scl;
  inout s_sda;
  //input s_sda_i;
  //output s_sda_o;
  output m_scl;
  inout m_sda;
  output led;
  
  wire s_scl_o;
  wire m_scl_o;
  wire s_sda_o;
  wire m_sda_o;
  wire rstb;
  reg [23:0]led_cnt;
  
  assign rstb = ~rst;
  
        i2c_trc i2c_trc (
                .clk(clk), 
                .rstb(rstb), 
                .s_scl(s_scl), 
                .s_sda_i(s_sda),  
                //.s_sda_i(s_sda_i),  
                .s_sda_o(s_sda_o), 
                .m_scl(m_scl), 
                .m_sda_i(m_sda),  
                .m_sda_o(m_sda_o)
        );
		
		
  assign s_sda = (s_sda_o==1'b0)?1'b0:1'bz;
		
  assign m_sda = (m_sda_o==1'b0)?1'b0:1'bz;
		
  always @ (posedge clk or negedge rstb )
    if (rstb==1'b0) begin 
       led_cnt <= 24'd0;
    end
    else begin
           led_cnt <= led_cnt + 24'd1;
    end
    
  assign led = led_cnt[23] ^ s_sda_o;
  
endmodule






