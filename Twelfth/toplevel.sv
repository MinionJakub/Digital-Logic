//Jakub Chomiczewski

//Modul pamieci z wykladu
module memory(
input rd, wr, clk,
  input [2:0] rdaddr, wraddr,
  input [7:0] in,
  output logic [7:0] out);
  logic [7:0] mem [0:7];
  always_ff @(posedge clk) if (rd) out <= mem[rdaddr];
  always_ff @(posedge clk) if (wr) mem[wraddr] <= in;
endmodule

/*

Modul ten odpowiada za zmiane stanu automatu oraz za 
sygnal ready.

*/
module state_path(input clk, nrst, start, i_eq_7,j_eq_7,i_eq_j,
                  output logic ready, output logic [2:0] state);
  const logic [2:0] READY = 1, OUTER = 2, INNER = 3,ENDIN = 4 ,SWAP = 5;
  always_ff @(posedge clk or negedge nrst)
    if(!nrst) begin 
      state <= READY;
      ready <= 1;
    end
  else case(state)
    READY: if(start && ready) begin 
      ready <= 0;
      state <= OUTER;
    end
    OUTER: if(i_eq_7) begin 
      ready <= 1;
      state <= READY;
    end
    else state <= INNER;
    INNER: if(j_eq_7) state <= ENDIN;
    ENDIN: if(!i_eq_j) state <= SWAP;
    else state <= OUTER;
    SWAP: state <= OUTER;
  endcase
endmodule

/*

Modul ten odpowiada za sterowanie danymi
wyprowadza on nastepujace sygnaly
[@out] dataout - wynik odczytu
[@out] i_eq_7 - czy doszlismy do i = 7 w czasie sortowania
[@out] j_eq_7 - czy doszlismy do j = 7 w czasie sortowania
[@out] i_eq_j - czy nalezy uzyc swapa czy nie

*/

module data_path(input clk,start,wr,ready,input logic [2:0] addr,
                 state, input logic [7:0] datain, output logic [7:0] dataout,
                output logic i_eq_7,j_eq_7,i_eq_j);
  const logic [2:0] READY = 1, OUTER = 2, INNER = 3,ENDIN = 4 ,SWAP = 5;
  logic [2:0] read_addr,write_addr,addr_i,addr_j,addr_j_m;
  logic [7:0] m,data,data_out;
  logic read,write,is_ready,is_outer,is_inner,is_endin,is_swap,c_l_m,
  set_addr_i_inc ;
  always_comb begin
    
    /*
    Zmienne zaczynajace sie od is_* maja na celu sprawdzenia w ktorym
    stanie jestesmy. 
    */
    is_ready = state == READY;
    is_outer = state == OUTER;
    is_inner = state == INNER;
    is_endin = state == ENDIN;
    is_swap = state == SWAP;

    /*
    Sygnaly wyjsciowe dla maszyny stanu oraz niezbedne do 
    przygotowania nastpenych odczytow i zapisow
    */
    i_eq_7 = addr_i == 7;
    j_eq_7 = addr_j == 7;
    i_eq_j = addr_i == addr_j_m;
    c_l_m = data_out < m;

    /*
    Kiedy ustawic i na i+1
    */
    set_addr_i_inc = is_outer && !i_eq_7 || is_swap || is_endin && i_eq_j;

    /*
    Ustawienie poprawnie adresu odczytu/zapisu w zaleznosci od
    stanu oraz warotsci pomocniczych zgodnie z grafem
    algorytmicznym danym w tresci zadania.
    Jesli nie ma byc odczytu/zapisu to ustawiam go 
    defaultowo na 0.
    */
    read_addr = is_ready && start && ready ? 0 :
                is_ready && !wr ? addr :
                set_addr_i_inc ? addr_i + 1 :
                is_inner ? !j_eq_7 ? addr_j + 1 : addr_i : 0;
    write_addr = is_ready && wr ? addr :
                 is_endin && !i_eq_j ? addr_j_m :
                 is_swap ? addr_i : 0;
    
    /*
    Ustawienie sygnalu czy czytac/zapisywac w danym cyklu zegarowym.
    Moga byc oba naraz zapalone w odpowiednich sytuacjach.
    */
    read = is_ready && !wr || is_ready && start && ready 
      		|| is_inner || set_addr_i_inc;
    write = is_ready && wr || is_endin && !i_eq_j || is_swap;

    /*
    Co zapisac jesli byl sygnal do zapisu wpp
    ustawiane jest na 0.
    */
    data = is_ready && wr ? datain :
           is_endin && !i_eq_j ? data_out :
           is_swap ? m : 0;
  end

  always_ff @(posedge clk) begin 
    /*
    Ustawianie odpowiednio addresow oraz wartosci 
    minimum w zaleznosci od stanu oraz 
    sygnalow pomocniczych zgodnie
    z przedstawionym diagramem.
    */
    addr_i <= is_ready && start && ready ? 0 :
                 is_endin && i_eq_j ? addr_i + 1 :
                 is_swap ? addr_i + 1 : addr_i;
    addr_j <= is_outer ? addr_i + 1 : 
                 is_inner && !j_eq_7 ? addr_j + 1 :
                 addr_j;
    m <= is_outer ? data_out :
        is_inner && c_l_m ? data_out :
        m;
    addr_j_m <= is_outer ? addr_i : 
                   is_inner && c_l_m ? addr_j :
                   addr_j_m;
  end

  //Ustawienie dataout jedynie gdy jestesmy w stanie READY wpp 
  //zostawiamy go jak byl
  assign dataout = state == READY && !wr ? data_out : dataout;

  //Modul do pamieci by zagwarantowac synchroniczny zapis i odczyt.
  //Kod jego byl wziety z wykladu na temat pamieci.
  memory memo(read,write,clk,read_addr,write_addr,data,data_out);
endmodule


//Modul by zgrac i polaczyc odpowiednio ze soba moduly odpwiadajace
//za stan oraz za przeplyw danych.
module circuit(input clk,nrst,start,wr,input logic [2:0] addr, input logic [7:0] datain,
               output logic [7:0] dataout, output ready);
  logic i_eq_7,i_eq_j,j_eq_7;
  logic [2:0] state;
  state_path sp(clk,nrst,start,i_eq_7,j_eq_7,i_eq_j,ready,state);
  data_path dp(clk,start,wr,ready,addr,state,datain,dataout,i_eq_7,j_eq_7,i_eq_j);
endmodule