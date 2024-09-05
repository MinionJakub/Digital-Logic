module memory( input logic rd, wr, clk, input logic [9:0] rdaddr, wraddr,
              input logic [15:0] in, output logic [15:0] out
);
  logic [15:0] mem [0:1023];
  assign out = rd ? mem[rdaddr] : out;
  always_ff @(posedge clk) if (wr) mem[wraddr] <= in;
endmodule

module arithmetic_unit(input nrst, clk, push,en,
               input logic [15:0] d, input logic [2:0] op,
               output logic [15:0] out, output logic [9:0] cnt
);

const logic read = 1;
const logic write = 1;
logic prev_load;
logic [9:0] read_addr,write_addr;
logic [15:0] top,register,data,read_value,second;

memory stos(read,write,clk,read_addr,write_addr,data,read_value);

assign register = prev_load ? read_value : top;
assign out = register;
always_ff @(posedge clk or negedge nrst)
if(!nrst) begin 
  top <= 0;
  cnt <= 0;
  prev_load <= 0;
  read_addr <= 0;
  write_addr <= 0;
end else if(push & en) begin 
  prev_load <= 0;
  data <= second;
  second <= top;
  top <= d;
  read_addr <= cnt - 2;
  write_addr <= cnt - 2;
  cnt <= cnt + 1;
end else if (en) begin
  unique case(op)
  0 : begin 
    write_addr <= cnt - 2;
    data <= second;
    if(register[15] || register == 0) top <= 0; else top <= 1;
    prev_load <= 0;
  end
  1 : if(cnt > 0) begin 
    write_addr <= cnt - 2;
    data <= second;
    top <= 0 - register;
    prev_load <= 0;
  end
  2 : if(cnt > 1) begin 
    prev_load <= 0;
    top <= register + second; 
    second <= read_value; 
    read_addr <= cnt - 3;
    write_addr <= cnt - 2;
    data <= read_value;
    cnt <= cnt - 1; 
  end
  3 : if(cnt > 1) begin 
    top <= register * second; 
    second <= read_value; 
    read_addr <= cnt - 3;
    write_addr <= cnt - 2;
    data <= read_value;
    cnt <= cnt - 1; 
    prev_load <= 0;
  end
  4 : if(cnt > 1) begin 
    top <= second; 
    second <= register; 
    prev_load <= 0;
    write_addr <= cnt - 2;
    data <= register;
  end
  5 : if(cnt > 0) begin
    if(register != 0) begin
      prev_load <= 1;
      write_addr <= cnt - 2;
      data <= second; 
      second <= register;
      read_addr <= cnt - 2 - register[9:0];
      cnt <= cnt + 1; 
    end
    else begin 
      prev_load <= 0;
      write_addr <= cnt - 2;
      data <= second;
      second <= register;
      read_addr <= cnt - 2;
      top <= second;
      cnt <= cnt + 1;
    end
  end
  6 : if(cnt > 0) begin 
    prev_load <= 0;
    top <= second; 
    second <= read_value;
    read_addr <= cnt - 3;
    write_addr <= cnt - 2;
    data <= read_value;
    cnt <= cnt - 1; 
  end
  7 : if(cnt > 0) begin 
    prev_load <= 0;
    top <= second; 
    second <= read_value;
    read_addr <= cnt - 3;
    write_addr <= cnt - 2;
    data <= read_value;
    cnt <= cnt - 1; 
  end
  endcase
end else top <= prev_load ? read_value : top;
endmodule

//Do testowania na boku
module circle(input nrst, clk, push,en,
               input logic [15:0] d, input logic [2:0] op,
              output logic [15:0] out, output logic [9:0] cnt);
  arithmetic_unit ar1(nrst,clk,push,en,d,op,out,cnt);
endmodule