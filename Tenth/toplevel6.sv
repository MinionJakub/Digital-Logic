// Jakub Chomiczewski

/*
Pamiec asynchroniczna RAM z jednym portem zapisu i jednym portem odczytu.
Kod z wykladu.
*/
module memory( input logic rd, wr, clk, input logic [9:0] rdaddr, wraddr,
              input logic [15:0] in, output logic [15:0] out
);
  logic [15:0] mem [0:999];
  assign out = rd ? mem[rdaddr] : out;
  always_ff @(posedge clk) if (wr) mem[wraddr] <= in;
endmodule

module circuit(input nrst, step, push, 
               input logic [15:0] d, input logic [1:0] op,
               output logic [15:0] out, output logic [9:0] cnt
);
  logic [15:0] register,second;
  logic [9:0] newcnt;
  logic [9:0] read_addr, write_addr;
  
  assign out = nrst ? register : 0;
  assign cnt = nrst ? newcnt : 0;
  
  //Dla czystosci pamieci
  assign read_addr = (cnt > 1) ? cnt - 2 : 10'b0;
  assign write_addr = (cnt > 0) ? cnt -1 : 10'b0;
  memory stos(1,1,step,read_addr,write_addr,out,second);
  
  //Bledem orginalnie bylo to ze nie dalem "or negedge nrst"
  always_ff @(posedge step or negedge nrst)
    if(!nrst) begin newcnt <= 0; register <= 0; end
  else begin 
    if(push) begin if (cnt < 1000) begin register <= d; newcnt <= cnt + 1; end end
    else unique case(op)
      0 : begin register <= out; newcnt <= cnt; end
      1 : begin if (cnt > 0) begin register <= 0 - out; newcnt <= cnt; end end
      2 : begin if (cnt > 1) begin register <= out + second; newcnt <= cnt - 1; end end
      3 : begin if (cnt > 1) begin register <= out * second; newcnt <= cnt - 1; end end
    endcase
  end
  
endmodule