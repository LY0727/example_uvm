`ifndef MY_MONITOR__SV
`define MY_MONITOR__SV
class my_monitor extends uvm_monitor;

   virtual my_if vif;

   uvm_analysis_port #(my_transaction)  ap;
   
   `uvm_component_utils(my_monitor)
   function new(string name = "my_monitor", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db#(virtual my_if)::get(this, "", "vif", vif))
         `uvm_fatal("my_monitor", "virtual interface must be set for vif!!!")
      ap = new("ap", this);
   endfunction

   extern task main_phase(uvm_phase phase);
   extern task collect_one_pkt(my_transaction tr);
endclass

task my_monitor::main_phase(uvm_phase phase);
   my_transaction tr;
   while(1) begin
      tr = new("tr");  

      collect_one_pkt(tr);  // item收集函数

      ap.write(tr);   // analysis port write, 经过fifo中转，会送到 scb、 model
   end
endtask

task my_monitor::collect_one_pkt(my_transaction tr);
   byte unsigned data_q[$];      // 动态数组定义， 适合边采集边扩展，  不需要提前知道数组长度
   byte unsigned data_array[];   // 未分配空间的动态数组， 适合后续分配空间； 实际使用前必须使用 new() 分配空间
   logic [7:0] data;
   logic valid = 0;
   int data_size;
   
   while(1) begin
      @(posedge vif.clk);
      if(vif.valid) break;
   end
   
   `uvm_info("my_monitor", "begin to collect one pkt", UVM_LOW);
      // 条件应该为传输协议的传输成功标志，这里就是valid,  一般会是handshake信号
   while(vif.valid) begin 
      data_q.push_back(vif.data);      // push_back()是一个动态数组的函数，sv的内建方法，  功能为在数组末尾添加一个元素。 
      @(posedge vif.clk);
   end
      // .size() 返回数组的元素个数,也是sv的机制
   data_size  = data_q.size();   
      // 分配指定长度的动态数组
   data_array = new[data_size];
   for ( int i = 0; i < data_size; i++ ) begin
      data_array[i] = data_q[i]; 
   end
      // 分配负载字段空间，减去头部和 CRC
   tr.pload = new[data_size - 18]; //da sa, e_type, crc
   data_size = tr.unpack_bytes(data_array) / 8;     // uvm定义的解包方案，将字节流转换为事务字段。  要使用这个应该在 item定义时对字段做了 宏注册
   `uvm_info("my_monitor", "end collect one pkt", UVM_LOW);
endtask


`endif
