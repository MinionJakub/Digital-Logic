module datapath(input clk,nrst,ready, input logic[7:0] in_a, in_b,
                output logic[7:0] num_a, num_b),out;
  logic [7:0] prev_a,prev_b;
  const logic READY = 1'b1;
  const logic BUSY = 1'b0;
  always_comb begin 
    prev_a = num_a;
    prev_b = num_b;
  end
  always_ff @(posedge clk or negedge nrst)
    if(nrst) case (ready)
        READY: begin num_a <= in_a; num_b <= in_b; end
        BUSY: begin 
          if(prev_a == prev_b) begin
            num_a <= prev_a;
            num_b <= prev_b;
            out <= num_a;
          end
          else if(prev_a < prev_b)begin
            num_a <= prev_b;
            num_b <= prev_a;
          end
          else begin 
            num_a <= prev_a - prev_b;
            num_b <= prev_b;
          end
        end
      endcase
endmodule
module ctlpath(input clk, nrst,start,input logic[7:0] in_a, in_b,
             output ready);
  const logic READY = 1'b1;
  const logic BUSY = 1'b0;
  always_ff @(posedge clk or negedge nrst)
  if(!nrst) begin
    ready <= READY;
  end
  else case(ready)
    READY: if(start) begin ready<=BUSY; end
    BUSY: if(in_a == in_b) begin ready <= READY; end
  endcase
endmodule

//Jakub Chomiczewski
module circuit(input clk,nrst,start,input logic [7:0] ina,inb, 
               output ready, output [7:0] out);
  logic [7:0] v1,v2;
  ctlpath c(clk,nrst,start,v1,v2,ready);
  datapath d(clk,nrst,ready,ina,inb,v1,v2,out);
endmodule