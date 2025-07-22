`ifndef BASE_TEST__SV
`define BASE_TEST__SV

class base_test extends uvm_test;

   my_env         env;
   
   function new(string name = "base_test", uvm_component parent = null);
      super.new(name,parent);
   endfunction
   
   extern virtual function void build_phase(uvm_phase phase);
   extern virtual function void report_phase(uvm_phase phase);
      // 注册宏放在 class 定义时第一行和最后一行应该是没区别吧
   `uvm_component_utils(base_test)
endclass


function void base_test::build_phase(uvm_phase phase);
   super.build_phase(phase);
   env  =  my_env::type_id::create("env", this); 
endfunction

   // 之前没看，后面需要思考一下怎么做更详细的报告
function void base_test::report_phase(uvm_phase phase);
   uvm_report_server server;
   int err_num;
   super.report_phase(phase);

      // get_report_server() 是 UVM 提供的函数，用于获取当前测试环境的报告服务器实例。
      // 报告服务器用于收集和管理测试中的报告信息。
      // 通过这个实例，我们可以查询错误、警告等信息的数量，或者进行其他报告相关的操作。
   server = get_report_server();
   err_num = server.get_severity_count(UVM_ERROR);

   if (err_num != 0) begin
      $display("TEST CASE FAILED");
   end
   else begin
      $display("TEST CASE PASSED");
   end
endfunction

`endif
