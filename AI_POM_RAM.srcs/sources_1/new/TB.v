`timescale 1ns / 1ps
// =========================================================
// Testbench for AI_LowPower_RAM
// =========================================================
`timescale 1ns/1ps

module tb_AI_LowPower_RAM;

    parameter ADDR_WIDTH = 4;
    parameter DATA_WIDTH = 8;

    reg clk;
    reg rst;
    reg we;
    reg [ADDR_WIDTH-1:0] addr;
    reg [DATA_WIDTH-1:0] din;
    wire [DATA_WIDTH-1:0] dout;
    wire [7:0] power_saving_level;

    // Instantiate DUT
    AI_LowPower_RAM #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .we(we),
        .addr(addr),
        .din(din),
        .dout(dout),
        .power_saving_level(power_saving_level)
    );

    // Clock Generation
    always #5 clk = ~clk; // 100MHz clock

    // Test sequence
    initial begin
        $display("=== AI Low Power RAM Simulation Start ===");
        clk = 0; rst = 1; we = 0; addr = 0; din = 0;
        #10 rst = 0;

        // Write data to some addresses
        repeat(3) begin
            @(posedge clk);
            we = 1; addr = 4'd2; din = 8'hAA;
        end

        repeat(5) begin
            @(posedge clk);
            we = 1; addr = 4'd5; din = 8'hBB;
        end

        // Access random low-usage addresses
        @(posedge clk); we = 1; addr = 4'd9; din = 8'hCC;
        @(posedge clk); we = 1; addr = 4'd10; din = 8'hDD;

        // Now read from same addresses
        @(posedge clk); we = 0; addr = 4'd2;
        @(posedge clk); addr = 4'd5;
        @(posedge clk); addr = 4'd10;

        // Observe AI Power Optimization
        repeat(10) @(posedge clk);

        $display("=== Simulation Complete ===");
        $finish;
    end

    // Monitor signals
    initial begin
        $monitor("Time=%0t | Addr=%d | WE=%b | DataOut=%h | PowerEff=%d%%",
                 $time, addr, we, dout, power_saving_level);
    end

endmodule
