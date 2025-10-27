`timescale 1ns / 1ps
// =========================================================
// AI-Powered Low-Power RAM (Pattern-Oriented Memory)
// ---------------------------------------------------------
// Author : Snehasish Biswas (FPGA/RTL Research Prototype)
// Function: AI-based access prediction to reduce switching power
// =========================================================
module AI_LowPower_RAM #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8
)(
    input wire clk,
    input wire rst,
    input wire we,                       // Write enable
    input wire [ADDR_WIDTH-1:0] addr,    // Address input
    input wire [DATA_WIDTH-1:0] din,     // Data input
    output reg [DATA_WIDTH-1:0] dout,    // Data output
    output reg [7:0] power_saving_level  // Indicates AI-predicted efficiency
);

    // -------------------------------
    // Memory Array
    // -------------------------------
    reg [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];

    // -------------------------------
    // AI Core: Access Pattern Learning
    // -------------------------------
    reg [ADDR_WIDTH-1:0] last_addr;
    reg [7:0] addr_freq [0:(1<<ADDR_WIDTH)-1]; // Frequency counter
    reg [7:0] activity_score;                   // Activity level
    integer i;

    // -------------------------------
    // Power Controller
    // -------------------------------
    reg [7:0] power_gating_mask; // Simulated AI-driven clock gating mask

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            dout <= 0;
            power_saving_level <= 0;
            last_addr <= 0;
            activity_score <= 0;
            power_gating_mask <= 8'hFF; // all active initially
            for (i = 0; i < (1<<ADDR_WIDTH); i = i + 1) begin
                mem[i] <= 0;
                addr_freq[i] <= 0;
            end
        end else begin
            // Learning Phase: Track access frequency
            addr_freq[addr] <= addr_freq[addr] + 1;
            last_addr <= addr;

            // Power Controller Logic (AI-inspired)
            // If access frequency of a block is low, AI disables it (saves power)
            for (i = 0; i < (1<<ADDR_WIDTH); i = i + 1) begin
                if (addr_freq[i] < 3)
                    power_gating_mask[i % 8] <= 0; // low activity ? gate off
                else
                    power_gating_mask[i % 8] <= 1; // active
            end

            // Memory operation (only if not gated)
            if (power_gating_mask[addr % 8]) begin
                if (we)
                    mem[addr] <= din;
                else
                    dout <= mem[addr];
            end

            // Estimate power efficiency: more 0s in mask ? more savings
            activity_score = 0;
            for (i = 0; i < 8; i = i + 1)
                activity_score = activity_score + power_gating_mask[i];
            power_saving_level <= (8 - activity_score) * 12; // scale to %
        end
    end

endmodule
