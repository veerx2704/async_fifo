`include "define.sv"
`ifndef PARALLEL_OR_EXCLUSIVE__SV
`define PARALLEL_OR_EXCLUSIVE__SV
class parallel_or_exclusive_sequence extends uvm_sequence;
    
    `uvm_object_utils(parallel_or_exclusive_sequence)
    `uvm_declare_p_sequencer(virtual_sequencer)
    
   function  new(string name= "parallel_or_exclusive_sequence");
      super.new(name);
   endfunction 
   
   extern virtual task body();
//   extern virtual task pre_body();
//   extern virtual task post_body();
   extern virtual task writer();
   extern virtual task reader();

endclass

task parallel_or_exclusive_sequence::body();
  `uvm_info("SEQ","Sequence starts",UVM_NONE);
	fork
		writer();
		reader();
	join
  `uvm_info("SEQ","Sequence finishes",UVM_NONE);
endtask

task parallel_or_exclusive_sequence::writer();
	write_fifo_seq w_seq;
  repeat (`DEPTH) begin
	`uvm_do_on(w_seq,p_sequencer.w_seqr)
    	`uvm_info("parallel_or_exclusive", "Sent done", UVM_MEDIUM)
    	end
endtask

task parallel_or_exclusive_sequence::reader();
	read_fifo_seq r_seq;
  repeat (`DEPTH) begin
	`uvm_do_on(r_seq,p_sequencer.r_seqr)
	`uvm_info("my_parallel_or_exclusive", "Get done", UVM_MEDIUM)
	end
	#`RPERIOD;
  	`uvm_info("parallel_or_exclusive", "body finished", UVM_MEDIUM)
endtask

//task parallel_or_exclusive_sequence::pre_body();
//    if(starting_phase != null) begin 
//    	`uvm_info("SEQ", "raising objection", UVM_NONE)
//        starting_phase.raise_objection(this);
//    end
//    else
//    	`uvm_info("SEQ","starting phase is NULL",UVM_NONE)
//endtask

//task parallel_or_exclusive_sequence::post_body();
//  `uvm_info("parallel_or_exclusive", "Entering post_body", UVM_MEDIUM)
//    if(starting_phase != null) begin 
//      `uvm_info("parallel_or_exclusive", "starting_phase is dropped", UVM_MEDIUM)
//        starting_phase.drop_objection(this);
//    end
//endtask



class parallel_or_exclusive extends base_test;

   function new(string name = "parallel_or_exclusive", uvm_component parent = null);
      super.new(name,parent);
   endfunction 
   extern virtual function void build_phase(uvm_phase phase);
   extern task main_phase(uvm_phase phase); 
   `uvm_component_utils(parallel_or_exclusive)
endclass


function void parallel_or_exclusive::build_phase(uvm_phase phase);
   super.build_phase(phase);
   
   uvm_config_db#(uvm_object_wrapper)::set(this, 
                                           "env.v_seqr.main_phase", 
                                           "default_sequence", 
                                           parallel_or_exclusive_sequence::type_id::get());
endfunction
task parallel_or_exclusive::main_phase(uvm_phase phase);
  parallel_or_exclusive_sequence seq;
  super.main_phase(phase);
  seq = parallel_or_exclusive_sequence::type_id::create("seq",this);
  `uvm_info("SEQ", "Raising Objection",UVM_LOW)
  phase.raise_objection(this);
  seq.start(env.v_seqr);
  phase.drop_objection(this);
  `uvm_info("SEQ","Dropped the objection",UVM_LOW)
  uvm_top.print_topology();
endtask
`endif