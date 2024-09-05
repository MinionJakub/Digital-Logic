module mult (input logic [15:0] a,b, output logic [15:0] o);
  assign o = a * b;
endmodule
module circuit(input clk, nrst,start,input logic [15:0] inx, 
               input logic [7:0] inn,output ready, output logic [15:0] out);
  const logic READY = 1'b1;
  const logic BUSY = 1'b0;
  logic [15:0] res,value,mult,exp,what_mult,by_mult;
  logic [7:0] power;
  
  assign out = value;
  always_ff @(posedge clk or negedge nrst)
    if(!nrst) begin ready <= READY; end
  	else case(ready)
      READY: if(start) begin 
        ready <= BUSY;
        value <= 1;
        mult <= 1;
        power <= inn;
        exp <= inx;
      end
      BUSY: if(power == 0) begin 
        ready <= READY; 
        value <= out; 
        mult <= 1;
      end
      else if(power[0] == 1) begin 
        value <= out;
        mult <= exp; 
        power <= {power[7:1],1'b0}; 
      end
      else begin
        power <= {1'b0,power[7:1]};
      end
    endcase
endmodule