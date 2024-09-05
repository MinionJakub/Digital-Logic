module memory(
  input rd, wr, clk,
  input[2:0] rdaddr, wraddr,
  input logic [7:0] in,
  output logic[7:0] out);
  logic[7:0] mem[0:7];
  always_ff @(posedge clk) if (rd) out <= mem[rdaddr];
  always_ff @(posedge clk) if (wr) mem[wraddr] <= in;
endmodule

module sorting(input clk,nrst,start, wr,input logic [2:0] addr, input logic [7:0] datain,
output logic [7:0] dataout ,output logic ready);

logic read,write;
const logic [2:0] READY = 1, OUTER_LOOP = 2,INNER_LOOP = 3, SWAP = 4, OUTER_WAIT = 5, INNER_WAIT = 6, TRANSIT = 7;
logic [2:0] state;
logic [2:0] read_addr, write_addr;
logic [2:0] addr_i, addr_j;
logic [7:0] elem,value,data,data_out,new_elem,new_value;

memory mem(read,write,clk,read_addr,write_addr,data,data_out);

assign dataout = state == READY ? data_out : dataout;
assign elem = state == OUTER_LOOP ? data_out : new_elem;
assign value = state == INNER_LOOP ? data_out : new_value;

always_ff @(posedge clk or negedge nrst)
if(!nrst) begin 
  state <= READY;
  ready <= 1;
  read <= 0;
  write <= 0;
end
else case(state)
READY: if(start) begin 
  ready <= 0;
  addr_i <= 0;
  read_addr <= 0;
  read <= 1;
  write <= 0;
  state <= OUTER_LOOP;
end
else if(wr) begin 
  read <= 0;
  write <= 1;
  write_addr <= addr;
  data <= datain;
end
else begin 
  read <= 1;
  write <= 0;
  read_addr <= addr;
end
OUTER_LOOP: if(addr_i == 7) begin
  ready <= 1;
  state <= READY;
  read <= 0;
  write <= 0;
end
else begin 
  state <= INNER_LOOP;
  addr_j <= addr_i+1;
  read <= 1;
  read_addr <= addr_i+1;
  write <= 0;
  new_elem <= elem;
end
INNER_LOOP:if(addr_j == 7) begin 
  state <= OUTER_LOOP;
  read <= 1;
  write <= 1;
  data <= elem;
  read_addr <= addr_i + 1;
  write_addr <= addr_i;
  addr_i <= addr_i + 1;
  new_elem <= elem;
end
else begin 
  if(value < elem) begin 
    state <= SWAP;
    write <= 1;
    read <= 0;
    write_addr <= addr_j;
    data <= elem;
    new_value <= value;
  end
  else begin 
    read <= 1;
    write <= 0;
    read_addr <= addr_j + 1;
    addr_j <= addr_j + 1;
  end
end
SWAP:begin 
  new_elem <= value;
  read <= 1;
  write <= 0; 
  read_addr <= addr_j + 1;
  addr_j <= addr_j + 1;
  state <= INNER_LOOP;
end
endcase

endmodule

