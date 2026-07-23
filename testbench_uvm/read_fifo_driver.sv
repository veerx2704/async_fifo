`ifndef READ_FIFO_DRIVER__SV
`define READ_FIFO_DRIVER__SV

class read_fifo_driver extends uvm_driver #(read_fifo_transaction);

virtual r_if r_if;
logic no_tr = 1'b0;

`uvm_component_utils(read_fifo_driver)
function new(string name = "read_fifo_driver", uvm_component parent);
	super.new(name, parent);
endfunction

virtual function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	if(!uvm_config_db#(virtual r_if)::get(this,"","r_if",r_if))
		`uvm_fatal("read_fifo_driver", "virtual interface must be set for read interface!")
endfunction

extern task main_phase(uvm_phase phase);
extern task drive_one_pkt(read_fifo_transaction tr);
extern task drive_nothing();
endclass

task read_fifo_driver::main_phase(uvm_phase phase);
	r_if.ren <= 1'b0;
	while(!r_if.rrst)
		@(posedge r_if.rclk);
	fork
		while(1) begin
          `uvm_info("DRIVER","Before get_next_item()",UVM_NONE)
			seq_item_port.get_next_item(req);
          `uvm_info("DRIVER","After get_next_item()",UVM_NONE)
			no_tr = 1'b0;
          `uvm_info("DRIVER","Before drive_one_pkt()",UVM_NONE)
			drive_one_pkt(req);
          `uvm_info("DRIVER","After drive_one_pkt()",UVM_NONE)
			no_tr = 1'b1;
          `uvm_info("DRIVER","Before item_done()",UVM_NONE)
			seq_item_port.item_done();
          `uvm_info("DRIVER","After item_done()",UVM_NONE)
		end
		while(1) begin
			drive_nothing();
		end
	join
endtask

task read_fifo_driver::drive_one_pkt(read_fifo_transaction tr);
//	@(posedge r_if.rclk);
//	while(1) begin
//		if(r_if.empty) begin
//			r_if.ren <= 1'b0;
//			@(posedge r_if.rclk);
//		end
//		else begin
//			r_if.ren <= 1'b1;
//			break;
//		end
//	end
  @(posedge r_if.rclk);
  	r_if.ren <= tr.ren;

endtask

task read_fifo_driver::drive_nothing();
	@(posedge r_if.rclk);
	if(no_tr) r_if.ren <= 1'b0;
endtask

`endif
