`ifndef WRITE_FIFO_SEQ__SV
`define WRITE_FIFO_SEQ__SV

class write_fifo_seq extends uvm_sequence #(transaction);

function new(string name = "write_fifo_seq");
	super.new();
endfunction

extern virtual task body();
extern virtual task pre_body();
extern virtual task post_body();

`uvm_object_utils(write_fifo_seq);

endclass

task write_fifo_seq::body();
	transaction trans;
	`uvm_do(trans);
endtask

task write_fifo_seq::pre_body();
	if(starting_phase != null) begin
		starting_phase.raise_objection(this);
	end
endtask
task write_fifo_seq::post_body();
	if(starting_phase != null) begin
		starting_phase.drop_objection(this);
	end
endtask

`endif