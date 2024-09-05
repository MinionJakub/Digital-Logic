/*module full_summator(output carry,value, input a,b,c);
  logic val;
  assign val = a^b;
  assign carry = (a &&b) || (val && c);
  assign value = val ^ c;
endmodule
module summator_without_carry(output value, input a,b,c);
  assign value = a^b^c;
endmodule*/
module or_and_4bit(output [0:3] ands, ors, input [0:3] num1, num2);
  assign ands[0] = num1[0] && num2[0];
  assign ands[1] = num1[1] && num2[1];
  assign ands[2] = num1[2] && num2[2];
  assign ands[3] = num1[3] && num2[3];
  assign ors[0] = num1[0] || num2[0];
  assign ors[1] = num1[1] || num2[1];
  assign ors[2] = num1[2] || num2[2];
  assign ors[3] = num1[3] || num2[3];
endmodule 
module make_PG(output P,G, input [0:3] v1,v2);
  assign P = v1[0] && v1[1] && v1[2] && v1[3];
  assign G = v2[0] && v1[1] && v1[2] && v1[3] 
             || v2[1] && v1[2] && v1[3] 
             || v2[2] && v1[3]
             || v2[3];;
endmodule
module PG_16_bit(output [0:3] P,G, output [0:15] v1,v2,input c_0, input [0:15] n1,n2);
  or_and_4bit q1(v1[0:3],v2[0:3],n1[0:3],n2[0:3]);
  or_and_4bit q2(v1[4:7],v2[4:7],n1[4:7],n2[4:7]);
  or_and_4bit q3(v1[8:11],v2[8:11],n1[8:11],n2[8:11]);
  or_and_4bit q4(v1[12:15],v2[12:15],n1[12:15],n2[12:15]);
  make_PG _1(P[0],G[0],v1[0:3],v2[0:3]);
  make_PG _2(P[1],G[1],v1[4:7],v2[4:7]);
  make_PG _3(P[2],G[2],v1[8:11],v2[8:11]);
  make_PG _4(P[3],G[3],v1[12:15],v2[12:15]);
endmodule
module s4bit(output [0:3] value, input c_0, input [0:3] num1, num2,g,p);
  wire [0:2]c;
  assign value[0] = c_0 ^ num1 [0] ^ num2[0];
  assign c[0] = (p[0] && c_0) || g[0]; 
  assign value[1] = c[0] ^ num1[1] ^ num2[1];
  assign c[1] = (p[0] && p[1] && c_0) || (p[1] && g[0]) || g[1];
  assign value[2] = c[1] ^ num1[2] ^ num2[2];
  assign c[2] = (p[0] && p[1] && p[2] && c_0) ||(g[0] && p[1] && p[2]) || (g[1] && p[2]) 
                || g[2];
  assign value[3] = c[2] ^ num1[3] ^ num2[3];
endmodule
module s16bit(output [0:15] value, input c_0, input [0:15] n1, n2);
  wire  [0:15] g0,p0;
  wire 	[0:3] g1,p1;
  PG_16_bit predict(p1,g1,g0,p0,c_0,n1,n2); 
  wire 	[0:2] c;
  s4bit first_q(value[0:3],c_0,n1[0:3],n2[0:3],g0[0:3],p0[0:3]);
  assign c[0] = (p1[0] && c_0) || g1[0];
  s4bit second_q(value[4:7],c[0],n1[4:7],n2[4:7],g0[4:7],p0[4:7]);
  assign c[1] = (p1[0] && p1[1] && c_0) || (p1[1] && g1[0]) || g1[1];
  s4bit third_q(value[8:11],c[1],n1[8:11],n2[8:11],g0[8:11],p0[8:11]);
  assign c[2] = (p1[0] && p1[1] && p1[2] && c_0) 
                || (g1[0] && p1[1] && p1[2]) 
                || (g1[1] && p1[2]) 
                || g1[2];
  s4bit fourth_q(value[12:15],c[2],n1[12:15],n2[12:15],g0[12:15],p0[12:15]);
endmodule
module circuit(output [0:15] o, input [0:15] a,b);
  s16bit ans(o,0,a,b);
endmodule