
module circuit(output o, input a,b,c,d,x,y);
  logic nx,ny;
  assign nx = !x;
  assign ny = !y;
  assign o = (a & nx & ny) | (b & nx & y) | (c & x & ny) | (d & x & y);
endmodule