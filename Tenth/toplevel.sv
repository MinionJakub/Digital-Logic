// Jakub Chomiczewski

/*
Pamiec asynchroniczna RAM z jednym portem zapisu i jednym portem odczytu.
Kod z wykladu. Jak testowalem to dla synchronicznego odczytu dawalo bledna odpowiedz.
*/
module memory( input logic rd, wr, clk, input logic [9:0] rdaddr, wraddr,
              input logic [15:0] in, output logic [15:0] out
);
  logic [15:0] mem [0:999];
  assign out = rd ? mem[rdaddr] : out;
  always_ff @(posedge clk) if (wr) mem[wraddr] <= in;
endmodule

//Glowny modul
module circuit(input nrst, step, push, 
               input logic [15:0] d, input logic [1:0] op,
               output logic [15:0] out, output logic [9:0] cnt
);
  logic [15:0] register,second;
  logic [9:0] newcnt;
  
  assign out = nrst ? register : 0;
  assign cnt = nrst ? newcnt : 0;

  //Odczyt z pamieci
  memory stos(1,1,step,cnt-2,cnt-1,out,second);
  
  /*
  Bledem orginalnie bylo to ze nie dalem "or negedge nrst".
  Ogolnie staralem sie zadbac o to by jedynie gdy mozemy wykonac operacje
  to zeby stan sie zmienil jesli nie mozemy wykonac to ignorujemy te operacje.
  Zablokowalem rowniez zawijanie sie pamieci.
  */
  always_ff @(posedge step or negedge nrst)
    if(!nrst) begin newcnt <= 0; register <= 0; end
  else begin 
    if(push) begin if (cnt < 1000) begin register <= d; newcnt <= cnt + 1; end end
    else unique case(op)
      1 : begin if (cnt > 0) begin register <= 0 - out; newcnt <= cnt; end end
      2 : begin if (cnt > 1) begin register <= out + second; newcnt <= cnt - 1; end end
      3 : begin if (cnt > 1) begin register <= out * second; newcnt <= cnt - 1; end end
    endcase
  end
  
endmodule
