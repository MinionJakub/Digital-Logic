//Jakub Chomiczewski

module sort_2_4_bit_num (input [3:0] first,second,output [7:0] result);
  assign result[7:0] = first[3:0] > second[3:0] ? 
                       {first[3:0],second[3:0]} : 
                       {second[3:0],first[3:0]};
endmodule

module ciruit(input [15:0] i, output [15 : 0] o);
  logic [3:0] first,second,third,fourth,sixth,seven;
  // Determinacja kto jest większy i mniejszy w pierszej parze
  sort_2_4_bit_num r1(i[15:12],i[11:8],{first,second});
  // Determinacja kto jest większy i mniejszy w drugiej parze
  sort_2_4_bit_num r2(i[7:4],i[3:0],{third,fourth});
  // Wybór największej z czterech liczb
  sort_2_4_bit_num r3(first,third,{o[15:12],sixth});
  // Wybór najmniejszej z czterech liczb
  sort_2_4_bit_num r4(second,fourth,{seven,o[3:0]});
  // Determinacja porządku na środku
  sort_2_4_bit_num r5(sixth,seven,o[11:4]);
endmodule