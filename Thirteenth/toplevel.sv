//Jakub Chomiczewski


//Moduł pamięci na podstawie wykładu.
module memory( input logic rd, wr, clk, input logic [9:0] rdaddr, wraddr,
              input logic [15:0] in, output logic [15:0] out
);
  logic [15:0] mem [0:1023];
  assign out = rd ? mem[rdaddr] : out;
  always_ff @(posedge clk) if (wr) mem[wraddr] <= in;
endmodule

// Musiałem przerobić moją jednostkę arytmetyczną by supportowała
// jedno cyklowy load i swap poprzednia wymagała użycia dwóch cykli.
module arithmetic_unit (input nrst, clk, push,en,
                input logic [15:0] d, input logic [2:0] op,
                output logic [15:0] out, output logic [9:0] cnt
);
  logic [15:0] second;
  logic [9:0] read_addr,write_addr;
  logic write;

// NAJWIĘKSZY BŁĄD JAKI MIAŁEM, KTÓRY KOSZTOWAŁEM MNIE DWA DNI 
// DEBUGOWANIA if(op == 4 && cnt > 1) ORAZ if(op == 5)
// I BŁĘDNE WYNIKI...
  always_comb begin 
    write = (push & cnt > 0 || op == 4);
    write_addr = cnt - 1;
    read_addr = cnt - 2;
    if(cnt == 0) read_addr = 0;
    if(op == 4 && cnt > 1 && !push) begin read_addr = cnt - 2; write_addr = cnt - 2; end
    if(op == 5 && !push) read_addr = cnt - out[9:0] - 2;
  end

  memory stos(1,write,clk,read_addr,write_addr,out,second);
  

  //Rozbiłem na dwa always_ff bo prościej było debugować
  //Myślałem nawet na daniu ich w dwóch odzielnych modułach
  always_ff @(posedge clk or negedge nrst)
  if (!nrst) cnt <= 0;
  else if (en && push) cnt <= cnt + 1;
  else if (en && cnt > 1 && (op == 2 || op == 3)) cnt <= cnt - 1;
  else if (en && cnt > 0 && (op == 6 || op == 7)) cnt <= cnt - 1;

  always_ff @(posedge clk )
  if(en & push) out <= d;
  else if (en) case(op)
    0 : if(out[15] || out == 0) out <= 0; else out <= 1;
    1 : if(cnt > 0)	out <= 0 - out;
    2 : if(cnt > 1) out <= out + second;
    3 : if(cnt > 1) out <= out * second;
    default : out <= second;
  endcase

endmodule

//Ścieżka do kontrolowania stanu, zrobiłem ten moduł by nie szukać 
//po dużym schemacie innych modułów.
module control_unit(input logic clk, nrst,start, finish, 
input logic [15:0] instruction,out, output ready,
 output logic [9:0] program_counter);
  logic state;
  const logic READY = 0, BUSY = 1;
  always_ff @(posedge clk or negedge nrst)
  if(!nrst) begin 
    program_counter <= 0;
    state <= READY;
    ready <= 1;
  end else begin 
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
endmodule

//Całkiem ładny (z mojej perspektywy) moduł, jeśli chodzi o podział i czytelność
module process_unit(input clk, nrst, wr, start, 
                      input logic [9:0] addr, input logic [15:0] datain, 
                      output ready, output logic [15:0] out);
  
  logic [15:0] instruction;
  logic [9:0] counter;
  logic [9:0] program_counter;

  logic write,en,push,finish;
  assign write = ready & !start & wr;
  memory code(1,write,clk,program_counter,addr,datain,instruction);
  always_comb begin 
    finish = (instruction[15] & instruction[14]);
    en = !ready & !finish;
    push = !instruction[15];
  end
  control_unit cu(clk,nrst,start,finish,instruction,out,ready,program_counter);
  arithmetic_unit ar(nrst,clk,push,en,instruction,instruction[2:0],out,counter);
endmodule

// Łatwiej się patrzy na wejścia i wyjście w czasie debugowania
  module circuit (input clk, nrst, wr, start, 
                        input logic [9:0] addr, input logic [15:0] datain, 
                        output ready, output logic [15:0] out);
    process_unit proc(clk, nrst, wr, start, 
                        addr,datain, 
                        ready,out);
  endmodule
