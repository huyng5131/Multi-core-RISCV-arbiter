module dual_core (
    input clk,
    input resetn,
    output trap_0,
    output trap_1
);
    // Luu y comment tieng Viet khong dau trong code
    // Khai bao cac duong day tin hieu noi bo
    wire v0, r0, i0;
    wire [31:0] a0, d0;
    wire [3:0] w0;

    wire v1, r1, i1;
    wire [31:0] a1, d1;
    wire [3:0] w1;

    wire s_v, s_r;
    wire [31:0] s_a, s_d, s_q;
    wire [3:0] s_w;

    // Khoi tao Core 0 - Bat dau tai dia chi 0x0
    picorv32 #(
        .PROGADDR_RESET(32'h0000_0000),
        .ENABLE_MUL(1),
        .ENABLE_DIV(1)
    ) core_0 (
        .clk(clk), .resetn(resetn), .trap(trap_0),
        .mem_valid(v0), .mem_ready(r0), .mem_addr(a0), 
        .mem_wdata(d0), .mem_wstrb(w0), .mem_rdata(s_q),
        .mem_instr(i0),    // Noi chan mem_instr de CPU biet dang doc lenh hay data
        .irq(32'b0),        // QUAN TRONG: Ep toan bo 32 chan ngat ve 0 de khong bi loi X
        .pcpi_ready(1'b0), // Khoa cac giao tiep dong xu ly khong dung toi
        .pcpi_wait(1'b0),
        .pcpi_wr(1'b0),
        .pcpi_rd(32'b0)
    );

    // Khoi tao Core 1 - Bat dau tai dia chi 0x1000
    picorv32 #(
        .PROGADDR_RESET(32'h0000_1000),
        .ENABLE_MUL(1), .ENABLE_DIV(1)
    ) core_1 (
        .clk(clk), .resetn(resetn), .trap(trap_1),
        .mem_valid(v1), .mem_ready(r1), .mem_addr(a1), 
        .mem_wdata(d1), .mem_wstrb(w1), .mem_rdata(s_q),
        .mem_instr(i1),
        .irq(32'b0),        // Ep chan ngat cua Core 1 ve 0
        .pcpi_ready(1'b0),
        .pcpi_wait(1'b0),
        .pcpi_wr(1'b0),
        .pcpi_rd(32'b0)
    );

    // Khoi tao Arbiter (Giu nguyen nhu cu)
    picorv32_arbiter arbiter_inst (
        .clk(clk), .resetn(resetn),
        .m0_valid(v0), .m0_addr(a0), .m0_wdata(d0), .m0_wstrb(w0), .m0_ready(r0),
        .m1_valid(v1), .m1_addr(a1), .m1_wdata(d1), .m1_wstrb(w1), .m1_ready(r1),
        .s_valid(s_v), .s_addr(s_a), .s_wdata(s_d), .s_wstrb(s_w), .s_ready(s_r)
    );

    // Khoi tao RAM don cong (Giu nguyen nhu cu)
    single_port_ram #(.INIT_FILE("program.hex")) ram_inst (
        .clk(clk), .addr(s_a[13:2]), .din(s_d), .we(s_w & {4{s_v}}), .dout(s_q), .ready(s_r)
    );

endmodule