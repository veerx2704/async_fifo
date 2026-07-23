`ifndef FIFO_ENV__SV
`define FIFO_ENV__SV

class fifo_env extends uvm_env;

write_fifo_agent	in_agent;
read_fifo_agent		out_agent;
reference_model		model;
scoreboard		scb;
virtual_sequencer	v_seqr;

uvm_tlm_analysis_fifo #(transaction) agt_scb_fifo;
uvm_tlm_analysis_fifo #(transaction) agt_mdl_fifo;
uvm_tlm_analysis_fifo #(transaction) mdl_scb_fifo;

function new(string name = "fifo_env", uvm_component parent);
	super.new(name, parent);
endfunction

virtual function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	in_agent = write_fifo_agent::type_id::create("in_agent",this);
	out_agent = read_fifo_agent::type_id::create("out_agent",this);
	model = reference_model::type_id::create("model",this);
	scb = scoreboard::type_id::create("scb", this);
	v_seqr = virtual_sequencer::type_id::create("v_seqr",this);
	agt_scb_fifo = new("agt_scb_fifo",this);
	agt_mdl_fifo = new("agt_mdl_fifo",this);
	mdl_scb_fifo = new("mdl_scb_fifo",this);
endfunction

extern virtual function void connect_phase(uvm_phase phase);
`uvm_component_utils(fifo_env)
endclass

function void fifo_env::connect_phase(uvm_phase phase);
	super.connect_phase(phase);
	in_agent.ap.connect(agt_mdl_fifo.analysis_export);
	model.port.connect(agt_mdl_fifo.blocking_get_export);
	model.ap.connect(mdl_scb_fifo.analysis_export);
	scb.exp_port.connect(mdl_scb_fifo.blocking_get_export);
	out_agent.ap.connect(agt_scb_fifo.analysis_export);
	scb.act_port.connect(agt_scb_fifo.blocking_get_export);
	
	v_seqr.w_seqr = in_agent.sqr;
	v_seqr.r_seqr = out_agent.sqr;
endfunction

`endif

