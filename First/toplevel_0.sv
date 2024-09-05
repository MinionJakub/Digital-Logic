// Write your modules here!

module choose(output answear,input first,second,which);
  logic nx;
  logic v1;
  logic v2;
  not choose_first(nx,which);
  and get_value_first(v1,first,nx);
  and get_value_second(v2,which,second);
  or  get_answear(answear,v1,v2);
endmodule

module circuit(output o, input a,b,c,d,x,y);
  logic v1;
  logic v2;
  choose choose_0(v1,a,b,y);
  choose choose_1(v2,c,d,y);
  choose choose_2(o,v1,v2,x);
endmodule