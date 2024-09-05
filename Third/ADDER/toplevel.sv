// Jakub Chomiczewski
// Liczy duży P i G - predykcja przeniesienia miedzy czworkami - miedzy nimi - 
// generuje pare nie calosc 
module make_PG(output P,G, input [3:0] v1,v2);
  assign P = v2[0] && v2[1] && v2[2] && v2[3];
  assign G = v1[0] && v2[1] && v2[2] && v2[3] 
             || v1[1] && v2[2] && v2[3] 
             || v1[2] && v2[3]
             || v1[3];;
endmodule
// Laczy informacje i tworzy LCC dla calego 16 bitowego addera
module PG_16_bit(output [3:0] P,G, output [15:0] v1,v2,input c_0, input [15:0] n1,n2);
  //Liczy p i g na najnizszym poziomie
  assign v1 = n1 & n2;
  assign v2 = n1 | n2;
  make_PG _1(P[0],G[0],v1[3:0],v2[3:0]);
  make_PG _2(P[1],G[1],v1[7:4],v2[7:4]);
  make_PG _3(P[2],G[2],v1[11:8],v2[11:8]);
  make_PG _4(P[3],G[3],v1[15:12],v2[15:12]);
endmodule
//Obliczanie za wczasu wszystkich przeniesień
module make_carry(input [3:0] p,g, input c, output [3:0] carry);
  assign carry[0] = c;
  assign carry[1] = (p[0] && c) || g[0];
  assign carry[2] = (p[0] && p[1] && c) || (p[1] && g[0]) || g[1];
  assign carry[3] = (p[0] && p[1] && p[2] && c) 
                	|| (g[0] && p[1] && p[2]) 
                	|| (g[1] && p[2]) 
                	|| g[2];
endmodule
// Dodaje 4 bity dokladnie - full adder
module s4bit(output [3:0] value, input c_0, input [3:0] num1, num2,g,p);
  wire [2:0]c;
  assign value[0] = c_0 ^ num1 [0] ^ num2[0];
  assign c[0] = (p[0] && c_0) || g[0]; 
  assign value[1] = c[0] ^ num1[1] ^ num2[1];
  assign c[1] = (p[0] && p[1] && c_0) || (p[1] && g[0]) || g[1];
  assign value[2] = c[1] ^ num1[2] ^ num2[2];
  assign c[2] = (p[0] && p[1] && p[2] && c_0) ||(g[0] && p[1] && p[2]) || (g[1] && p[2]) 
                || g[2];
  assign value[3] = c[2] ^ num1[3] ^ num2[3];
endmodule
// Dodaje 16 bitów dokladnie - najpierw produkujac wartosci przeniesienia przy pomocy 
// PG_16_bit a potem odpowiednio oblicza poprawna wartos
module s16bit(output [15:0] value, input c_0, input [15:0] n1, n2);
  wire  [15:0] g0,p0;
  wire 	[3:0] g1,p1;
  PG_16_bit predict(p1,g1,g0,p0,c_0,n1,n2); 
  wire 	[3:0] c;
  make_carry carries(p1,g1,c_0,c);
  s4bit first_q(value[3:0],c[0],n1[3:0],n2[3:0],g0[3:0],p0[3:0]);
  s4bit second_q(value[7:4],c[1],n1[7:4],n2[7:4],g0[7:4],p0[7:4]);
  s4bit third_q(value[11:8],c[2],n1[11:8],n2[11:8],g0[11:8],p0[11:8]);
  s4bit fourth_q(value[15:12],c[3],n1[15:12],n2[15:12],g0[15:12],p0[15:12]);
endmodule
// by ladny output by byl
module circuit(output [15:0] o, input [15:0] a,b);
  s16bit ans(o,0,a,b);
endmodule