// Write your modules here!
module memory(
input rd, wr, clk,
input [5:0] rdaddr, wraddr,
input [3:0] in,
output [3:0] out);
logic [3:0] mem [0:63];
  always_ff @(posedge clk) if (rd) out <= mem[rdaddr];
  always_ff @(posedge clk) if (wr) mem[wraddr] <= in;
endmodule

module state_path(input clk, nrst, start, i_eq_7,j_eq_7,i_eq_j,
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

module data_path(input clk,nrst,start,wr,input logic [2:0] addr,
                 state, logic input [7:0] datain, output logic [7:0] dataout,
                output logic i_eq_7,j_eq_7,i_eq_j);
  const logic [2:0] READY = 1, OUTER = 2, INNER = 3,ENDIN = 4 ,SWAP = 5;
  logic [2:0] read_addr,write_addr,addr_i,addr_j,addr_j_m;
  logic [7:0] c,m,data,data_out;
  logic read,write;
  always_comb begin 
    case(state)
      READY: if(start) begin 
        read = 1;
        write = 0;
        read_addr = 0;
        addr_i = 0;
      end else if (wr) begin 
        read = 0;
        write = 1;
        write_addr = addr;
        data = datain;
      end else begin 
        read = 1;
        write = 0;
        read_addr = addr;
      end
      OUTER: if(addr_i == 7) begin
        read = 0;
        write = 0;
      end else begin 
        read = 1;
        addr_j = addr_i + 1;
        addr_j_m = addr_i;
        read_addr = addr_i + 1;
        read = 1;
        write = 0;
        m = data_out;
      end
      INNER: 
    endcase
  end
endmodule

module circuit();
endmodule