module picorv32_arbiter (
    input clk, resetn,

    // Giao tiep voi Core 0 (Master 0)
    input         m0_valid,
    input  [31:0] m0_addr,
    input  [31:0] m0_wdata,
    input  [3:0]  m0_wstrb,
    output        m0_ready,

    // Giao tiep voi Core 1 (Master 1)
    input         m1_valid,
    input  [31:0] m1_addr,
    input  [31:0] m1_wdata,
    input  [3:0]  m1_wstrb,
    output        m1_ready,

    // Giao tiep chung dan vao RAM (Slave)
    output        s_valid,
    output [31:0] s_addr,
    output [31:0] s_wdata,
    output [3:0]  s_wstrb,
    input         s_ready
);
    // Bien ghi nho de thuc hien xoay vong uu tien (Round-robin)
    reg last_served; 

    // Logic quyet dinh ai duoc quyen truy cap (Grant)
    // Neu ca 2 cung valid, se uu tien loi chua duoc phuc vu o lan truoc
    wire g0 = m0_valid && (!m1_valid || last_served);
    wire g1 = m1_valid && (!m0_valid || !last_served);

    // Chuyen mach (Mux) tin hieu tu Master thang cuoc vao RAM
    assign s_valid = g0 ? m0_valid : (g1 ? m1_valid : 1'b0);
    assign s_addr  = g0 ? m0_addr  : m1_addr;
    assign s_wdata = g0 ? m0_wdata : m1_wdata;
    assign s_wstrb = g0 ? m0_wstrb : m1_wstrb;

    // QUAN TRONG: Chi gui tin hieu ready ve cho Core dang duoc cho phep
    // Core con lai se thay ready=0 va tu dong dung doi (stall)
    assign m0_ready = g0 && s_ready;
    assign m1_ready = g1 && s_ready;

    // Luu lai trang thai de dao quyen uu tien cho lan sau
    always @(posedge clk) begin
        if (!resetn) last_served <= 0;
        else if (s_ready) last_served <= g0 ? 0 : 1;
    end
endmodule