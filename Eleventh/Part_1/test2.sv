module circuit(input clk, nrst,start,input logic [15:0] inx, 
               input logic [7:0] inn,output ready, output logic [15:0] out);
  const logic READY = 1'b1;
  const logic BUSY = 1'b0;
  logic [15:0] value,mult,res;
  logic [7:0] power;
  logic what_mult;
  always_ff @(posedge clk or negedge nrst)
    if(!nrst) begin ready <= READY; end
  	else case(ready)
      READY: if(start) begin 
        ready <= BUSY;
        power <= inn;
        value <= 1;
        mult <= inx;
      end
      BUSY: if(power == 0) begin 
        ready <= READY;
        out <= value;
      end
      else begin 
       if(power[0] == 1) begin 
        power <= {power[7:1],1'b0};
        what_mult <= 1'b1;
      end
      else begin
        power <= {1'b0,power[7:1]};
        what_mult <= 1'b0;
      end
      	res <= what_mult ? value : mult;
      	res <= res * mult;
      	mult <= what_mult ? mult : res;
      	value <= what_mult ? res : value;
      end
    endcase
endmodule