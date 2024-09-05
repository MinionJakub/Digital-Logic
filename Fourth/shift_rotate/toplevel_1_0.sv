// Write your modules here!
module funnel_shifter(input [7:0] a,b,input [3:0] n,output [7:0] o);
  /*assign o = n == 0 ? b : 
             n == 1 ? {a[0], b[7:1]} : 
             n == 2 ? {a[1 : 0], b[7:2]} :
             n == 3 ? {a[2 : 0], b[7:3]} :
             n == 4 ? {a[3 : 0], b[7:4]} :
             n == 5 ? {a[4 : 0], b[7:5]} :
             n == 6 ? {a[5 : 0], b[7:6]} :
             n == 7 ? {a[6 : 0], b[7]} :
             a;*/
  assign o = n < 4 ? 
             n < 2 ? (n == 1 ? {a[0], b[7:1]} : b) : (n == 2 ?  {a[1 : 0], b[7:2]} : {a[2 : 0], b[7:3]}) :
             n < 6 ? (n == 4 ? {a[3 : 0], b[7:4]} : {a[4 : 0], b[7:5]}) : 
             n < 8 ? (n == 6 ? {a[5 : 0], b[7:6]} : {a[6 : 0], b[7]}) : a;
endmodule
module circuit(input [7:0] i, input [3:0] n, input ar,lr,rot,output [7:0] o);
  wire [3:0] shift;
  wire [7:0] left,right;
  wire one;
  //assign zeroes = {8'b0};
  //assign ones = {8'b1};
  assign shift = lr ? (8 - n) : n;
  assign one = ar & i[7];
  assign {left,right} = rot ? {i,i} : 
                        lr ? {i,8'b0} :
                        one ? {8'hff,i} : {8'b0, i};
  funnel_shifter value(left,right,shift,o);
endmodule