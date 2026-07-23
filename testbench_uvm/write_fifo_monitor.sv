`ifndef WRITE_FIFO_MONITOR__SV
`define WRITE_FIFO_MONITOR__SV
class write_fifo_monitor extends uvm_monitor;

   virtual w_if w_if;

  uvm_analysis_port #(transaction)  ap;
   
   `uvm_component_utils(write_fifo_monitor)
   function new(string name = "write_fifo_monitor", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db#(virtual w_if)::get(this, "", "w_if", w_if))
         `uvm_fatal("write_fifo_monitor", "virtual interface must be set for w_if!!!")
      ap = new("ap", this);
   endfunction

   extern task main_phase(uvm_phase phase);
     extern task collect_one_pkt(transaction tr);
endclass

task write_fifo_monitor::main_phase(uvm_phase phase);
   transaction tr;
   while(1) begin
      tr = new("tr");
      collect_one_pkt(tr);
      ap.write(tr);
   end
endtask

task write_fifo_monitor::collect_one_pkt(transaction tr);
   
   while(1) begin
      @(posedge w_if.wclk);
     if(w_if.wen && !w_if.full) break;
   end
   `uvm_info("write_fifo_monitor", "begin to collect one pkt", UVM_MEDIUM);
   tr.data = w_if.d_in;
   `uvm_info("write_fifo_monitor", "end collect one pkt", UVM_MEDIUM);
endtask


`endif
