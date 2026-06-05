module single_port_ram #(
    parameter ADDR_WIDTH = 12, // Do rong dia chi 12-bit (16KB)
    parameter INIT_FILE = "program.hex" // File hex de nap du lieu
)(
    input clk,
    // Cac tin hieu dieu khien tu Arbiter
    input [ADDR_WIDTH-1:0] addr, 
    input [31:0]           din,  
    input [3:0]            we,   
    output [31:0]          dout, // Bo chu "reg" vi gio la doc bat dong bo
    output                 ready 
);
    // Khai bao mang RAM 32-bit
    reg [31:0] ram [0:(2**ADDR_WIDTH)-1];

    // Doc file hex vao RAM khi bat dau mo phong
    initial begin
        if (INIT_FILE != "") $readmemh(INIT_FILE, ram);
    end

    // Ghi dong bo (luon ghi vao canh len cua dong ho)
    always @(posedge clk) begin
        if (we[0]) ram[addr][7:0]   <= din[7:0];
        if (we[1]) ram[addr][15:8]  <= din[15:8];
        if (we[2]) ram[addr][23:16] <= din[23:16];
        if (we[3]) ram[addr][31:24] <= din[31:24];
    end

    // QUAN TRONG: Doc bat dong bo (Combinational Read)
    // Thay doi addr la dout ra ket qua ngay lap tuc, khong doi canh len clk
    assign dout = ram[addr];
    
    // Luon san sang vi mach doc la mach to hop phan hoi tuc thi
    assign ready = 1'b1; 

endmodule