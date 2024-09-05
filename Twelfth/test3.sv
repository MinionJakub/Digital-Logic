module states_control(input clk, nrst, start, i_eq_7, j_eq_7, i_eq_j,
                      output logic ready, output logic [2:0] state);
  const logic [2:0] READY = 3'b001;
  const logic [2:0] OUTER = 3'b010;
  const logic [2:0] INNER = 3'b011;
  const logic [2:0] ENDIN = 3'b100;
  const logic [2:0] SWAP = 3'b101;
  always_ff @(posedge clk or negedge nrst)
    if(!nrst)begin 
      ready <= 1;
      state <= READY;
    end
  else case(state)
    READY: if(start) begin ready <= 0; state <= OUTER; end
    OUTER: if(i_eq_7) begin ready <= 1; state <= READY; end
    else state <= INNER;
    INNER: if(j_eq_7) state <= ENDIN;
    ENDIN: if(!i_eq_j) state <= SWAP; else state <= OUTER;
    SWAP: state <= OUTER;
  endcase 
endmodule 

module memory(
  input rd, wr, clk,
  input[2:0] rdaddr, wraddr,
  input[7:0] in,
  output[7:0] out);
  logic[7:0] mem[0:7];
  always_ff @(posedge clk) if (rd) out <= mem[rdaddr];
  always_ff @(posedge clk) if (wr) mem[wraddr] <= in;
endmodule


module data_control(input clk, nrst, wr,start, input logic [2:0] state,
                    input logic [2:0] addr, input logic [7:0] datain, 
                    output logic [7:0] dataout,
                    output logic i_eq_7, j_eq_7, i_eq_j);
  const logic [2:0] READY = 3'b001;
  const logic [2:0] OUTER = 3'b010;
  const logic [2:0] INNER = 3'b011;
  const logic [2:0] ENDIN = 3'b100;
  const logic [2:0] SWAP = 3'b101;

  logic [2:0] addr_i;
  logic [2:0] addr_j;
  logic [2:0] addr_j_m;
  logic [7:0] value;
  logic [7:0] value_m;

  logic write,read;
  logic [2:0] read_addr,write_addr;
  logic [7:0] data;

  always_ff @(posedge clk or negedge nrst)
  if(nrst) begin 
    case(state) 
      READY: if(!start) begin
        if(wr) begin 
          write_addr <= addr; 
          write <= 1'b1; 
          read <= 1'b0; 
          data <= datain; 
        end
        else begin 
          read_addr <= addr; 
          read <= 1'b1; 
          write <= 1'b0; 
        end
      end
      else begin 
        addr_i <= 0;
        read_addr <= 0;
        read <= 1;
        write <= 0;
        i_eq_7 <= 0;
        i_eq_j <= 0;
        j_eq_7 <= 0;
      end
      OUTER: if(addr_i == 7) begin 
        i_eq_7 <= 1;
        read <= 0;
        write <= 0;
      end
      else begin 
        addr_j <= addr_i + 1;
        addr_j_m <= addr_i;
        value_m <= value;
        read_addr <= addr_i + 1;
        read <= 1;
      end
      INNER: if(value < value_m) begin 
        value_m <= value;
        addr_j_m <= addr_j;
        read <= 0;
        write <= 0;
      end
      else if(addr_j == 7) begin
        j_eq_7 <= 1;
        read <= 0;
        write <= 0;
      end
      else begin 
        read_addr <= addr_j + 1;
        addr_j <= addr_j + 1;
      end
      ENDIN: if(addr_i == addr_j_m) begin 
        addr_i <= addr_i + 1;
      end
      else begin 
        i_eq_j <= 1; 
      end
      SWAP: begin 
        addr_i <= addr_i + 1;
      end
    endcase
  end
endmodule

module circuit(input clk, nrst,start,wr,input logic [2:0] addr,
               input logic [7:0] datain, output logic [7:0] dataout, 
               output ready);
  logic i_eq_7,i_eq_j,j_eq_7;
  logic [2:0] state;
  states_control calc_state(clk,nrst,start,i_eq_7,j_eq_7,i_eq_j,ready,state);
  data_control data_manipulate(clk,nrst,wr,start,state,addr,datain,dataout,i_eq_7,j_eq_7,i_eq_j);
endmodule