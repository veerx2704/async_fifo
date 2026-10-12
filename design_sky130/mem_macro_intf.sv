module mem_macro_intf #(
    parameter ADDR_WIDTH = 9,
    parameter DATA_WIDTH = 32
)(
    input  wire                  clk,        // Fast internal system clock
    input  wire                  rst_n,      // Active low reset
    input  wire [ADDR_WIDTH-1:0] async_addr_1rw,
    input  wire [ADDR_WIDTH-1:0] async_addr_1r,
    input  wire [DATA_WIDTH-1:0] async_data_1rw, 
    input  wire [(DATA_WIDTH/8)-1:0] wmask0,
    input  wire                  async_csb_1r,
    input  wire                  async_csb_1rw, 
    output reg  [DATA_WIDTH-1:0] async_dout_1r,
    output reg  [DATA_WIDTH-1:0] async_dout_1rw
);

    reg [ADDR_WIDTH-1:0] addr_r1, addr_r2;
    reg                  csb_r1;
    wire                 addr_changed_r;
    wire [DATA_WIDTH-1:0] sram_dout_r;

    reg [DATA_WIDTH - 1:0] data_rw1;
    reg [ADDR_WIDTH-1:0] addr_rw1, addr_rw2;
    reg                  csb_rw1;
    wire                 addr_changed_rw;
    wire [DATA_WIDTH-1:0] sram_dout_rw;


    // Double-buffer inputs to eliminate metastability and detect changes
    always @(posedge clk) begin
        if (!rst_n) begin
            addr_r1 <= 0;
            addr_r2 <= 0;
            csb_r1  <= 1'b1;
            addr_rw1 <= 0;
            addr_rw2 <= 0;
            csb_rw1  <= 1'b1;
            data_rw1 <= {DATA_WIDTH{1'b0}};
        end else begin
            addr_r1 <= async_addr_1r;
            addr_r2 <= addr_r1;
            csb_r1  <= async_csb_1r;
            addr_rw1 <= async_addr_1rw;
            addr_rw2 <= addr_rw1;
            csb_rw1  <= async_csb_1rw;
            data_rw1 <= async_data_1rw;
        end
    end

    // Signal is high for exactly one clock cycle after a change is caught
    assign addr_changed_r = (addr_r1 != addr_r2);
    assign addr_changed_rw = (addr_rw1 != addr_rw2);

    // Instantiation of Sky130 Macro
    sky130_sram_2kbyte_1rw1r_32x512_8 u_sky130_sram (
        .clk0  (clk),
        .csb0  (!(csb_rw1 || !addr_changed_rw)),
        .web0  (!(csb_rw1 || !addr_changed_rw)),
        .wmask0(wmask0),
        .addr0 (addr_rw1),
        .din0  (data_rw1),
        .dout0 (sram_dout_rw),
        
        .clk1  (clk),
        .csb1  (!(csb_r1 || !addr_changed_r)), // Only enable macro when address actually updates
        .addr1 (addr_r1),
        .dout1 (sram_dout_r)
    );

    // Continuous assignment or latch to drive the asynchronous output output bus
    always @(*) begin
        async_dout_1r = sram_dout_r;
        async_dout_1rw = sram_dout_rw;
    end

endmodule
