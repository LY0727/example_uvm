`ifndef MY_SEQUENCER__SV
`define MY_SEQUENCER__SV
// sequencer 如果没有从多个sequence进行挑选的操作的话，其实这个类就基本没有内容。
// 连接也是在上层组件中写的。
class my_sequencer extends uvm_sequencer #(my_transaction);
   
   function new(string name, uvm_component parent);
      super.new(name, parent);
   endfunction 
   
   `uvm_component_utils(my_sequencer)
endclass

`endif
