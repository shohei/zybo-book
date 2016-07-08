`timescale 1ns / 1ps

module pl_led(
    input clk,
    input reset,
    output [3:0] led
    );
    parameter p_count_1s = 27'd124999999;
    
    reg [26:0] count;
    always@(posedge clk)
    if(reset==1'b1)
      count <= 27'h0000000;
    else
     if (count == p_count_1s)
       count <= 27'd0;
     else
       count <= count + 27'd1;
    
    assign led = count[26:23];
    
endmodule
