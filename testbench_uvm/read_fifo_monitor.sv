`ifndef READ_FIFO_MONITOR__SV
`define READ_FIFO_MONITOR__SV

class read_fifo_monitor extends uvm_monitor;

virtual r_if r_if;

uvm_analysis_port #(transaction) ap;

`uvm_component_utils(read_fifo_monitor)
function new(string name = "read_fifo_monitor", uvm_component parent = null);
	super.new(name, parent);
endfunction

virtual function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	if (!uvm_config_db#(virtual r_if)::get(this,"","r_if",r_if))
		`uvm_fatal("read_fifo_monitor","virtual interface must be set for read interface!")
	ap = new("ap",this);
endfunction

extern task main_phase(uvm_phase phase);
extern task collect_one_pkt(transaction tr);

endclass

task read_fifo_monitor::main_phase(uvm_phase phase);
	transaction tr;
	while(1) begin
		tr = new("tr");
		collect_one_pkt(tr);
		ap.write(tr);
	end
endtask

task read_fifo_monitor::collect_one_pkt(transaction tr);
	while(1) begin
		@(posedge r_if.rclk);
      if(r_if.ren && !r_if.empty) break;
	end
	
	`uvm_info("read_fifo_master","begin to collect one packet", UVM_MEDIUM);
	tr.data = r_if.d_out;
	`uvm_info("read_fifo_monitor", "ended collection of one packet", UVM_MEDIUM);
endtask

`endif

