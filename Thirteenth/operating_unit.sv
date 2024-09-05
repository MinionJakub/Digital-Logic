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
               output logic [15:0] out, output logic [9:0] cnt, output logic ready
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
    ready = (state == NORMAL);
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
        0 : begin if (cnt > 0) begin if(register > 0 & !register[15]) register <= 1; else register <= 0; end end
        1 : begin if (cnt > 0) begin register <= 0 - out; newcnt <= cnt; end end
        2 : begin if (cnt > 1) begin register <= out + second; newcnt <= cnt - 1; end end
        3 : begin if (cnt > 1) begin register <= out * second; newcnt <= cnt - 1; end end
        4 : begin if (cnt > 1) begin swap_value <= second; state <= SWAP; end end
        5 : begin state <= LOAD; end
        6 : begin if (cnt > 0) begin register <= second; newcnt <= cnt - 1; end end
        7 : begin if (cnt > 0) begin register <= second; newcnt <= cnt - 1; end end
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

module operating_unit(input clk, nrst, wr, start, 
                      input logic [9:0] addr, input logic [15:0] datain, 
                      output ready, output logic [15:0] out);
  
  logic [15:0] instruction;
  logic [9:0] counter;
  logic [9:0] program_counter;
  logic state;
  logic write,en,push,finish,ready_ar;
  const logic READY = 0, BUSY = 1;

  assign write = ready & !start & wr;

  memory code(1,write,clk,program_counter,addr,datain,instruction);

  always_comb begin 
    finish = (instruction[15] & instruction[14]);
    en = !ready & !finish & ready_ar;
    push = !instruction[15];
  end

  always_ff @(posedge clk or negedge nrst)
  if(!nrst) begin 
    program_counter <= 0;
    state <= READY;
    ready <= 1;
  end else if(ready_ar) begin 
    case(state)
    READY: if(start & ready) begin 
      ready <= 0;
      state <= BUSY;
      program_counter <= 0;
    end
    BUSY: if(finish) begin 
      ready <= 1;
      state <= READY;
    end else if (instruction[15])begin 
      if(instruction[2:0] != 7) program_counter <= program_counter + 1;
      else program_counter <= out[9:0];
    end else program_counter <= program_counter + 1;
    endcase
  end

  arithmetic_unit ar(nrst,clk,push,en,instruction,instruction[2:0],out,counter,ready_ar);

endmodule

module circuit (input clk, nrst, wr, start, 
                      input logic [9:0] addr, input logic [15:0] datain, 
                      output ready, output logic [15:0] out);
  operating_unit proc(clk, nrst, wr, start, 
                      addr,datain, 
                      ready,out);
endmodule