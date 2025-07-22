`ifndef MY_TRANSACTION__SV
`define MY_TRANSACTION__SV

class my_transaction extends uvm_sequence_item;

   rand bit[47:0] dmac;
   rand bit[47:0] smac;
   rand bit[15:0] ether_type;
   rand byte      pload[];    // 未分配空间的动态数组，适合后续分配空间； 实际使用前必须使用 new() 分配空间
   rand bit[31:0] crc;

   constraint pload_cons{
      pload.size >= 46;
      pload.size <= 1500;
   }

   function bit[31:0] calc_crc();
      return 32'h0;
   endfunction
      // post_randomize() 是 SystemVerilog 的回调函数，每次对象随机化后自动调用。用于在随机化后根据其它字段计算并赋值 crc 字段。
      // 这里我们并没有对 calc_crc实现 具体的算法计算，只是返回0占位。
   function void post_randomize();
      crc = calc_crc;
   endfunction
      //  `uvm_object_utils 是 UVM 中的宏，用于注册对象以便 UVM 能够识别和处理它。
      //  `uvm_field_int 和 `uvm_field_array_int 是 UVM 中的宏，用于指定对象的字段及其属性。
      //  UVM_ALL_ON 表示所有字段都将被包含在 UVM 的打印、比较和记录中。
   `uvm_object_utils_begin(my_transaction)
      `uvm_field_int(dmac, UVM_ALL_ON)
      `uvm_field_int(smac, UVM_ALL_ON)
      `uvm_field_int(ether_type, UVM_ALL_ON)
      `uvm_field_array_int(pload, UVM_ALL_ON)
      `uvm_field_int(crc, UVM_ALL_ON)
   `uvm_object_utils_end

   function new(string name = "my_transaction");
      super.new();
   endfunction

endclass
`endif
