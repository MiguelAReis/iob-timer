`timescale 1ns/1ps
`include "iob_lib.vh"
`include "interconnect.vh"
`include "iob_timer.vh"

module iob_timer 
  #(
    parameter ADDR_W = `TIMER_ADDR_W, //NODOC Address width
    parameter DATA_W = `DATA_W, //NODOC Data word width
    parameter WDATA_W = `TIMER_WDATA_W //NODOC Data word width on writes
    )
   (
`include "cpu_nat_s_if.v"
`include "gen_if.v"
    );

//BLOCK Register File & Configuration, control and status registers accessible by the sofware
`include "sw_reg.v"
`include "sw_reg_gen.v"

    //combined hard/soft reset 
   `SIGNAL(rst_int, 1)
   `COMB rst_int = rst | TIMER_RESET;

   always @* begin
   	rst_soft_en = 1'b0;
   	tmp_reg_en = 1'b0;
    rdata = 32'b0;
 	  case (address)
 	    `TIMER_RESET:     rst_soft_en = 1'b1;
 	    `TIMER_STOP:      tmp_reg_en = 1'b1;
 	    `TIMER_DATA_HIGH: rdata = tmp_reg[63:32];
 	    `TIMER_DATA_LOW:  rdata = tmp_reg[31:0];
 	    default:;
   	  endcase
   end 
     	
   //soft reset pulse
   always @(posedge clk, posedge rst)
     if(rst)
       rst_soft <= 1'b0;
     else if (rst_soft_en)
       rst_soft <= wdata[0];
     else
       rst_soft <= 1'b0;
   
   // cpu interface ready signal
   always @(posedge clk, posedge rst)
     if(rst)
       ready <= 1'b0;
     else 
       ready <= valid;
       
   assign rst_int = rst | rst_soft;

   
   
   //ready signal   
   `SIGNAL(ready_int, 1)
   `REG_AR(clk, rst, 0, ready_int, valid)

   `SIGNAL2OUT(ready, ready_int)

   //rdata signal
   `COMB begin
      TIMER_DATA_LOW = TIMER_VALUE[DATA_W-1:0];
      TIMER_DATA_HIGH = TIMER_VALUE[2*DATA_W-1:DATA_W];      
   end
      
endmodule

