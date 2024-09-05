// Write your modules here!
module circuit(output o, input a,b,c,d,x,y);
  logic v1,v2,v3,v4,nx,ny;
  not(nx,x);
  not(ny,y);
  and(v1,a,nx,ny);
  and(v2,b,nx,y);
  and(v3,c,x,ny);
  and(v4,d,x,y);
  or(o,v1,v2,v3,v4);
endmodule