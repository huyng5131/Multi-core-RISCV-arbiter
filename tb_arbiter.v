`timescale 1ns / 1ps

module tb_arbiter;
    // --- Tin hieu co ban cap cho he thong ---
    reg clk;            
    reg resetn;         
    wire trap_0;        
    wire trap_1;        

    // --- Khoi tao he thong Top-level (DUT) ---
    dual_core dut (
        .clk(clk),
        .resetn(resetn),
        .trap_0(trap_0),
        .trap_1(trap_1)
    );

    // =================================================================
    // DUONG DAN PHAN CAP (Hierarchical Probing)
    // Dua cac tin hieu an ben trong chip ra ngoai ria de ModelSim tu thay
    // =================================================================
    
    // Cac tin hieu quan trong cua Core 0
    wire        c0_valid = dut.core_0.mem_valid;
    wire [31:0] c0_addr  = dut.core_0.mem_addr;
    wire [31:0] c0_wdata = dut.core_0.mem_wdata;
    wire [31:0] c0_rdata = dut.core_0.mem_rdata; // Du lieu doc cua Core 0
    wire        c0_ready = dut.core_0.mem_ready;
    wire        c0_instr = dut.core_0.mem_instr;

    // Cac tin hieu quan trong cua Core 1
    wire        c1_valid = dut.core_1.mem_valid;
    wire [31:0] c1_addr  = dut.core_1.mem_addr;
    wire [31:0] c1_wdata = dut.core_1.mem_wdata;
    wire [31:0] c1_rdata = dut.core_1.mem_rdata; // Du lieu doc cua Core 1
    wire        c1_ready = dut.core_1.mem_ready;
    wire        c1_instr = dut.core_1.mem_instr;

    // Cac tin hieu phan xu cua Arbiter
    wire        arb_g0   = dut.arbiter_inst.g0;
    wire        arb_g1   = dut.arbiter_inst.g1;
    wire        arb_last = dut.arbiter_inst.last_served;

    // --- Tao xung nhip 100MHz ---
    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    // --- Kich ban khoi dong mo phong ---
    initial begin
        resetn = 0; 
        #100;
        resetn = 1; // CPU bat dau thoat reset va chay chuong trinh
        
        $display("====================================================");
        $display("===> BAT DAU THEO DOI LOG DIEU KHIEN CUA ARBITER <===");
        $display("====================================================");

        #5000; // Chay trong 5 micro giay de xem nhat ky ghi RAM
        
        $display("====================================================");
        $display("===> KET THUC THOI GIAN THEO DOI CONSOLE LOG <=======");
        $display("====================================================");
        $finish; 
    end

    // =================================================================
    // CONSOLE LOG AUTOMATION (In nhat ky tu dong ra o chu cua ModelSim)
    // =================================================================
    always @(posedge clk) begin
        if (resetn) begin
            
            // Log hoan thanh chu ky doi voi Core 0
            if (c0_valid && c0_ready) begin
                if (dut.core_0.mem_wstrb != 4'b0)
                    $display("[TIME: %0t ps] CORE 0 ===> GHI RAM [0x%h] = 0x%h", $time, c0_addr, c0_wdata);
                else
                    $display("[TIME: %0t ps] CORE 0 ---> DOC %s [0x%h] = 0x%h", $time, c0_instr ? "MA LENH" : "DU LIEU", c0_addr, c0_rdata);
            end
            
            // Log hoan thanh chu ky doi voi Core 1
            if (c1_valid && c1_ready) begin
                if (dut.core_1.mem_wstrb != 4'b0)
                    $display("[TIME: %0t ps] CORE 1 ===> GHI RAM [0x%h] = 0x%h", $time, c1_addr, c1_wdata);
                else
                    $display("[TIME: %0t ps] CORE 1 ---> DOC %s [0x%h] = 0x%h", $time, c1_instr ? "MA LENH" : "DU LIEU", c1_addr, c1_rdata);
            end

            // Log canh bao khi xay ra TRANH CHAP BUS va co Core bi Stall (Dung doi)
            if (c0_valid && !c0_ready && arb_g1)
                $display("[TIME: %0t ps] [!] TRANH CHAP: Core 1 dang chiem Bus, Core 0 phai STALL cho...", $time);
                
            if (c1_valid && !c1_ready && arb_g0)
                $display("[TIME: %0t ps] [!] TRANH CHAP: Core 0 dang chiem Bus, Core 1 phai STALL cho...", $time);
        end
    end

endmodule