`include "define.sv"
`ifndef WRITE_FIFO_DRIVER__SV
`define WRITE_FIFO_DRIVER__SV
class write_fifo_driver extends uvm_driver#(transaction);

   virtual w_if w_if;
   logic no_tr = 1'b0;

   `uvm_component_utils(write_fifo_driver)
   function new(string name = "write_fifo_driver", uvm_component parent = null);
      super.new(name, parent);
   endfunction

   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);
     if(!uvm_config_db#(virtual w_if)::get(this, "", "w_if", w_if))
         `uvm_fatal("write_fifo_driver", "virtual interface must be set for w_if!!!")
   endfunction

   extern task main_phase(uvm_phase phase);
     extern task drive_one_pkt(transaction tr);
   extern task drive_nothing();
endclass

task write_fifo_driver::main_phase(uvm_phase phase);
   w_if.d_in <= `DATA_SIZE'b0;
   w_if.wen  <= 1'b0;
   while(!w_if.wrst)
      @(posedge w_if.wclk);
   
   fork
       while(1) begin
          seq_item_port.get_next_item(req);
          no_tr = 1'b0;
          drive_one_pkt(req);
          no_tr = 1'b1;
          seq_item_port.item_done();
       end
       while (1) begin
           drive_nothing();
       end
   join
endtask

task write_fifo_driver::drive_one_pkt(transaction tr);
  	  	  integer full_count = 0;
      `uvm_info("write_fifo_driver", "begin to drive one pkt", UVM_LOW);
      @(posedge w_if.wclk);
      while(1) begin
        if (w_if.full) begin
            //wait if full.
          	full_count++;
            w_if.wen <= 1'b0;
          if(full_count == `DEPTH) break;
            @(posedge w_if.wclk);
          
        end
        else begin
          w_if.wen<= 1'b1;
          w_if.d_in <= tr.data;
          break;
        end
      end
      `uvm_info("write_fifo_driver", "end drive one pkt", UVM_LOW);


endtask
task write_fifo_driver::drive_nothing();
   @(posedge w_if.wclk);
   if (no_tr) w_if.wen<= 1'b0; //If no transaction. Drive the winc to zero.

endtask

`endif
