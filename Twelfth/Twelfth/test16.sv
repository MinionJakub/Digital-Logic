//Jakub Chomiczewski
module memory(
input rd, wr, clk,
  input [2:0] rdaddr, wraddr,
  input [7:0] in,
  output logic [7:0] out);
  logic [7:0] mem [0:7];
  always_ff @(posedge clk) if (rd) out <= mem[rdaddr];
  always_ff @(posedge clk) if (wr) mem[wraddr] <= in;
endmodule

module state_path(input clk, nrst, start, i_eq_7,j_eq_7,i_eq_j,c_l_m,
                  output logic ready, output logic [2:0] state);
  const logic [2:0] READY = 1, OUTER = 2, INNER = 3,ENDIN = 4 ,SWAP = 5;
  always_ff @(posedge clk or negedge nrst)
    if(!nrst) begin 
      state <= READY;
      ready <= 1;
    end
  else case(state)
    READY: if(start) begin 
      ready <= 0;
      state <= OUTER;
    end else ready <= 1;
    OUTER: if(i_eq_7) begin 
      ready <= 0;
      state <= READY;
    end
    else state <= INNER;
    INNER: if(j_eq_7 && !c_l_m) state <= ENDIN;
    ENDIN: if(!i_eq_j) state <= SWAP;
    else state <= OUTER;
    SWAP: state <= OUTER;
  endcase
endmodule

module data_path(input clk,start,wr,input logic [2:0] addr,
                 state, input logic [7:0] datain, output logic [7:0] dataout,
                output logic i_eq_7,j_eq_7,i_eq_j,c_l_m);
  const logic [2:0] READY = 1, OUTER = 2, INNER = 3,ENDIN = 4 ,SWAP = 5;
  logic [2:0] read_addr,write_addr,addr_i,addr_j,addr_j_m;
  logic [7:0] m,data,data_out;
  logic read,write,is_ready,is_outer,is_inner,is_endin,is_swap;
  always_comb begin
    is_ready = state == READY;
    is_outer = state == OUTER;
    is_inner = state == INNER;
    is_endin = state == ENDIN;
    is_swap = state == SWAP;
    i_eq_7 = addr_i == 7;
    j_eq_7 = addr_j == 7;
    i_eq_j = addr_i == addr_j_m;
    c_l_m = data_out < m;
    read_addr = is_ready && !wr ? addr : 
                is_ready && start ? 0 : 
                is_outer && !i_eq_7 ? addr_i + 1 :
                is_inner && !j_eq_7 ? addr_j + 1 :
                is_inner && j_eq_7 ? addr_i :
                is_endin && i_eq_j ? addr_i + 1 :
                is_swap ? addr_i + 1 : 0;
    write_addr = is_ready && wr ? addr :
                 is_endin && !i_eq_j ? addr_j_m :
                 is_swap ? addr_i : 0;
    read = is_ready && !wr || is_ready && start || is_outer && !i_eq_7 
      		|| is_inner || is_endin && i_eq_j || is_swap;
    write = is_ready && wr || is_endin && !i_eq_j || is_swap;
    data = is_ready && wr ? datain :
           is_endin && !i_eq_j ? data_out :
           is_swap ? m : 0;
  end
  always_ff @(posedge clk) begin 
    addr_i <= is_ready && start ? 0 :
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
  assign dataout = state == READY && !wr ? data_out : dataout;
  memory memo(read,write,clk,read_addr,write_addr,data,data_out);
endmodule

module circuit(input clk,nrst,start,wr,input logic [2:0] addr, input logic [7:0] datain,
               output logic [7:0] dataout, output ready);
  logic i_eq_7,i_eq_j,j_eq_7,c_l_m;
  logic [2:0] state;
  state_path sp(clk,nrst,start,i_eq_7,j_eq_7,i_eq_j,c_l_m,ready,state);
  data_path dp(clk,start,wr,addr,state,datain,dataout,i_eq_7,j_eq_7,i_eq_j,c_l_m);
endmodule