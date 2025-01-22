`timescale 1ns / 1ps

module processor_tb;

    // Inputs to the processor module
    reg clk;
    reg reset;

    // Outputs from the processor module
    wire [31:0] pc_out;
    wire [31:0] instr_out;
    wire [31:0] a, b, c, Result;
    wire [31:0] Adderout, memwrite;
    
    // Instantiate the processor module
    processor uut (
        .clk(clk),
        .reset(reset),
        .pc_out(pc_out),
        .instr_out(instr_out),
        .Result(Result),
        .Adderout(Adderout),
        .a(a),
        .b(b),
        .c(c),
        .memwrite(memwrite)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Clock with a period of 10ns
    end

    // Testbench sequence
    initial begin
        // Initialize inputs
        reset = 1;
        
        // Reset the processor
        #10 reset = 0;

        // Wait for the processor to start executing instructions
        #135;

        $finish;
    end

endmodule
