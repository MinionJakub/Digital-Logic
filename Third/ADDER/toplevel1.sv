/*module full_summator(output carry,value, input a,b,c);
  logic val;
  assign val = a^b;
  assign carry = (a &&b) || (val && c);
  assign value = val ^ c;
endmodule
module summator_without_carry(output value, input a,b,c);
  assign value = a^b^c;
endmodule*/
module or_and(output [0:3] ands, ors, input [0:3] num1, num2);
  assign ands[0] = num1[0] && num2[0];
  assign ands[1] = num1[1] && num2[1];
  assign ands[2] = num1[2] && num2[2];
  assign ands[3] = num1[3] && num2[3];
  assign ors[0] = num1[0] || num2[0];
  assign ors[1] = num1[1] || num2[1];
  assign ors[2] = num1[2] || num2[2];
  assign ors[3] = num1[3] || num2[3];
endmodule 
module s4bit(output G,P, output [0:3] value, input c_0, input [0:3] num1, num2);
  wire [0:3] g,p;
  wire [0:2]c;
  assign value[0] = c_0 ^ num1 [0] ^ num2[0];
  or_and g_p(g,p,num1,num2);
  assign c[0] = (p[0] && c_0) || g[0]; 
  assign value[1] = c[0] ^ num1[1] ^ num2[1];
  assign c[1] = (p[0] && p[1] && c_0) || (p[1] && g[0]) || g[1];
  assign value[2] = c[1] ^ num1[2] ^ num2[2];
  assign c[2] = (p[0] && p[1] && p[2] && c_0) ||(g[0] && p[1] && p[2]) || (g[1] && p[2]) 
                || g[2];
  assign value[3] = c[2] ^ num1[3] ^ num2[3];
  /*
  assign carry = (p[0] && p[1] && p[2] && p[3] && c_0) || (g[0] && p[1] && p[2] && p[3])
                 || (g[1] && p[2] && p[3]) || (g[1] && p[2] && p[3]) || (g[2] && p[3]) || g[3];
  */
  assign P = p[0] && p[1] && p[2] && p[3];
  assign G = g[0] && p[1] && p[2] && p[3] || g[1] && p[2] && p[3] || g[2] && p[3] || g[3];
endmodule
module s16bit(output G,P, output [0:15] value, input c_0, input [0:15] n1, n2);
  wire  [0:3] g,p;
  wire 	[0:2] c;
  s4bit first_q(g[0],p[0],value[0:3],c_0,n1[0:3],n2[0:3]);
  assign c[0] = (p[0] && c_0) || g[0];
  s4bit second_q(g[1],p[1],value[4:7],c[0],n1[4:7],n2[4:7]);
  assign c[1] = (p[0] && p[1] && c_0) || (p[1] && g[0]) || g[1];
  s4bit third_q(g[2],p[2],value[8:11],c[1],n1[8:11],n2[8:11]);
  assign c[2] = (p[0] && p[1] && p[2] && c_0) ||(g[0] && p[1] && p[2]) || (g[1] && p[2]) 
                || g[2];
  s4bit fourth_q(g[3],p[3],value[12:15],c[2],n1[12:15],n2[12:15]);
  assign P = p[0] && p[1] && p[2] && p[3];
  assign G = g[0] && p[1] && p[2] && p[3] || g[1] && p[2] && p[3] || g[2] && p[3] || g[3];
endmodule
/*module circuit();
endmodule*/