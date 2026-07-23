`ifndef REFERENCE_MODEL__SV
`define REFERENCE_MODEL__SV

class reference_model extends uvm_component;
uvm_blocking_get_port #(transaction) port;
uvm_analysis_port #(transaction) ap;

extern function new(string name, uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern virtual task main_phase(uvm_phase phase);

`uvm_component_utils(reference_model)
endclass

function reference_model::new(string name, uvm_component parent);
	super.new(name, parent);
endfunction

function void reference_model::build_phase(uvm_phase phase);
	super.build_phase(phase);
	port = new("port", this);
	ap = new("ap",this);
endfunction

task reference_model::main_phase(uvm_phase phase);
	transaction tr;
	transaction new_tr;
	super.main_phase(phase);
	while (1) begin
		port.get(tr);
		new_tr = new("new_tr");
		new_tr.copy(tr);
		`uvm_info("reference_model","get one transaction, copy and print it:",UVM_LOW)
		new_tr.print();
		ap.write(new_tr);
	end
endtask

`endif
