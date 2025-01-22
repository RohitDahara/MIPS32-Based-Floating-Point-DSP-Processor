`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.10.2024 14:00:39
// Design Name: 
// Module Name: macc
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Multiply-Accumulate (MACC) unit with floating-point operations
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// Top-Level MACC Module
module macc (
    input [31:0] a,          // First floating-point input for multiplication
    input [31:0] b,          // Second floating-point input for multiplication
    input [31:0] acc,        // Accumulator input (previous accumulated result)
    output [31:0] result     // Output result (new accumulated value)
);

    wire [31:0] mult_result; // Intermediate result of the multiplier
    wire [31:0] add_result;  // Intermediate result of the adder

    // Instantiate the floating-point multiplier
    fp_multiplier multiplier (
        .a(a),
        .b(b),
        .result(mult_result)  // Output: multiplication result
    );

    // Instantiate the floating-point adder
    fp_adder adder (
        .a(mult_result),      // First input: multiplier result
        .b(acc),              // Second input: accumulator value
        .sum(add_result)      // Output: addition result
    );

    // Output the final result of the MAC operation
    assign result = add_result;

endmodule

//////////////////////////////////////////////////////////////////////////////////
// Floating-Point Multiplier Module
//////////////////////////////////////////////////////////////////////////////////
module fp_multiplier (
    input [31:0] a,         // First floating-point input
    input [31:0] b,         // Second floating-point input
    output [31:0] result    // Floating-point multiplication result
);
    // Extract fields for multiplication
    wire sign_a = a[31];
    wire sign_b = b[31];
    wire [7:0] exp_a = a[30:23];
    wire [7:0] exp_b = b[30:23];
    wire [23:0] mant_a = {1'b1, a[22:0]}; // Implicit leading 1 for normalized numbers
    wire [23:0] mant_b = {1'b1, b[22:0]}; 

    // Calculate sign, exponent, and mantissa
    wire sign_res = sign_a ^ sign_b;
    wire [8:0] exp_res = exp_a + exp_b - 8'd127; // Exponent bias adjustment
    wire [47:0] mant_res = mant_a * mant_b;      // 48-bit mantissa product

    // Normalize result
    wire normalization_needed = mant_res[47];
    wire [7:0] final_exp = normalization_needed ? (exp_res + 1) : exp_res;
    wire [22:0] final_mant = normalization_needed ? mant_res[46:24] : mant_res[45:23];

    // Pack result
    assign result = {sign_res, final_exp, final_mant};

endmodule

//////////////////////////////////////////////////////////////////////////////////
// Floating-Point Adder Module
//////////////////////////////////////////////////////////////////////////////////
module fp_adder (
    input [31:0] a,         // First floating-point input
    input [31:0] b,         // Second floating-point input
    output [31:0] sum       // Floating-point addition result
);
    // Extract fields for addition
    wire sign_a = a[31];
    wire sign_b = b[31];
    wire [7:0] exp_a = a[30:23];
    wire [7:0] exp_b = b[30:23];
    wire [23:0] mant_a = {1'b1, a[22:0]};
    wire [23:0] mant_b = {1'b1, b[22:0]};

    // Align exponents by shifting the mantissas
    wire [7:0] exp_diff = (exp_a > exp_b) ? (exp_a - exp_b) : (exp_b - exp_a);
    wire [23:0] aligned_mant_a = (exp_a >= exp_b) ? mant_a : (mant_a >> exp_diff);
    wire [23:0] aligned_mant_b = (exp_b >= exp_a) ? mant_b : (mant_b >> exp_diff);
    wire [7:0] final_exp = (exp_a >= exp_b) ? exp_a : exp_b;

    // Perform addition or subtraction based on the signs
    wire [24:0] mant_sum = (sign_a == sign_b) ? (aligned_mant_a + aligned_mant_b)
                                              : (aligned_mant_a - aligned_mant_b);

    // Normalize the result
    wire normalization_needed = mant_sum[24];
    wire [7:0] normalized_exp = normalization_needed ? (final_exp + 1) : final_exp;
    wire [22:0] normalized_mant = normalization_needed ? mant_sum[23:1] : mant_sum[22:0];

    // Pack result
    assign sum = {sign_a, normalized_exp, normalized_mant};

endmodule
