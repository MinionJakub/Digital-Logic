// Write your modules here!


//Memory module z wykladu z jednym portem wejscia i wyjscia
module memory( input logic rd, wr, clk, input logic [9:0] rdaddr, wraddr,
              input logic [15:0] in, output logic [15:0] result
);
  logic [15:0] mem [0:999];
  always_ff @(posedge clk) if (rd) result <= mem[rdaddr];
  always_ff @(posedge clk) if (wr) mem[wraddr] <= in;
endmodule

module circuit(input logic clk, input logic [15:0] data, input logic norst, insert,
               output logic [15 : 0] out1, out2, output logic [9:0] counter);
  logic [15 : 0] first, second;
  logic [9 : 0] newcounter;
  assign out1 = norst ? first : 0;
  assign out2 = norst ? counter > 1 ? second : 0 : 0;
  assign counter = norst ? newcounter : 0;
  memory stos(1,1,clk,counter - 2, counter - 1, first, second);
  always_ff @(posedge clk)
    if(!norst) begin 
      first <= 0;
      newcounter <= 0;
    end
  else if(insert)begin 
    if(counter < 1000) begin 
      first <= data;
      newcounter <= counter + 1;
    end
  end
  
endmodule