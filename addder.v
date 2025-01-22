`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: adder
// Description: 32-bit IEEE 754 Floating-Point Adder
//////////////////////////////////////////////////////////////////////////////////

module adder (
    input [31:0] a,
    input [31:0] b,
    output [31:0] sum
);
    wire sign_a, sign_b;
    wire [7:0] exp_a, exp_b;
    wire [23:0] mantissa_a, mantissa_b;

    assign sign_a = a[31];
    assign sign_b = b[31];
    assign exp_a = a[30:23];
    assign exp_b = b[30:23];
    assign mantissa_a = {1'b1, a[22:0]};
    assign mantissa_b = {1'b1, b[22:0]};

    reg [23:0] mantissa_a_shifted, mantissa_b_shifted;
    reg [7:0] exp_diff, exp_result;
    reg [24:0] mantissa_sum;
    reg sign_result;
    reg [22:0] mantissa_result;

    always @(*) begin
        if (exp_a > exp_b) begin
            exp_diff = exp_a - exp_b;
            mantissa_a_shifted = mantissa_a;
            mantissa_b_shifted = mantissa_b >> exp_diff;
            exp_result = exp_a;
            sign_result = sign_a;
        end else begin
            exp_diff = exp_b - exp_a;
            mantissa_a_shifted = mantissa_a >> exp_diff;
            mantissa_b_shifted = mantissa_b;
            exp_result = exp_b;
            sign_result = sign_b;
        end

        if (sign_a == sign_b) begin
            mantissa_sum = mantissa_a_shifted + mantissa_b_shifted;
        end else begin
            if (mantissa_a_shifted >= mantissa_b_shifted) begin
                mantissa_sum = mantissa_a_shifted - mantissa_b_shifted;
                sign_result = sign_a;
            end else begin
                mantissa_sum = mantissa_b_shifted - mantissa_a_shifted;
                sign_result = sign_b;
            end
        end
    end

    always @(*) begin
        if (mantissa_sum[24]) begin
            mantissa_result = mantissa_sum[23:1];
            exp_result = exp_result + 1;
        end else begin
            mantissa_result = mantissa_sum[22:0];
        end
    end

    assign sum = {sign_result, exp_result, mantissa_result};

endmodule
