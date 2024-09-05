//Jakub Chomiczewski
module memory( input logic rd, wr, clk, input logic [7:0] rdaddr, wraddr,
              input logic [7:0] in, output logic [7:0] out
);

  logic [7:0] mem [0:255];
  // initial $readmemh("program.vh",mem);
  assign out = rd ? mem[rdaddr] : out;
  always_ff @(posedge clk) if (wr) mem[wraddr] <= in;
endmodule

module interpreter(input clk, nrst, in_valid,out_ack,start,input logic [7:0] in_data,
output in_ack, out_valid, ready, output logic [7:0] out_data);
const logic [2:0] READY = 0, ZERO = 1, WORK = 2, WRITE = 3, 
READ = 4, RIGHT = 5, LEFT = 6;
const logic [7:0] PLUS = 8'h2b, MINUS = 8'h2d, BRC_L = 8'h5b,
BRC_R = 8'h5d, SHIFT_L = 8'h3c, SHIFT_R = 8'h3e, DOT = 8'h2e,
COMMA = 8'h2c, EOF = 8'h00;
logic [2:0] state;
logic [7:0] program_counter,head,op,value,c,data;
logic we_code,we_tape;
always_comb begin
  out_valid = state == WRITE;
  in_ack = state == READ || in_valid && state == READY && !start;
  we_code = in_valid && state == READY && !start;
  we_tape = (state == WORK && (op == PLUS || op == MINUS)) 
  || state == READ || state == ZERO || state == READY && start;
  data = state == READ ? in_data : 
  state == WORK && op == PLUS ? value + 1 :
  state == WORK && op == MINUS ? value - 1 : 0;
end
memory code(1,we_code,clk,program_counter,program_counter,in_data,op);
memory tape(1,we_tape,clk,head,head,data,value);
always_ff @(posedge clk or negedge nrst)
if(!nrst) begin 
  state <= READY;
  program_counter <= 0;
  head <= 0;
  ready <= 1;
end else case(state)
READY: if (start && ready) begin
  state <= ZERO;
  head <= head + 1;
  program_counter <= 0;
  ready <= 0;
end else if(in_valid) program_counter <= program_counter + 1;
ZERO: if(head == 255) begin 
  state <= WORK;
  head <= 0;
end else begin 
  head <= head + 1;
end
WORK: begin 
  case(op)
  SHIFT_L: begin head <= head - 1; program_counter <= program_counter + 1; end
  SHIFT_R: begin head <= head + 1; program_counter <= program_counter + 1; end
  DOT: state <= WRITE;
  COMMA: state <= READ;
  BRC_L: if(value != 0) program_counter <= program_counter + 1;
  else begin program_counter <= program_counter + 1; state <= RIGHT; c <= 0;end
  BRC_R: if(value != 0) begin program_counter <= program_counter - 1; state <= LEFT; c <= 0;end
  else program_counter <= program_counter + 1;
  EOF: begin program_counter <= 0; head <= 0; state <= READY; ready <= 1; end
  PLUS: program_counter <= program_counter + 1;
  MINUS: program_counter <= program_counter + 1;
  default: begin program_counter <= 0; head <= 0; state <= READY; ready <= 1; end
  endcase
end
WRITE: if(out_ack) begin program_counter <= program_counter + 1; state <= WORK; end
READ: if(in_valid) begin program_counter <= program_counter + 1; state <= WORK; end
RIGHT: begin 
  case(op)
  BRC_L: begin c <= c + 1; program_counter <= program_counter + 1; end
  BRC_R: if(c > 0) begin c <= c - 1; program_counter <= program_counter + 1; end
  else  begin program_counter <= program_counter + 1; state <= WORK; end
  default: program_counter <= program_counter + 1;
  endcase
end
LEFT: begin 
  case (op)
    BRC_R: begin c <= c + 1; program_counter <= program_counter - 1; end
    BRC_L: if(c > 0) begin c <= c - 1; program_counter <= program_counter - 1; end
    else begin program_counter <= program_counter + 1; state <= WORK; end
    default: program_counter <= program_counter - 1;
  endcase
end
endcase
  assign out_data = state == WRITE || op == DOT && state == WORK ? value : out_data;
endmodule

module circuit(input clk, nrst, in_valid,out_ack,start,input logic [7:0] in_data,
output in_ack, out_valid, ready, output logic [7:0] out_data);
interpreter brainfk(clk,nrst,in_valid,out_ack,start,in_data,in_ack,out_valid,ready,out_data);
endmodule