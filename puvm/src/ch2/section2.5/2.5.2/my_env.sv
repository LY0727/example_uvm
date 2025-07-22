`ifndef MY_ENV__SV
`define MY_ENV__SV

class my_env extends uvm_env;
      // 声明组件，    创建在 build_phase 中
   my_agent   i_agt;
   my_agent   o_agt;
   my_model   mdl;
   my_scoreboard scb;

   uvm_tlm_analysis_fifo #(my_transaction) agt_scb_fifo;
   uvm_tlm_analysis_fifo #(my_transaction) agt_mdl_fifo;
   uvm_tlm_analysis_fifo #(my_transaction) mdl_scb_fifo;
   
   function new(string name = "my_env", uvm_component parent);
      super.new(name, parent);
   endfunction

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
         // 创建agent
      i_agt = my_agent::type_id::create("i_agt", this);
      o_agt = my_agent::type_id::create("o_agt", this);
         // 指定属性
      i_agt.is_active = UVM_ACTIVE;
      o_agt.is_active = UVM_PASSIVE;
         // 创建model和scoreboard;  后面也考虑直接把mdl放在scb内部
      mdl = my_model::type_id::create("mdl", this);
      scb = my_scoreboard::type_id::create("scb", this);
         // 创建分析 FIFO， fifo都在agent内部
      agt_scb_fifo = new("agt_scb_fifo", this);  // agent -> scb，主要是发出的输入激励，由moniter输出
      agt_mdl_fifo = new("agt_mdl_fifo", this);  // agent -> model，主要是发出的输入激励，这里是不是也通过moniter输出，而不通过driver输出？
      mdl_scb_fifo = new("mdl_scb_fifo", this);  // model -> scb， reference model根据输入stumulus 生成的 输出信息

   endfunction

   extern virtual function void connect_phase(uvm_phase phase);
      // 注册宏
   `uvm_component_utils(my_env)
endclass

function void my_env::connect_phase(uvm_phase phase);
   super.connect_phase(phase);

      // ap 指 analysis port, 
   i_agt.ap.connect(agt_mdl_fifo.analysis_export);     // agent -> analysis_fifo ->  model, agent发出的输入激励，所以ap直接发给fifo就行，fifo容量动态分配
   mdl.port.connect(agt_mdl_fifo.blocking_get_export); // agent -> analysis_fifo ->  model, mdl从fifo中获取输入激励，（获取->处理->再获取）blocking_get_export是一个阻塞获取端口 
      // exp_port 指 expected port, act_port 指 actual port;  只是命名的不同，本质都是 blocking_get_export 
      // 期望值，来自 model
      // 实际值，来自 o_agent->monitor
   mdl.ap.connect(mdl_scb_fifo.analysis_export);       // model -> analysis_fifo -> scb, model发出的输出信息，ap直接发给fifo就行，
   scb.exp_port.connect(mdl_scb_fifo.blocking_get_export); // model -> analysis_fifo -> scb, scb从fifo中获取输出信息，blocking_get_export是一个阻塞获取端口

   o_agt.ap.connect(agt_scb_fifo.analysis_export);          // agent -> analysis_fifo -> scb, agent发出的输入激励，所以ap直接发给fifo就行，fifo容量动态分配
   scb.act_port.connect(agt_scb_fifo.blocking_get_export);  // agent -> analysis_fifo -> scb, scb从fifo中获取输出信息，blocking_get_export是一个阻塞获取端口
endfunction

`endif
