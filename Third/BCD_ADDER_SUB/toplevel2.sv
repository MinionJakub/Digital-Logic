// Write your modules here!

module complete_9(input [3:0] BCD ,output [3:0] minusBCD );
  assign minusBCD[3] = !BCD[3] && !BCD[2] && !BCD[1];
  assign minusBCD[2] = BCD[2] ^ BCD[1];
  assign minusBCD[1] = BCD[1];
  assign minusBCD[0] = !BCD[0];
endmodule

module s4bit(output [3:0] value,output c_out, input [3:0] num1, num2,input c_in);
  wire [3:0] g,p;
  wire [2:0]c;
  wire P,G;
  assign value[0] = c_in ^ num1 [0] ^ num2[0];
  assign g = num1 & num2;
  assign p = num1 | num2;
  assign c[0] = (p[0] && c_in) || g[0]; 
  assign value[1] = c[0] ^ num1[1] ^ num2[1];
  assign c[1] = (p[0] && p[1] && c_in) || (p[1] && g[0]) || g[1];
  assign value[2] = c[1] ^ num1[2] ^ num2[2];
  assign c[2] = (p[0] && p[1] && p[2] && c_in) ||(g[0] && p[1] && p[2]) || (g[1] && p[2]) 
                || g[2] ;
  assign value[3] = c[2] ^ num1[3] ^ num2[3];
  assign P = p[0] && p[1] && p[2] && p[3];
  assign G = g[0] && p[1] && p[2] && p[3] || g[1] && p[2] && p[3] || g[2] && p[3] || g[3];
  assign c_out = G | c_in & P;
endmodule

module BCD_digit_adder(output [3:0] digit, output carry, input [3:0] num1, num2, input c_in);
  wire [3:0] pseudo_sum;
  wire carry_ps;
  //dodanie jakby byly 4 bitowe i mialy zakres od 0-f
  s4bit calc(pseudo_sum,carry_ps,num1,num2,c_in);
  // czy nastapilo przeniesieni
  assign carry = carry_ps || pseudo_sum[3] && pseudo_sum[2] || pseudo_sum[3] && pseudo_sum[1];
  // poprawienie
  wire [3:0] add_six;
  assign add_six = {1'b0,carry,carry,1'b0};
  s4bit result(digit,_,pseudo_sum,add_six,0);
endmodule

module BCD_two_digit_adder(output [3:0] tens, ones, input [3:0] n11,n12,n21,n22,input c_in);
  wire carry;
  BCD_digit_adder res1(ones,carry,n12,n22,c_in);
  BCD_digit_adder res2(tens,_,n11,n21,carry);
endmodule

module BCD_two_digit_sub(output [3:0] tens, ones, input [3:0] n11,n12,n21,n22);
  wire [3:0] nn21,nn22;
  complete_9 _1(n21,nn21);
  complete_9 _2(n22,nn22);
  BCD_two_digit_adder corect(tens,ones,n11,n12,nn21,nn22,1);
endmodule

module calc_ans(output [7:0] out, input [7:0] n1,n2,input option);
  wire [7:0] add, sub,choose1,choose2;
  wire neg_option;
  assign neg_option = !option;
  assign choose1 = {option,option,option,option,option,option,option,option};
  assign choose2 = {neg_option,neg_option,neg_option,neg_option,neg_option,neg_option,neg_option,neg_option};
  BCD_two_digit_sub subtraction(sub[7:4],sub[3:0],n1[7:4],n1[3:0],n2[7:4],n2[3:0]);
  BCD_two_digit_adder addition(add[7:4],add[3:0],n1[7:4],n1[3:0],n2[7:4],n2[3:0],0);
  assign out = sub & choose1 | add & choose2;
endmodule

module circuit(output [7:0] o, input [7:0] a,b, input sub);
  calc_ans get_ans(o,a,b,sub);
endmodule