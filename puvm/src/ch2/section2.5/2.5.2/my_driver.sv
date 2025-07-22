`ifndef MY_DRIVER__SV
`define MY_DRIVER__SV
class my_driver extends uvm_driver#(my_transaction);

   virtual my_if vif;

   `uvm_component_utils(my_driver)
   function new(string name = "my_driver", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db#(virtual my_if)::get(this, "", "vif", vif))
         `uvm_fatal("my_driver", "virtual interface must be set for vif!!!")
   endfunction

   extern task main_phase(uvm_phase phase);
   extern task drive_one_pkt(my_transaction tr);
endclass

task my_driver::main_phase(uvm_phase phase);
   vif.data <= 8'b0;  // data_pkg 设置了初始值
   vif.valid <= 1'b0;
   while(!vif.rst_n)  // 异步复位
      @(posedge vif.clk);
   while(1) begin
      seq_item_port.get_next_item(req);   // 从 sequencer 获取一个item,  阻塞式

      drive_one_pkt(req);  // item的发送处理逻辑。  协议接口时序其实就在这里实现。

      seq_item_port.item_done();    // 通知 sequencer 该item已经处理完毕
   end
endtask
   // 这个没有rdy信号，比较简单
task my_driver::drive_one_pkt(my_transaction tr);
   byte unsigned     data_q[];
   int  data_size;

   data_size = tr.pack_bytes(data_q) / 8; 
   `uvm_info("my_driver", "begin to drive one pkt", UVM_LOW);
   repeat(3) @(posedge vif.clk); // 等待3个时钟周期， 
   for ( int i = 0; i < data_size; i++ ) begin   //每个周期发送一个字节的数据
      @(posedge vif.clk);
      vif.valid <= 1'b1;
      vif.data <= data_q[i]; 
   end

   @(posedge vif.clk);  // 最后一个字节发送完毕后， 下一个周期将 valid 置为 0
   vif.valid <= 1'b0;
   `uvm_info("my_driver", "end drive one pkt", UVM_LOW);
endtask


`endif
