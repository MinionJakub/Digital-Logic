// Jakub Chomiczewski

/*
Pamiec asynchroniczna RAM z jednym portem zapisu i jednym portem odczytu.
Kod z wykladu. Jak testowalem to dla synchronicznego odczytu dawalo bledna odpowiedz.
*/
module memory( input logic rd, wr, clk, input logic [9:0] rdaddr, wraddr,
              input logic [15:0] in, output logic [15:0] out
);
  logic [15:0] mem [0:1023];
  assign out = rd ? mem[rdaddr] : out;
  always_ff @(posedge clk) if (wr) mem[wraddr] <= in;
endmodule

//Modul arytmetczny na bazie pracowni 10
//Operacje + czas:
//SWAP oraz LOAD trwają 3 cykle
//Reszta operacji trwa 2 cykle?
//Zapis do stosu bedzie co dopiero odpowiednio
//w 4 i 3 cyklu
module arithmetic_unit(input nrst, clk, push,en,
               input logic [15:0] d, input logic [2:0] op,
               output logic [15:0] out, output logic [9:0] cnt
);
  logic [15:0] register,second,swap_value;
  logic [9:0] newcnt;
  logic [1:0] state;
  logic [9:0] addr_read, addr_write;
  logic read_en, write_en;
  const logic [1:0] NORMAL = 0, SWAP = 1, LOAD = 2;
  always_comb begin
    read_en = 1;
    write_en = 1;
    out = nrst ? register : 0;
    cnt = nrst ? newcnt : 0;
    addr_read = cnt - 2;
    addr_write = cnt - 1;
    case(state)
    SWAP: 
      begin
        read_en = 0;
        addr_write = cnt - 2;
      end
    LOAD:
      begin 
        write_en = 0;
        addr_read = (cnt - 2 - register[9:0]);
      end
    endcase
  end

  memory stos(read_en,write_en,clk,addr_read,addr_write,out,second);

  always_ff @(posedge clk or negedge nrst)
    if(!nrst) begin newcnt <= 0; register <= 0; state <= NORMAL; end
  else begin 
    case (state)
    NORMAL:
      if(push & en) begin if (cnt < 1000) begin register <= d; newcnt <= cnt + 1; end end
      else  if(en) unique case(op)
        0 : begin if (cnt > 0) begin if(register > 0) register <= 1; else register <= 0; end end
        1 : begin if (cnt > 0) begin register <= 0 - out; newcnt <= cnt; end end
        2 : begin if (cnt > 1) begin register <= out + second; newcnt <= cnt - 1; end end
        3 : begin if (cnt > 1) begin register <= out * second; newcnt <= cnt - 1; end end
        4 : begin if (cnt > 1) begin swap_value <= second; state <= SWAP; end end
        5 : begin if ({6'b0,cnt} > register) begin state <= LOAD; end end
        6 : begin if (cnt > 0) begin register <= second; newcnt <= cnt -1; end end
        7 : begin if (cnt > 0) begin register <= second; newcnt <= cnt -1; end end
      endcase
    SWAP: 
      begin
        state <= NORMAL;
        register <= swap_value;
      end
    LOAD: 
      begin 
        register <= second;
        newcnt <= cnt + 1;
        state <= NORMAL;
      end
    endcase
  end
  
endmodule

/*

Wazne obserwacje przebieg dla operacji (oprocz 4 i 5):
Zlecenie -> Wykonanie (wynik) -> Zapis
Dla operacji 4 i 5:
Zlecenie -> Zmiana Stanu -> Wykonanie(wynik) -> Zapis
Chain-owanie moze jedynie sie odbyc w trakcie cyklu zapis

*/

//Do testowania na boku
module circle(input nrst, clk, push,en,
               input logic [15:0] d, input logic [2:0] op,
              output logic [15:0] out, output logic [9:0] cnt);
  arithmetic_unit ar1(nrst,clk,push,en,d,op,out,cnt);
endmodule