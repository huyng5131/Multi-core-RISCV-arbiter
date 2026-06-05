module single_port_ram #(
    parameter ADDR_WIDTH = 12, // 4096 words (16KB)
    parameter INIT_FILE = ""
)(
    input clk,
    // Ch? có m?t giao ti?p duy nh?t cho t?t c? các Master
    input [ADDR_WIDTH-1:0] addr,
    input [31:0]           din,
    input [3:0]            we,
    output reg [31:0]      dout,
    output                 ready
);
    reg [31:0] ram [0:(2**ADDR_WIDTH)-1];

    initial begin
        if (INIT_FILE != "") $readmemh(INIT_FILE, ram);
    end

    always @(posedge clk) begin
        // Ghi d? li?u theo byte-mask
        if (we[0]) ram[addr][7:0]   <= din[7:0];
        if (we[1]) ram[addr][15:8]  <= din[15:8];
        if (we[2]) ram[addr][23:16] <= din[23:16];
        if (we[3]) ram[addr][31:24] <= din[31:24];
        
        // ??c d? li?u ra
        dout <= ram[addr];
    end

    // RAM ??n c?ng ??ng b? th??ng s?n sàng sau 1 chu k?
    assign ready = 1'b1; 
endmodule