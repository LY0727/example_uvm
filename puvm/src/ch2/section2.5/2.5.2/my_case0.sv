`ifndef MY_CASE0__SV
`define MY_CASE0__SV
class case0_sequence extends uvm_sequence #(my_transaction);
   my_transaction m_trans;

   function  new(string name= "case0_sequence");
      super.new(name);
   endfunction 
      // uvm_sequence 的 body() 方法是一个虚拟任务，必须被实现。  sequnce 执行就是 body() 方法的执行。
   virtual task body();
      if(starting_phase != null) 
         starting_phase.raise_objection(this);   

/*
      // 发送10个事务，每次通过uvm_do() 宏 自动随机化item字段，然后发送到drv；
      // 随机化的约束条件 在 my_transaction 中定义。   那么sequence的不同体现为什么？  
      // 我之前的理解是 item 只定义激励的字段，sequence 定义激励的不同的  数量、约束条件  来实现不同的场景的输入模拟。
      // 查找了一下资料，应该是这么做：  
         1. item定义时， 定义字段， 和一些 基础约束条件， 这些约束条件是通用的，适用于所有的sequence；  比如data的数据范围一定在[0, 255]之间；
         2. sequence 定义时， 定义一些特定的约束条件，比如data的范围是[0, 100]， 这些约束条件是特定的，适用于特定的sequence； 
         3. sequence 还可以定义发送的数量， 比如发送10个事务， 发送100个事务等；
      // 这样就可以通过不同的sequence来实现不同的场景模拟。


      `uvm_do_with(m_trans, { m_trans.data > 50; })
      // 或
      m_trans.randomize() with { data > 50; }
*/
      repeat (10) begin     
         `uvm_do(m_trans)   
      end
      #100;



      if(starting_phase != null) 
         starting_phase.drop_objection(this);
   endtask

   `uvm_object_utils(case0_sequence)
endclass

   // uvm_test -> base_test -> my_case0 、my_case1 
   // 可以看到这里的方案时，不同的case 设置不同的 default_sequence
class my_case0 extends base_test;

   function new(string name = "my_case0", uvm_component parent = null);
      super.new(name,parent);
   endfunction 
   extern virtual function void build_phase(uvm_phase phase); 
   `uvm_component_utils(my_case0)
endclass

   // 在 build_phase 中设置 default_sequence 为 case0_sequence
function void my_case0::build_phase(uvm_phase phase);
   super.build_phase(phase);

   uvm_config_db#(uvm_object_wrapper)::set(this, 
                                           "env.i_agt.sqr.main_phase", 
                                           "default_sequence", 
                                           case0_sequence::type_id::get());
endfunction

`endif
