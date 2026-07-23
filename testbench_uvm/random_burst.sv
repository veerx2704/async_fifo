`include "define.sv"
`ifndef RANDOM_BURST__SV
`define RANDOM_BURST__SV

class random_burst_sequence extends uvm_sequence;
    
  `uvm_object_utils(random_burst_sequence)
  `uvm_declare_p_sequencer(virtual_sequencer)
    
   function  new(string name= "virtual_sequencer");
      super.new(name);
   endfunction 
   
   extern virtual task body();
//   extern virtual task pre_body();
//   extern virtual task post_body();

endclass

task random_burst_sequence::body();
   write_fifo_seq   w_seq;
   read_fifo_seq    r_seq;
      repeat (16) begin
        `uvm_do_on(w_seq,p_sequencer.w_seqr)
      end
	  //#1000;
      fork
      repeat (3) begin
         `uvm_do_on(w_seq,p_sequencer.w_seqr)
      end
      repeat (19) begin
        `uvm_do_on(r_seq,p_sequencer.r_seqr)
      end
      join
	  #`RPERIOD;
  	  `uvm_info("random_burst", "body finished", UVM_MEDIUM)
endtask

//task random_burst_sequence::pre_body();
//    if(starting_phase != null) begin 
//        starting_phase.raise_objection(this);
//    end
//endtask

//task random_burst_sequence::post_body();
//  `uvm_info("random_burst", "Entering post_body", UVM_MEDIUM)
//    if(starting_phase != null) begin 
//      `uvm_info("random_burst", "starting_pase is drop", UVM_MEDIUM)
//        starting_phase.drop_objection(this);
//    end
//endtask


class random_burst extends base_test;

   function new(string name = "random_burst", uvm_component parent = null);
      super.new(name,parent);
   endfunction 
   extern virtual function void build_phase(uvm_phase phase); 
     extern virtual task main_phase(uvm_phase phase);
   `uvm_component_utils(random_burst)
endclass


function void random_burst::build_phase(uvm_phase phase);
   super.build_phase(phase);

   uvm_config_db#(uvm_object_wrapper)::set(this, 
                                           "env.v_seqr.main_phase", 
                                           "default_sequence", 
                                            random_burst_sequence::type_id::get());
endfunction

task random_burst::main_phase(uvm_phase phase);
       random_burst_sequence seq;
       super.main_phase(phase);
  		seq = random_burst_sequence::type_id::create("seq",this);
  		`uvm_info("SEQ", "Raising Objection",UVM_LOW)
  		phase.raise_objection(this);
  		seq.start(env.v_seqr);
  		phase.drop_objection(this);
  		`uvm_info("SEQ","Dropped the objection",UVM_LOW)
  		uvm_top.print_topology();
endtask

`endif
