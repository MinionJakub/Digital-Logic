module memory( input logic rd, wr, clk, input logic [7:0] rdaddr, wraddr,
              input logic [7:0] in, output logic [7:0] out
);
  logic [7:0] mem [0:255];
  assign out = rd ? mem[rdaddr] : out;
  always_ff @(posedge clk) if (wr) mem[wraddr] <= in;
endmodule

module state_path(input clk,nrst,start,zeroed,to_write,
to_read,go_right,go_left,stop_right,stop_left,to_end,
output ready, output logic [2:0] state);
const logic [2:0] READY = 0, ZERO = 1, WORK = 2,
RIGHT = 3,LEFT = 4, WRITE = 5,READ = 6;
always_ff @(posedge clk or negedge nrst)
if(!nrst) begin 
  state <= READY;
  ready <= 1;
end else case(state) 
  READY: if(start && ready) begin 
    state <= ZERO;
    ready <= 0;
  end
  ZERO: if(zeroed) state <= WORK;
  WORK: if(to_write) state <= WRITE;
  else if(to_read) state <= READ;
  else if(go_left) state <= LEFT;
  else if(go_right) state <= RIGHT;
  else if(to_end) begin 
    state <= READY;
    ready <= 1;
  end
  READ: if(!to_read) state <= WORK;
  WRITE: if(!to_write) state <= WORK;
  LEFT: if(stop_left) state <= WORK;
  RIGHT: if(stop_right) state <= WORK;
endcase
endmodule

module inc_dec_module(input inc,dec,nrst,clk,output logic [7:0] value);
always_ff @(posedge clk or negedge nrst)
if(!nrst) value <= 0;
else if(inc) value <= value + 1;
else if(dec) value <= value - 1;
endmodule

module transform_function(input in_valid,nrst,start,out_ack, input logic [2:0] state, 
                          input logic [7:0] code,value,in_data,c,head,
output logic zeroed,to_write,to_read,go_right,go_left,stop_right,stop_left,to_end,
write_queue,write_code,inc_head,inc_pc,dec_head,dec_pc,nrst_pc,nrst_head,
inc_c,dec_c,nrst_c,in_ack,out_valid,output logic [7:0] data);
const logic [2:0] READY = 0, ZERO = 1, WORK = 2,
RIGHT = 3,LEFT = 4, WRITE = 5,READ = 6;

const logic [7:0] PLUS = 8'h2b, MINUS = 8'h2d, BRC_L = 8'h5b,
BRC_R = 8'h5d, SHIFT_L = 8'h3c, SHIFT_R = 8'h3e, DOT = 8'h2e,
COMMA = 8'h2c, EOF = 8'h00;

always_comb begin
  inc_c = 0;
  dec_c = 0;
  nrst_c = 1;
  to_end = 0;
  in_ack = 0;
  inc_pc = 0;
  dec_pc = 0;
  zeroed = 0;
  to_read = 0;
  to_read = 0;
  nrst_pc = 1;
  go_left = 0;
  to_write = 0;
  go_right = 0;
  inc_head = 0;
  dec_head = 0;
  nrst_head = 1;
  stop_left = 0;
  out_valid = 0;
  write_code = 0;
  stop_right = 0;
  write_queue = 0;
  data = in_data;
  if(!nrst) begin 
    nrst_pc = 0;
    nrst_head = 0;
  end
  else case(state)
  READY: if(in_valid & !start) begin 
    in_ack = 0;
    inc_pc = 1;
    write_code = 1;
  end else if (start) begin
    nrst_pc = 0;
    nrst_head = 0;
  end
  ZERO : begin 
    data = 0;
    inc_head = 1;
    write_queue = 1;
    zeroed = (head + 1) == 0;
  end
  WORK : begin if(code == PLUS)begin 
    inc_pc = 1;
    write_queue = 1;
    data = value + 1;
  end else if(code == MINUS) begin 
    inc_pc = 1;
    write_queue = 1;
    data = value - 1;
  end else if(code == SHIFT_L) begin 
    inc_pc = 1;
    dec_head = 1;
  end else if(code == SHIFT_R) begin 
    inc_pc = 1;
    inc_head = 1;
  end else if(code == DOT) begin 
    to_write = 1;
    out_valid = 1;
  end else if(code == COMMA) begin 
    in_ack = 1;
    to_read = 1;
  end else if(code == EOF) begin 
    to_end = 1;
    nrst_pc = 0;
    nrst_head = 0;
  end else if(code == BRC_L) begin 
    inc_pc = 1;
    if(value == 0) begin 
      nrst_c = 0;
      go_right = 1;
    end
  end else if(code == BRC_R) begin 
    if(value == 0) inc_pc = 1;
    else begin 
      nrst_c = 0;
      go_left = 1;
      dec_pc = 1;
    end
  end end
  RIGHT: begin 
    inc_pc = 1;
    if(code == BRC_L) inc_c = 1;
    else if(code == BRC_R) begin 
      if(c > 0) dec_c = 1;
      else stop_right = 1;
    end
  end
  LEFT: begin 
    if(code == BRC_R) begin 
      inc_c = 1;
      dec_pc = 1;
    end else if(code == BRC_L) begin 
      if(c > 0) begin 
        dec_c = 1;
        dec_pc = 1;
      end
      else begin 
        inc_pc = 1;
        stop_left = 1;
      end
    end
  end
  WRITE: begin 
    if(!out_ack) begin 
      out_valid = 1;
      to_write = 1;
    end else begin 
      inc_pc = 1;
    end
  end
  READ: begin 
    if(!in_valid) begin 
      to_read = 1;
      in_ack = 1;
    end else begin 
      write_queue = 1;
      inc_pc = 1;
    end
  end
  endcase
end

endmodule

module brainfck_interpreter(input clk, nrst,input logic [7:0] in_data, input in_valid, 
output in_ack, output logic [7:0] out_data, output out_valid, input out_ack,
input start, output ready);

const logic [2:0] READY = 0, ZERO = 1, WORK = 2,
RIGHT = 3,LEFT = 4, WRITE = 5,READ = 6;
  
logic [2:0] state;
logic [7:0] code;
logic [7:0] program_counter, head, value,data,c;
logic zeroed,to_write,to_read,go_right,
go_left,stop_right,stop_left,to_end,
write_queue,write_code,inc_head,
inc_pc,dec_head,dec_pc,
nrst_pc,nrst_head,
inc_c,dec_c,
nrst_c;

  transform_function tf(in_valid,nrst,start,out_ack,state,code,value,in_data,c,head,zeroed,to_write,to_read,
go_right,go_left,stop_right,stop_left,to_end,write_queue,write_code,inc_head,
inc_pc,dec_head,dec_pc,nrst_pc,nrst_head,inc_c,dec_c,nrst_c,in_ack,out_valid,data);
assign out_data = state == WRITE || (state == WORK && code == DOT) ? value : out_data;

memory queue(1,write_queue,clk,head,head,data,value);
memory codem(1,write_code,clk,program_counter,program_counter,data,code);
inc_dec_module pc(inc_pc,dec_pc,nrst_pc,clk,program_counter);
inc_dec_module hc(inc_head,dec_head,nrst_head,clk,head);
inc_dec_module cc(inc_c,dec_c,nrst_c,clk,c);
state_path sp(clk,nrst,start,zeroed,to_write,to_read,go_right,
go_left,stop_right,stop_left,to_end,ready,state);
endmodule 

module circuit(input clk, nrst,input logic [7:0] in_data, input in_valid, 
output in_ack, output logic [7:0] out_data, output out_valid, input out_ack,
input start, output ready);
brainfck_interpreter bri(clk,nrst,in_data,in_valid,in_ack,out_data,out_valid,out_ack,start,ready);
endmodule