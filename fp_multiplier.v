`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: fp_multiplier
// Description: 32-bit IEEE 754 Floating-Point Multiplier
//////////////////////////////////////////////////////////////////////////////////

module fp_multiplier(
    input [31:0] a,
    input [31:0] b,
    output [31:0] result
);
    wire sign_a = a[31];
    wire sign_b = b[31];
    wire [7:0] exp_a = a[30:23];
    wire [7:0] exp_b = b[30:23];
    wire [23:0] mant_a = {1'b1, a[22:0]};
    wire [23:0] mant_b = {1'b1, b[22:0]};

    wire sign_result = sign_a ^ sign_b;
    wire [8:0] exp_sum = exp_a + exp_b - 8'd127;
    wire [47:0] mant_result = mant_a * mant_b;

    wire [22:0] normalized_mant;
    wire [7:0] final_exp;

    assign normalized_mant = mant_result[47] ? mant_result[46:24] : mant_result[45:23];
    assign final_exp = mant_result[47] ? exp_sum + 1 : exp_sum;

    assign result = {sign_result, final_exp, normalized_mant};

endmodule
