`ifndef VIRTUAL_SEQUENCER__SV
`define VIRTUAL_SEQUENCER__SV

class virtual_sequencer extends uvm_sequencer;

write_fifo_sequencer w_seqr;
read_fifo_sequencer r_seqr;

function new(string name = "virtual_sequencer", uvm_component parent);
	super.new(name, parent);
endfunction

`uvm_component_utils(virtual_sequencer)
endclass

`endif
