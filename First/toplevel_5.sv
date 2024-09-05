// Write your modules here!

module choose(output answear,input first,second,which);
  assign answear = (first & !which) | (which & second) ;
endmodule

module circuit(output o, input a,b,c,d,x,y);
  logic v1;
  logic v2;
  choose choose_0(v1,a,b,y);
  choose choose_1(v2,c,d,y);
  choose choose_2(o,v1,v2,x);
endmodule