module memory(
  input rd, wr, clk,
  input[2:0] rdaddr, wraddr,
  input[7:0] in,
  output[7:0] out);
  logic[7:0] mem[0:7];
  always_ff @(posedge clk) if (rd) out <= mem[rdaddr];
  always_ff @(posedge clk) if (wr) mem[wraddr] <= in;
endmodule

module state_path(input logic clk,nrst,start,ended, output logic ready);
  const logic READY = 1;
  const logic SORTING = 0;
  always_ff @(posedge clk or negedge nrst)
  if(!nrst) ready <= READY;
  else case(ready)
    READY: if(start) ready<= SORTING;
    SORTING: if(ended) ready<= READY;
  endcase
endmodule

module data_path(input logic clk, nrst, wr,state,
                 input logic [2:0] addr,
                 input logic [7:0] data_in, 
                 output logic ended,
                 output logic [7:0] data_out);
  
  const logic READY = 1;
  const logic SORTING = 0;
  logic [3:0] read_addr, write_addr,addr_i,addr_j,addr_j_m;
  logic [7:0] read_data, write_data;
  logic read,write;
  
  always_ff @(posedge clk or negedge nrst)
  if(!nrst) begin 
    read <= 0;
    write <= 0;
    read_addr <= 0;
    write_addr <= 0;
    ended <= 0;
    addr_i <= 0;
    addr_j <= 0;
  end
  else case(state)
    READY: if(wr) begin 
      read <= 0;
      write <= 1;
      read_addr <= 0;
      write_addr <= addr;
      write_data <= data;
      ended <= 0;
      addr_i <= 0;
      addr_j <= 0;
    end
    else begin 
      read <= 1;
      write <= 0;
      read_addr = addr;
      write_addr = 0;
      ended = 0;
      addr_i <= 0;
      addr_j <= 0;
    end
    SORTING: if(addr_i < 8) begin 
      if(addr_j  < 8) begin
      end
    end
  endcase
endmodule