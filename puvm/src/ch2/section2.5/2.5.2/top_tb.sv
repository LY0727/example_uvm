`timescale 1ns/1ps
`include "uvm_macros.svh"

import uvm_pkg::*;
`include "my_if.sv"
`include "my_transaction.sv"
`include "my_sequencer.sv"
`include "my_driver.sv"
`include "my_monitor.sv"
`include "my_agent.sv"
`include "my_model.sv"
`include "my_scoreboard.sv"
`include "my_env.sv"
`include "base_test.sv"
`include "my_case0.sv"
`include "my_case1.sv"

module top_tb;

reg clk;
reg rst_n;
reg[7:0] rxd;
reg rx_dv;
wire[7:0] txd;
wire tx_en;

my_if input_if(clk, rst_n);
my_if output_if(clk, rst_n);

dut my_dut(.clk(clk),
           .rst_n(rst_n),
           .rxd(input_if.data),
           .rx_dv(input_if.valid),
           .txd(output_if.data),
           .tx_en(output_if.valid));
// clk 和 rst_n 信号直接顶层生成的；   如果需要做 这两个验证相关的验证，其实也应该设置一个agent来做处理
initial begin
   clk = 0;
   forever begin
      #100 clk = ~clk;
   end
end

initial begin
   rst_n = 1'b0;
   #1000;
   rst_n = 1'b1;
end
// 这个框架中定义了两个 mycase；  
// 每次运行启动函数时， 只会运行一个case；这个通过命令行参数  +UVM_TESTNAME=<test_name>  来指定实际运行哪一个 case；  这样通过脚本一次性运行所有的case；
// 这里的 test_name 就是 my_case0 或者 my_case1； 

initial begin
   run_test();
end

initial begin
   uvm_config_db#(virtual my_if)::set(null, "uvm_test_top.env.i_agt.drv", "vif", input_if);
   uvm_config_db#(virtual my_if)::set(null, "uvm_test_top.env.i_agt.mon", "vif", input_if);
   uvm_config_db#(virtual my_if)::set(null, "uvm_test_top.env.o_agt.mon", "vif", output_if);
end

endmodule
