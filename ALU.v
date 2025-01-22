`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12.10.2024 12:04:59
// Design Name: 
// Module Name: alu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ALU(n1,n2,oper,result,Overflow,Underflow,Exception);
input [31:0] n1,n2;
input[1:0] oper;
output Overflow,Underflow,Exception;
output [31:0] result;
wire [31:0] temp_result,result1,result2,result3,result4,result5,result6;
wire Overflow1,Underflow1,Exception1,Overflow2,Underflow2,Exception2,Overflow3,Underflow3,Exception3;

add_sub AS(.n1(n1),.n2(n2),.result(result1),.sub(|oper),.Overflow(Overflow1),.Underflow(Underflow1),.Exception(Exception1));
mul M(.n1(n1),.n2(n2),.result(result2),.Overflow(Overflow2),.Underflow(Underflow2),.Exception(Exception2));
div D(.n1(n1),.n2(n2),.result(result3),.Overflow(Overflow3),.Underflow(Underflow3),.Exception(Exception3));

Mux_32Bit M01(.in0(result1),.in1(result2),.sl(oper[1]),.out(temp_result));
Mux_32Bit M02(.in0(temp_result),.in1(result3),.sl(&oper),.out(result4));

Mux_1Bit M03(.in0(Overflow1),.in1(Overflow2),.sl(oper[1]),.out(temp1));
Mux_1Bit M04(.in0(temp1),.in1(Overflow3),.sl(&oper),.out(Overflow));

Mux_1Bit M05(.in0(Underflow1),.in1(Underflow2),.sl(oper[1]),.out(temp2));
Mux_1Bit M06(.in0(temp2),.in1(Underflow3),.sl(&oper),.out(Underflow));

Mux_1Bit M07(.in0(Exception1),.in1(Exception2),.sl(oper[1]),.out(temp3));
Mux_1Bit M08(.in0(temp3),.in1(Exception3),.sl(&oper),.out(Exception));

// if Exception is 1 ===> set the result to all 1s
Mux_32Bit M09(.in0(result4),.in1(32'b1_11111111_11111111111111111111111),.sl(Exception),.out(result5));

// if Underflow is 1 ===> set the result to all 0s and sign is the final_sign ( setting to 0 )
Mux_32Bit M010(.in0(result5),.in1({result4[31],31'b00000000_00000000000000000000000}),.sl(Underflow),.out(result6));

// if Overflow is 1 ===> set the E to all 1s and M to all 0s and sign is the final_sign ( setting to +inf or -inf)
Mux_32Bit M011(.in0(result6),.in1({result4[31],31'b11111111_00000000000000000000000}),.sl(Overflow),.out(result));

endmodule


module Reduction_and8bit(input [7:0] in,output out);

	wire w1,w2,w3,w4,w5,w6;
	and(w1,in[1],in[0]);
	and(w2,in[2],w1);
	and(w3,in[3],w2);
	and(w4,in[4],w3);
	and(w5,in[5],w4);
	and(w6,in[6],w5);
	and(out,in[7],w6);

endmodule


module Reduction_or8bit(input [7:0] in,output out);

	wire w1,w2,w3,w4,w5,w6;
	or(w1,in[1],in[0]);
	or(w2,in[2],w1);
	or(w3,in[3],w2);
	or(w4,in[4],w3);
	or(w5,in[5],w4);
	or(w6,in[6],w5);
	or(out,in[7],w6);

endmodule


module Reduction_or24bit(input [23:0] in,output out);

	Reduction_or8bit RO01(.in(in[7:0]),.out(o1));
	Reduction_or8bit RO02(.in(in[15:8]),.out(o2));
	Reduction_or8bit RO03(.in(in[23:16]),.out(o3));
	or(out,o1,o2,o3);

endmodule


module Reduction_nor31bit(input [30:0] in,output out);

	Reduction_or24bit RO01(.in(in[23:0]),.out(o1));
	Reduction_or8bit RO02(.in({1'b0,in[30:24]}),.out(o2));
	nor(out,o1,o2);

endmodule


module Complement8bit(input [7:0] in,output [7:0] out);

	not(out[0],in[0]);
	not(out[1],in[1]);
	not(out[2],in[2]);
	not(out[3],in[3]);
	not(out[4],in[4]);
	not(out[5],in[5]);
	not(out[6],in[6]);
	not(out[7],in[7]);
	
endmodule


module Complement24bit(input [23:0] in,output [23:0] out);

	Complement8bit C01(.in(in[7:0]),.out(out[7:0]));
	Complement8bit C02(.in(in[15:8]),.out(out[15:8]));
	Complement8bit C03(.in(in[23:16]),.out(out[23:16]));
	
endmodule


module Adder4bit(input [3:0] a,input [3:0] b,input cin,output [3:0]sum,output cout);

	wire g0,g1,g2,g3,p0,p1,p2,p3,c2,c1,c0;
	assign g0 = a[0]&b[0];
	assign g1 = a[1]&b[1];
	assign g2 = a[2]&b[2];
	assign g3 = a[3]&b[3];
	assign p0 = a[0]^b[0];
	assign p1 = a[1]^b[1];
	assign p2 = a[2]^b[2];
	assign p3 = a[3]^b[3];
	assign c0 = g0 |( p0 & cin);
	assign c1 = g1 | (p1&g0)| (p1&p0&cin);
	assign c2 = g2 | (p2&g1) | (p2&p1&g0) | (p2&p1&p0&cin);
	assign cout = g3 | (p3&g2) | (p3&p2&g1) | (p3&p2&p1&g0) | (p3&p2&p1&p0&cin);

	xor(sum[0],p0,cin);
	xor(sum[1],p1,c0);
	xor(sum[2],p2,c1);
	xor(sum[3],p3,c2);

endmodule


module Adder8bit(input [7:0] a,input [7:0] b,input cin,output [7:0]sum,output cout);

	Adder4bit ADD01(.a(a[3:0]),.b(b[3:0]),.cin(cin),.sum(sum[3:0]),.cout(ctemp));
	Adder4bit ADD02(.a(a[7:4]),.b(b[7:4]),.cin(ctemp),.sum(sum[7:4]),.cout(cout));

endmodule


module Adder9bit(input [8:0] a,input [8:0] b,input cin,output [8:0]sum,output cout);

	Adder8bit ADD01(.a(a[7:0]),.b(b[7:0]),.cin(cin),.sum(sum[7:0]),.cout(ctemp));
	xor(sum[8],a[8],b[8],ctemp);
	assign cout = a[8]&b[8] | a[8]&ctemp | ctemp&b[8];

endmodule


module Adder24bit(input [23:0] a,input [23:0] b,input cin,output [23:0]sum,output cout);

	Adder8bit ADD01(.a(a[7:0]),.b(b[7:0]),.cin(cin),.sum(sum[7:0]),.cout(ctemp1));
	Adder8bit ADD02(.a(a[15:8]),.b(b[15:8]),.cin(ctemp1),.sum(sum[15:8]),.cout(ctemp2));
	Adder8bit ADD03(.a(a[23:16]),.b(b[23:16]),.cin(ctemp2),.sum(sum[23:16]),.cout(cout));

endmodule


module Complement8bit_2s(input [7:0] in,output [7:0] out);

	wire [7:0] outtemp;
	Complement8bit C01(.in(in),.out(outtemp));
	Adder8bit ADD01(.a(outtemp),.b(8'b0000_0001),.cin(1'b0),.sum(out),.cout());
	
endmodule



module Complement24bit_2s(input [23:0] in,output [23:0] out);

	wire [23:0] outtemp;

	Complement24bit C01(.in(in),.out(outtemp));

	Adder24bit ADD01(.a(outtemp),.b(24'b0000_0000_0000_0000_0000_0001),.cin(1'b0),.sum(out),.cout());

endmodule



module Mux_1Bit(input in0,input in1 ,input sl,output out);

	wire w1,w2,invSL;

	not(invSL,sl);

	and(w1,in0,invSL);

	and(w2,in1,sl);

	or(out,w1,w2);

endmodule


module Mux_8Bit(input [7:0] in0,input [7:0] in1 ,input sl,output [7:0] out);

	Mux_1Bit M01(.in0(in0[0]),.in1(in1[0]) ,.sl(sl),.out(out[0]));
	Mux_1Bit M02(.in0(in0[1]),.in1(in1[1]) ,.sl(sl),.out(out[1]));
	Mux_1Bit M03(.in0(in0[2]),.in1(in1[2]) ,.sl(sl),.out(out[2]));
	Mux_1Bit M04(.in0(in0[3]),.in1(in1[3]) ,.sl(sl),.out(out[3]));
	Mux_1Bit M05(.in0(in0[4]),.in1(in1[4]) ,.sl(sl),.out(out[4]));
	Mux_1Bit M06(.in0(in0[5]),.in1(in1[5]) ,.sl(sl),.out(out[5]));
	Mux_1Bit M07(.in0(in0[6]),.in1(in1[6]) ,.sl(sl),.out(out[6]));
	Mux_1Bit M08(.in0(in0[7]),.in1(in1[7]) ,.sl(sl),.out(out[7]));

endmodule


module Mux_24Bit(input [23:0] in0,input [23:0] in1 ,input sl,output [23:0] out);

	Mux_8Bit M01(.in0(in0[7:0]),.in1(in1[7:0]) ,.sl(sl),.out(out[7:0]));
	Mux_8Bit M02(.in0(in0[15:8]),.in1(in1[15:8]) ,.sl(sl),.out(out[15:8]));
	Mux_8Bit M03(.in0(in0[23:16]),.in1(in1[23:16]) ,.sl(sl),.out(out[23:16]));

endmodule


module Mux_32Bit(input [31:0] in0,input [31:0] in1 ,input sl,output [31:0] out);

	Mux_24Bit M01(.in0(in0[23:0]),.in1(in1[23:0]),.sl(sl),.out(out[23:0]));
	Mux_8Bit M02(.in0(in0[31:24]),.in1(in1[31:24]),.sl(sl),.out(out[31:24]));

endmodule


module Multiplier24bit(input [23:0] a,input [23:0] b,output [47:0]mul);

	assign mul = a*b;
	
endmodule


module Divider24bit(input [47:0] a,input [23:0] b,output [24:0]div);

	wire [47:0] div_temp;
	assign div_temp = a/b;
	assign div = div_temp[24:0];

endmodule



module normalizeMandfindShift
(
	input[23:0] M_result,
	input M_carry,
	input real_oper,
	output reg [22:0] normalized_M,
	output reg [4:0] shift				
);

reg [23:0] M_temp;

always @(*)

begin

	if(M_carry & !real_oper)
	begin
		normalized_M = M_result[23:1] + {22'b0,M_result[0]};
		shift = 5'd0;
	end
	else
	begin
		casex(M_result)
			
			24'b1xxx_xxxx_xxxx_xxxx_xxxx_xxxx:
			
			begin
				normalized_M = M_result[22:0];
				shift = 5'd0;
			end
			
			24'b01xx_xxxx_xxxx_xxxx_xxxx_xxxx:
			
			begin
				M_temp = M_result << 1;
				normalized_M = M_temp[22:0];
				shift = 5'd1;
			end
			
			24'b001x_xxxx_xxxx_xxxx_xxxx_xxxx:
			
			begin
				M_temp = M_result << 2;
				normalized_M = M_temp[22:0];
				shift = 5'd2;
			end			
			
			24'b0001_xxxx_xxxx_xxxx_xxxx_xxxx:
			
			begin
				M_temp = M_result << 3;
				normalized_M = M_temp[22:0];
				shift = 5'd3;
			end			
			
			24'b0000_1xxx_xxxx_xxxx_xxxx_xxxx:
			
			begin
				M_temp = M_result << 4;
				normalized_M = M_temp[22:0];
				shift = 5'd4;
			end			
			
			24'b0000_01xx_xxxx_xxxx_xxxx_xxxx:
			
			begin
				M_temp = M_result << 5;
				normalized_M = M_temp[22:0];
				shift = 5'd5;
			end			
			
			24'b0000_001x_xxxx_xxxx_xxxx_xxxx:
			
			begin
				M_temp = M_result << 6;
				normalized_M = M_temp[22:0];
				shift = 5'd6;
			end			
			
			24'b0000_0001_xxxx_xxxx_xxxx_xxxx:
			
			begin
				M_temp = M_result << 7;
				normalized_M = M_temp[22:0];
				shift = 5'd7;
			end			
			
			24'b0000_0000_1xxx_xxxx_xxxx_xxxx:
			
			begin
				M_temp = M_result << 8;
				normalized_M = M_temp[22:0];
				shift = 5'd8;
			end			
			
			24'b0000_0000_01xx_xxxx_xxxx_xxxx:
			
			begin
				M_temp = M_result << 9;
				normalized_M = M_temp[22:0];
				shift = 5'd9;
			end			
			
			24'b0000_0000_001x_xxxx_xxxx_xxxx:
			
			begin
				M_temp = M_result << 10;
				normalized_M = M_temp[22:0];
				shift = 5'd10;
			end			
			
			24'b0000_0000_0001_xxxx_xxxx_xxxx:
			
			begin
				M_temp = M_result << 11;
				normalized_M = M_temp[22:0];
				shift = 5'd11;
			end			
			
			24'b0000_0000_0000_1xxx_xxxx_xxxx:
			
			begin
				M_temp = M_result << 12;
				normalized_M = M_temp[22:0];
				shift = 5'd12;
			end			
			
			24'b0000_0000_0000_01xx_xxxx_xxxx:
			
			begin
				M_temp = M_result << 13;
				normalized_M = M_temp[22:0];
				shift = 5'd13;
			end			
			
			24'b0000_0000_0000_001x_xxxx_xxxx:
			
			begin
				M_temp = M_result << 14;
				normalized_M = M_temp[22:0];
				shift = 5'd14;
			end			
			
			24'b0000_0000_0000_0001_xxxx_xxxx:
			
			begin
				M_temp = M_result << 15;
				normalized_M = M_temp[22:0];
				shift = 5'd15;
			end			
			
			24'b0000_0000_0000_0000_1xxx_xxxx:
			
			begin
				M_temp = M_result << 16;
				normalized_M = M_temp[22:0];
				shift = 5'd16;
			end			

			24'b0000_0000_0000_0000_01xx_xxxx:

			begin
				M_temp = M_result << 17;
				normalized_M = M_temp[22:0];
				shift = 5'd17;
			end			

			24'b0000_0000_0000_0000_001x_xxxx:

			begin
				M_temp = M_result << 18;
				normalized_M = M_temp[22:0];
				shift = 5'd18;
			end			

			24'b0000_0000_0000_0001_0001_xxxx:

			begin
				M_temp = M_result << 19;
				normalized_M = M_temp[22:0];
				shift = 5'd19;
			end			

			24'b0000_0000_0000_0000_0000_1xxx:

			begin
				M_temp = M_result << 20;
				normalized_M = M_temp[22:0];
				shift = 5'd20;
			end			

			24'b0000_0000_0000_0000_0000_01xx:

			begin
				M_temp = M_result << 21;
				normalized_M = M_temp[22:0];
				shift = 5'd21;
			end			

			24'b0000_0000_0000_0000_0000_001x:

			begin
				M_temp = M_result << 22;
				normalized_M = M_temp[22:0];
				shift = 5'd22;
			end			

			24'b0000_0000_0000_0000_0000_0001:

			begin
				M_temp = M_result << 23;
				normalized_M = M_temp[22:0];
				shift = 5'd23;
			end			
			
			default:
			begin
				normalized_M = 23'b0;
				shift = 5'd0;
			end			
		endcase	
	end
end										

endmodule



module div
(
	input [31:0] n1,
	input [31:0] n2,
    output [31:0] result,
    output Overflow,
    output Underflow,
    output Exception
);

wire is_n2_zero,reduced_and_E1,reduced_and_E2,reduced_or_E1,reduced_or_E2,Overflow1,Underflow1,Overflow2,Underflow2;
wire [24:0] M_div_result;
wire [8:0] temp_E2,temp_E3;
wire [7:0] complemented_E2,complemented_shift_E1,sub_E,bias_added_E,temp_E1,final_E;
wire [4:0] shift_E1,shift_E2;
wire [22:0] normalized_M1,normalized_M2,final_M;

//if all the bits of E1 or E2 are 1 or if n2 is zero ===> Exception 
Reduction_and8bit RA01(.in(n1[30:23]),.out(reduced_and_E1));
Reduction_and8bit RA02(.in(n2[30:23]),.out(reduced_and_E2));
Reduction_nor31bit RN01(.in(n2[30:0]),.out(is_n2_zero));
or(Exception,reduced_and_E1,reduced_and_E2,is_n2_zero);

// final sign of the result
xor(final_sign,n1[31],n2[31]);

// if all the bits of E1 or E2 are 0  ===> Number is denormalized and the implied bit of the corresponding mantissa is to be set as 0.
Reduction_or8bit RO01(.in(n1[30:23]),.out(reduced_or_E1));
Reduction_or8bit RO02(.in(n1[30:23]),.out(reduced_or_E2));

// Subtracting E2 from E1 ===> 2's complement Subtraction
Complement8bit C01(.in(n2[30:23]),.out(complemented_E2));
Adder8bit ADD01(.a(n1[30:23]),.b(complemented_E2),.cin(1'b1),.sum(sub_E),.cout());

// Adding 127(BIAS) to sub_E
Adder8bit ADD02(.a(sub_E),.b(8'b01111111),.cin(1'b0),.sum(bias_added_E),.cout());

// Used to make all mantissae normalized if any of the them is firstly denormalized 
normalizeMandfindShift NM1(.M_result({reduced_or_E1,n1[22:0]}),.M_carry(1'b0),.real_oper(1'b0),.normalized_M(normalized_M1),.shift(shift_E1));
normalizeMandfindShift NM2(.M_result({reduced_or_E2,n2[22:0]}),.M_carry(1'b0),.real_oper(1'b0),.normalized_M(normalized_M2),.shift(shift_E2));

// dividing M1 by M2
Divider24bit DIV01(.a({1'b1,normalized_M1,24'b0}),.b({1'b1,normalized_M2}),.div(M_div_result));

// if M_div_result[24] = 0 ===> take ans from 22 pos to 0 pos, i.e, final_M = M_div_result[22:0]
// if M_div_result[24] = 1 ===> take ans from 23 pos to 1 pos, i.e, final_M = M_div_result[23:1]
Mux_24Bit M02(.in0({1'b0,M_div_result[22:0]}),.in1({1'b0,M_div_result[23:1]}),.sl(M_div_result[24]),.out({temp,final_M}));

// Subtracting shift_E1 from bias_added_E  ===> we get temp_E1
Complement8bit C02(.in({3'b000,shift_E1}),.out(complemented_shift_E1));
Adder8bit ADD03(.a(bias_added_E),.b(complemented_shift_E1),.cin(1'b1),.sum(temp_E1),.cout());

// Adding shift_E2 to temp_E1 ===> we get temp_E2
Adder8bit ADD04(.a(temp_E1),.b({3'b000,shift_E2}),.cin(1'b0),.sum(temp_E2[7:0]),.cout(temp_E2[8]));
and(Overflow1,temp_E1[8],temp_E2[8]);
nor(Underflow1,temp_E1[8],temp_E2[8]);

// Subtracting 1 from temp_E2[7:0] to get temp_E3
Adder8bit ADD05(.a(temp_E2[7:0]),.b(8'b11111111),.cin(1'b0),.sum(temp_E3[7:0]),.cout(temp_E3[8]));
and(Overflow2,temp_E2[8],temp_E3[8]);
nor(Underflow2,temp_E2[8],temp_E3[8]);

// Based on M_div_result[24] bit ===> we will select temp_E2 or temp_E3  
Mux_8Bit M03(.in0(temp_E3[7:0]),.in1(temp_E2[7:0]),.sl(M_div_result[24]),.out(final_E));
Mux_1Bit M04(.in0(Overflow2),.in1(Overflow1),.sl(M_div_result[24]),.out(Overflow));
Mux_1Bit M05(.in0(Underflow2),.in1(Underflow1),.sl(M_div_result[24]),.out(Underflow));

assign result = {final_sign,final_E[7:0],final_M};

endmodule



module mul
( 
	input [31:0] n1,
	input [31:0] n2,
	output [31:0] result,
	output Overflow,
	output Underflow,
	output Exception
);

wire [8:0] sum_E,final_E;
wire [47:0] M_mul_result;
wire [23:0] normalized_M_mul_result;
wire [22:0] final_M;
wire final_sign,reduced_and_E1,reduced_and_E2,reduced_or_E1,reduced_or_E2,carry_E;

// Checking whether all the bits of E1, E2 are 1 ==> Then the number will be either infinity or NAN ( i.e. an Exception ) 
Reduction_and8bit RA01(.in(n1[30:23]),.out(reduced_and_E1));
Reduction_and8bit RA02(.in(n2[30:23]),.out(reduced_and_E2));

// If any of E1 or E2 has all btis 1 then we have an Exception( high ) 
or(Exception,reduced_and_E1,reduced_and_E2);

// final sign of the result
xor(final_sign,n1[31],n2[31]);

// if all the bits of E1 or E2 are 0  ===> Number is denormalized and implied bit of the corresponding mantissa is set as 0.
Reduction_or8bit RO01(.in(n1[30:23]),.out(reduced_or_E1));
Reduction_or8bit RO02(.in(n1[30:23]),.out(reduced_or_E2));

// Multiplying M1 and M2 ( here we have firstly concatenate the implied bit with the corresponding mantissa )
Multiplier24bit MUL01(.a({reduced_or_E1,n1[22:0]}),.b({reduced_or_E2,n2[22:0]}),.mul(M_mul_result));

// MSB of the product is used as select line
// finding the rounding bit ( finally we will or with the LSB of the final product to include rounding )
// if M_mul_result[47] is 1 ===> product is normalized and we will round off the last 24 bits else last 23 bits
Reduction_or24bit RO03(.in({1'b0,M_mul_result[22:0]}),.out(mul_round1));
Reduction_or24bit RO04(.in(M_mul_result[23:0]),.out(mul_round2));
Mux_1Bit M01(.in0(mul_round1),.in1(mul_round2),.sl(M_mul_result[47]),.out(final_product_round));

// normalization
// if MSB of M_mul_result is 1 ===> product is already normalized and next 23 bits after MSB is taken
// if MSB of M_mul_result is 0 ===> The next bit is always 1, so starting from next to next bit, next 23 bits are taken
// here we do not require to shift any bit
Mux_24Bit M02(.in0({1'b0,M_mul_result[45:23]}),.in1({1'b0,M_mul_result[46:24]}),.sl(M_mul_result[47]),.out(normalized_M_mul_result));
Adder24bit ADD23(.a({1'b0,normalized_M_mul_result[22:0]}),.b({23'b0,final_product_round}),.cin(1'b0),.sum({temp,final_M}),.cout());

// Adding E1 and E2
Adder8bit ADD01(.a(n1[30:23]),.b(n2[30:23]),.cin(1'b0),.sum(sum_E[7:0]),.cout(sum_E[8]));

// Subtracting 127(BIAS) from sum_E = E1 + E2
// if M_mul_result[47] = 1 ===> product is of the form 11.(something) and we need to shift the decimal point to left to make the product normalized and therefore we add 1 to resultant E
// if M_mul_result[47] = 0 ===> product is of the form 01.(something) and the product is already normalized and nothing is added or subtracted to E
Adder9bit ADD02(.a(sum_E),.b(9'b110000001),.cin(M_mul_result[47]),.sum(final_E),.cout(carry_E));

// In 2's complement subtraction : 
// if carry_E = 0 ===> result is negative and it the case of Underflow
// if carry_E = 1 and MSB of sum(final_E) is 8 (that means sum is atleast 256 ) ===> it is the case of Overflow 
not(Underflow,carry_E);
and(Overflow,carry_E,final_E[8]);

assign result = {final_sign,final_E[7:0],final_M};

endmodule



module add_sub
(
    input [31:0] n1,
    input [31:0] n2,
    output [31:0] result,
    input sub,
    output Overflow,
    output Underflow,
    output Exception
);

wire real_oper,real_sign,M_carry;
wire isElLessThanE2,reduced_and_E1,reduced_and_E2,reduced_or_E1,reduced_or_E2;
wire [7:0] temp_exp_diff,One_Added_E,new_E,complemented_temp_exp_diff,exp_diff,E,complemented_E2,complemented_shift_E;
wire [8:0] final_E;
wire [23:0] M1,M2,complemented_M2,complemented_M_result,M_result,M_result2,new_M2;
wire w1,w2,w3,final_sign;
wire [22:0] final_M;
wire[4:0] shift_E;

// If the bits of E1, E2 are 1 ==> Then the number will be either infinity or NAN ( i.e. an Exception ) 
Reduction_and8bit RA01(.in(n1[30:23]),.out(reduced_and_E1));
Reduction_and8bit RA02(.in(n2[30:23]),.out(reduced_and_E2));

// If any of E1 or E2 has all btis 1 then we have an Exception( high ) 
or(Exception,reduced_and_E1,reduced_and_E2);

// If all the bits of E1 or E2 are 0  ===> Number is denormalized and implied bit of the corresponding mantissa is set as 0.
Reduction_or8bit RO01(.in(n1[30:23]),.out(reduced_or_E1));
Reduction_or8bit RO02(.in(n1[30:23]),.out(reduced_or_E2));

// Performing E1 - E2
// Before subtraction, complementing E2 bcoz of 2's complement subtraction
Complement8bit C01(.in(n2[30:23]),.out(complemented_E2));
Adder8bit ADD01(.a(n1[30:23]),.b(complemented_E2),.cin(1'b1),.sum(temp_exp_diff),.cout(isE1GreaterThanE2));

// If exp_diff comes out to be -ve ===> Found it's 2's complement
// Original or 2's complement version is selected according to isE1GreaterThanE2
Complement8bit_2s C023(.in(temp_exp_diff),.out(complemented_temp_exp_diff));
Mux_8Bit M011(.in0(complemented_temp_exp_diff),.in1(temp_exp_diff),.sl(isE1GreaterThanE2),.out(exp_diff));

// Selecting the larger exponent
Mux_8Bit M03(.in0(n2[30:23]),.in1(n1[30:23]),.sl(isE1GreaterThanE2),.out(E));

// shifting either mantissa of n1 or n2 a/c to isE1GreaterThanE2
assign M1 = isE1GreaterThanE2? {reduced_or_E1,n1[22:0]}:{reduced_or_E1,n1[22:0]} >> exp_diff;
assign M2 = isE1GreaterThanE2?{reduced_or_E2,n2[22:0]} >> exp_diff:{reduced_or_E2,n2[22:0]};

// assuming real_oper and real_sign
xor(real_oper,sub,n1[31],n2[31]);
buf(real_sign,n1[31]);

// M2 is added to or subtracted from M1 a/c to real_oper
Complement24bit C02(.in(M2),.out(complemented_M2));
Mux_24Bit M04(.in0(M2),.in1(complemented_M2),.sl(real_oper),.out(new_M2));
Adder24bit ADD02(.a(M1),.b(new_M2),.cin(real_oper),.sum(M_result),.cout(M_carry));

// correction in the sign of the final result
and(w1,~real_sign,real_oper,~M_carry);
and(w2,~real_oper,real_sign);
and(w3,M_carry,real_sign);
or(final_sign,w1,w2,w3);

// 1 is added to E if Addtion is performed b/w mantissae and carry is generated
Adder8bit ADD0212(.a(E),.b(8'd1),.cin(1'b0),.sum(One_Added_E),.cout());
Mux_8Bit M031(.in0(E),.in1(One_Added_E),.sl(M_carry&!real_oper),.out(new_E));

// if M_result is negative then 2's complement of M_result is to be calculated
Complement24bit_2s C03(.in(M_result),.out(complemented_M_result));
Mux_24Bit M05(.in0(M_result),.in1(complemented_M_result),.sl(real_oper&!M_carry),.out(M_result2));

// Normalization step ( See Utils.v )
normalizeMandfindShift NM(.M_result(M_result2),.M_carry(M_carry),.real_oper(real_oper),.normalized_M(final_M),.shift(shift_E));
Complement8bit C04(.in({3'b000,shift_E}),.out(complemented_shift_E));

// finally shift is subtracted from E ( 2's complement subtraction )
Adder8bit ADD03(.a(new_E),.b(complemented_shift_E),.cin(1'b1),.sum(final_E[7:0]),.cout(final_E[8]));

// final ans
assign result = {final_sign,final_E[7:0],final_M};

// if (Carry) final_E[8] = 0 ===> final_E is -ve ( Underflow )
not(Underflow,final_E[8]);

// if All bits of of One_Added_E are 1 ( 255 ) and shift_E are 0 ( 0 ), then final_E is 255 ( Out of bound,i.e, Overflow )  
and(Overflow,&One_Added_E,~|shift_E);

endmodule
