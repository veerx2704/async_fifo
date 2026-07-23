`ifndef SCOREBOARD__SV
`define SCOREBOARD__SV

class scoreboard extends uvm_scoreboard;

transaction expect_queue[$];

uvm_blocking_get_port #(transaction) exp_port;
uvm_blocking_get_port #(transaction) act_port;

`uvm_component_utils(scoreboard)

extern function new(string name, uvm_component parent = null);
extern virtual function void build_phase(uvm_phase phase);
extern virtual task main_phase(uvm_phase phase);

endclass

function scoreboard::new(string name, uvm_component parent = null);
	super.new(name, parent);
endfunction

function void scoreboard::build_phase(uvm_phase phase);
	super.build_phase(phase);
	exp_port = new("exp_port",this);
	act_port = new("act_port",this);
endfunction

task scoreboard::main_phase(uvm_phase phase);
	transaction expected, actual, temp;
	bit result;
	
	super.main_phase(phase);
	fork
		while(1) begin
			exp_port.get(expected);
			expect_queue.push_back(expected);
		end
		while(1) begin
			act_port.get(actual);
			if(expect_queue.size() > 0 ) begin
				temp = expect_queue.pop_front();
				result = actual.compare(temp);
				if(result) begin
					`uvm_info("scoreboard", "Compare SUCCESSFUL", UVM_LOW);
					$display("Expected packet is:");
					temp.print();
					$display("Actual packet is:");
					actual.print();
				end
				else begin
					`uvm_error("scoreboard","Compare FAILED");
					$display("Expected packet is:");
					temp.print();
					$display("Actual packet is:");
					actual.print();
				end
			end
			else begin
				`uvm_error("scoreboard", "Received from DUT, while Expect Queue is empty");
				$display("The unexpected packet is:");
				actual.print();
			end
		end
	join
endtask

`endif
