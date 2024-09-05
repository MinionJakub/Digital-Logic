// Write your modules here!

module memory(
  input rd, wr, clk,
  input[2:0] rdaddr, wraddr,
  input[7:0] in,
  output[7:0] out);
  logic[7:0] mem[0:7];
  always_ff @(posedge clk) if (rd) out <= mem[rdaddr];
  always_ff @(posedge clk) if (wr) mem[wraddr] <= in;
endmodule

module states_control(input clk, nrst, start, ended,
                      output ready, output logic state);
  const logic READY = 1'b1;
  const logic SORTING = 1'b0;
  always_ff @(posedge clk or negedge nrst)
    if(!nrst)begin 
      ready <= 1;
      state <= READY;
    end
  else case(state)
    READY: if(start) begin 
      ready <= 0;
      state <= SORTING;
    end
    SORTING: if(ended) begin
      ready <= 1;
      state <= READY;
    end
  endcase 
endmodule 

module data_control(input clk, nrst, state, wr,start, input logic [2:0] addr,
                    input logic [7:0] datain, output logic [7:0] dataout,
                    output logic ended);
  logic [3:0] addr_write;
  logic [3:0] addr_read;
  logic [2:0] addr_i;
  logic [7:0] elem,data;
  logic read,write;
  const logic READY = 1'b1;
  const logic SORTING = 1'b0;
  memory mem(read,write,clk,addr_read[2:0],addr_write[2:0],state?datain:elem,state?dataout:data);
  always_ff @(posedge clk or negedge nrst)
  if(!nrst) begin 
    addr_read <= 0; 
    addr_write <= 0; 
    read <= 0;
    write <= 0;
  end
  else case(state) 
    READY: if(start) begin 
      addr_read <= 1;
      addr_write <= 0;
      addr_i <= 0;
      read <= 1;
      ended <= 0;
    end
    else begin 
      if(wr) begin 
        write <= 1;
        addr_write <= addr;
        read <= 0;
      end
      else begin 
        read <= 1;
        addr_read <= addr;
        write <= 0;
      end
    end
    SORTING: if(addr_i == 7) begin 
      write <= 0;
      read <= 0;
      addr_read <= 0;
      addr_write <= 0;
      ended <= 1;
    end
    else if (addr_read == 7) begin 

    end
  endcase
endmodule

module circuit(input clk, nrst,start,wr,input logic [2:0] addr,
               input logic [7:0] datain, output logic [7:0] dataout, 
               output ready);
  
endmodule