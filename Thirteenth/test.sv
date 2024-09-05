  module memory( input logic rd, wr, clk, input logic [9:0] rdaddr, wraddr,
                input logic [15:0] in, output logic [15:0] out
  );
    logic [15:0] mem [0:1023];
    assign out = rd ? mem[rdaddr] : out;
    always_ff @(posedge clk) if (wr) mem[wraddr] <= in;
  endmodule

module arithmetic_unit(
  input nrst, clk, push, en,
  input [2:0] op,
  input [15:0] d,
  output logic [15:0] out,
  output logic [9:0] cnt
);
  const logic [2:0] opGreater = 3'b000;
  const logic [2:0] opNeg = 3'b001;
  const logic [2:0] opAdd = 3'b010;
  const logic [2:0] opMul = 3'b011;
  const logic [2:0] opSwap = 3'b100;
  const logic [2:0] opLoad = 3'b101;
  const logic [2:0] opPop = 3'b11?;
  
  
  logic [15:0] second_value;
  logic [9:0] read_addr, write_addr;
  logic swap,wr;

  
  always_comb begin

    swap = 0;
    write_addr = cnt;
    read_addr = cnt - 10'b1;

    if(push && cnt == 0) read_addr = cnt; 
    else begin 
      swap = 0;
      if(op == opLoad) begin read_addr = cnt - out - 10'b1; end
      if(op == opSwap) begin read_addr = cnt - 10'b1; write_addr = cnt - 10'b1; swap = 1; end
    end

  end
  
  assign wr = (push && cnt > 10'b0) || swap;
  memory stos(wr, clk, read_addr, write_addr, out, second_value);  

  always_ff @(posedge clk or negedge nrst) begin
    if (!nrst) begin
      cnt <= 10'b0;
      out <= 16'b0;
    end
    else if (en && push) begin
      cnt <= cnt + 10'b1; 
      out <= d;
    end else if(en) casez(op)
      opGreater: if(out > 16'b0111111111111111 || out == 16'b0) out <= 0; else out <= 1;
      opNeg: out <= -1 * out;
      opAdd: if(cnt > 10'b0) begin out <= out + second_value; cnt <= cnt - 10'b1; end
      opMul: if(cnt > 10'b0) begin out <= out * second_value; cnt <= cnt - 10'b1; end
      opSwap: begin out <= second_value; end
      opLoad: begin out <= second_value; end
      default: if(cnt > 10'b0) begin out <= second_value; cnt <= cnt - 10'b1; end // chciałem dać pop ale nie działało :C     
    endcase

  end
  
endmodule

  module process_unit(input clk, nrst, wr, start, input logic [9:0] addr, 
                      input logic [15:0] datain, output ready, output logic [15:0] out);
    const logic READY = 1, BUSY = 0;
    logic [9:0] program_counter, read_addr, write_addr, data;
    logic [15:0] instruction;
    logic en,state,write;
    memory code(1,write,clk,program_counter,write_addr,data,instruction);
    arithmetic_unit ar(nrst,clk,push,en,instruction[2:0],instruction[14:0],out,);
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
        if(instruction[2:0] == 7) program_counter <= out;
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