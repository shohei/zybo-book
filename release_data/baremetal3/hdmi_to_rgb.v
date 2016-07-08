
`timescale 1 ns / 1ps
//2015.11.07 k.yokomizo
module hdmi_to_rgb (

  input rxclk,
  input [29:0] data_in,
  input  wire exrst,          // external reset input, e.g. reset button

  output wire hsync,          // hsync data
  output wire vsync,          // vsync data
  output wire de,             // data enable
  
  output wire [2:0] bitslip,

  output wire [7:0] red,      // pixel data out
  output wire [7:0] green,    // pixel data out
  output wire [7:0] blue    // pixel data out
  );

  wire [9:0] data_0;
  wire [9:0] data_1;
  wire [9:0] data_2;
  
    assign data_0 = {data_in[27],
	                  data_in[24],
	                  data_in[21],
	                  data_in[18],
	                  data_in[15],
	                  data_in[12],
	                  data_in[9],
	                  data_in[6],
	                  data_in[3],
	                  data_in[0]}	;
					  
    assign data_1 = {data_in[28],
	                  data_in[25],
	                  data_in[22],
	                  data_in[19],
	                  data_in[16],
	                  data_in[13],
	                  data_in[10],
	                  data_in[7],
	                  data_in[4],
	                  data_in[1]}	;
					  
    assign data_2 = {data_in[29],
	                  data_in[26],
	                  data_in[23],
	                  data_in[20],
	                  data_in[17],
	                  data_in[14],
	                  data_in[11],
	                  data_in[8],
	                  data_in[5],
	                  data_in[2]}	;
					  
  assign bitslip = {r_bitslip,g_bitslip,b_bitslip};
  
  dec_sync dec_sync_b(
   .clk(     rxclk),
   .rst(     exrst),
   .data_in( data_0),
   .vsync(   vsync),
   .hsync(   hsync),
   .bitslip( b_bitslip),
   .data_out(blue),
   .doe(     de)
  );
  
  dec_sync dec_sync_g(
   .clk(     rxclk),
   .rst(     exrst),
   .data_in( data_1),
   .vsync(   ),
   .hsync(   ),
   .bitslip( g_bitslip),
   .data_out(green),
   .doe(     )
  );
  
  dec_sync dec_sync_r(
   .clk(     rxclk),
   .rst(     exrst),
   .data_in( data_2),
   .vsync(   ),
   .hsync(   ),
   .bitslip( r_bitslip),
   .data_out(red),
   .doe(     )
  );
  
  
endmodule
