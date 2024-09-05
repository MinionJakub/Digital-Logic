
module circuit(output o, input a,b,c,d,x,y);
  logic v1;
  logic v2;
  assign v1 = (a & !x & !y) | (b & !x & y);
  assign v2 = (c & x & !y) | (d & x & y);
  assign o = v1 | v2;
endmodule