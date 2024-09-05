
module circuit(output o, input a,b,c,d,x,y);
  logic v1,v2,nx,ny;
  assign nx = !x;
  assign ny = !y;
  assign v1 = (a & nx & ny) | (b & nx & y);
  assign v2 = (c & x & ny) | (d & x & y);
  assign o = v1 | v2;
endmodule