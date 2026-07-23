`include "define.sv"
`ifndef LONG_TEST__SV
`define LONG_TEST__SV

class long_test_sequence extends uvm_sequence;
    
    `uvm_object_utils(long_test_sequence)
  `uvm_declare_p_sequencer(virtual_sequencer)
    
   function  new(string name= "long_test_sequence");
      super.new(name);
   endfunction 
   
   extern virtual task body();
//   extern virtual task pre_body();
//   extern virtual task post_body();

endclass

task long_test_sequence::body();
   write_fifo_seq w_seq;
   read_fifo_seq  r_seq;
  //write full
  repeat (`DEPTH) begin
    `uvm_do_on(w_seq,p_sequencer.w_seqr)
  end  
  //read empty
  repeat (`DEPTH) begin
    `uvm_do_on(r_seq,p_sequencer.r_seqr)
  end   
  #`RPERIOD;
  `uvm_info("long_test", "body finished", UVM_MEDIUM)
endtask

//task long_test_sequence::pre_body();
//    if(starting_phase != null) begin 
//        starting_phase.raise_objection(this);
//    end
//endtask

//task long_test_sequence::post_body();
//  `uvm_info("long_test", "Entering post_body", UVM_MEDIUM)
//    if(starting_phase != null) begin 
//      `uvm_info("long_test", "starting_pase is drop", UVM_MEDIUM)
//        starting_phase.drop_objection(this);
//    end
//endtask


class long_test extends base_test;

  function new(string name = "long_test", uvm_component parent = null);
      super.new(name,parent);
   endfunction 
   extern virtual function void build_phase(uvm_phase phase); 
   extern virtual task main_phase(uvm_phase phase); 
     `uvm_component_utils(long_test)
endclass


function void long_test::build_phase(uvm_phase phase);
   super.build_phase(phase);

   uvm_config_db#(uvm_object_wrapper)::set(this, 
                                           "env.v_seqr.main_phase", 
                                           "default_sequence", 
                                           long_test_sequence::type_id::get());
endfunction
task long_test::main_phase(uvm_phase phase);
       long_test_sequence seq;
       super.main_phase(phase);
  		seq = long_test_sequence::type_id::create("seq",this);
  		`uvm_info("SEQ", "Raising Objection",UVM_LOW)
  		phase.raise_objection(this);
  		seq.start(env.v_seqr);
  		phase.drop_objection(this);
  		`uvm_info("SEQ","Dropped the objection",UVM_LOW)
  		uvm_top.print_topology();
endtask
`endif
