`include "define.sv"
`ifndef TRANSACTION__SV
`define TRANSACTION__SV

class transaction extends uvm_sequence_item;

rand bit [`DATA_SIZE-1:0] data;
`uvm_object_utils_begin(transaction)
`uvm_field_int(data,UVM_ALL_ON)
`uvm_object_utils_end

function new(string name = "transaction");
	super.new();
endfunction

endclass
`endif
