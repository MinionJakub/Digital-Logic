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

  module process_unit(input clk, nrst, wr, start, input logic [9:0] addr, 
                      input logic [15:0] datain, output ready, output logic [15:0] out);
    const logic READY = 1, BUSY = 0;
    logic [9:0] program_counter, write_addr;
    logic [15:0] instruction,data;
    logic en,state,write,push;
    memory code(1,write,clk,program_counter,write_addr,data,instruction);
    arithmetic_unit ar(nrst,clk,push,en,instruction[14:0],instruction[2:0],out,);
    always_comb begin 
      en = 0;
      push = 0;
      if(!ready) begin 
        en = !(instruction[15] & instruction[14]);
        push = !instruction[15];
      end
    end
    always_ff @(posedge clk or negedge nrst)
    if(!nrst) begin 
      program_counter <= 0;
      ready <= 1;
      state <= READY;
      write <= 0;
    end else case(state)
    READY: if(ready) begin 
      if(start) begin 
        ready <= 0;
        state <= BUSY;
        program_counter <= 0;
        write <= 0;
      end else if (wr) begin
        write <= 1; 
        data <= datain;
        write_addr <= addr;
      end else write <= 0;
    end
    BUSY: if(instruction[15]) begin 
      if(instruction[14]) begin 
        ready <= 1;
        state <= READY;
        program_counter <= 0;
      end
      else begin 
        if(instruction[2:0] == 7) program_counter <= out[9:0];
        else program_counter <= program_counter + 1;
      end
    end else program_counter <= program_counter + 1;
    endcase
    
  endmodule


  module circuit (input clk, nrst, wr, start, 
                        input logic [9:0] addr, input logic [15:0] datain, 
                        output ready, output logic [15:0] out);
    process_unit proc(clk, nrst, wr, start, 
                        addr,datain, 
                        ready,out);
  endmodule