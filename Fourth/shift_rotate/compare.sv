module comp_2(input [7:0] v, output o);
  assign o = v[7] | v[6] | v[5] | v[4] | v[3] | v[2] | v[1];
endmodule

module comp_4(input [7:0] v, output o);
  assign o = v[7] | v[6] | v[5] | v[4] | v[3] | v[2];
endmodule


module comp_8(input [7:0] v, output o);
  assign o = v[7] | v[6] | v[5] | v[4] | v[3] ;
endmodule