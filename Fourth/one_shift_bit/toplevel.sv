// Jakub Chomiczewski
module circuit(input [3:0] i, input l,r, output [3:0] o);
  // Zalozylem ze ma byc logic shift
  wire [3:0] shift_l,shift_r,no_shift;
  wire n_lr;
  nor(n_lr,l,r);
  assign shift_l = {i[2] & l ,i[1] & l,i[0] & l,1'b0};
  assign shift_r = {1'b0, i[3]&r,i[2]&r,i[1] &r};
  assign no_shift = {i[3] & n_lr,i[2] & n_lr,i[1] & n_lr,i[0] & n_lr};
  assign o = shift_l | shift_r | no_shift;
endmodule