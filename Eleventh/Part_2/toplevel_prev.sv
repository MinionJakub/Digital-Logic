//Jakub Chomiczewski
module circuit(input clk,nrst,start,input logic [7:0] ina,inb, 
               output ready, output [7:0] out);
  const logic READY = 1'b1;
  const logic BUSY = 1'b0;
  logic [7:0] num_a,num_b;
  logic [7:0] prev_a,prev_b;
  
	always_comb
    begin
      prev_a = num_a;
      prev_b = num_b;
      //nie ma potrzeby by out byl w always_ff 
      //wartosc out nie ma sensu gdy ready = 0
      out = num_a;
    end
  
  always_ff @(posedge clk or negedge nrst)
    if(!nrst) begin ready <= READY;end
  else case (ready)
    READY: if(start) begin 
      num_a <= ina; 
      num_b <= inb; 
      ready <= BUSY; 
    end
    BUSY: if(prev_a == prev_b) begin 
      num_a <= prev_a; 
      num_b <= prev_b; 
      ready <= READY; 
    end
    else if(prev_a < prev_b) begin 
      num_a <= prev_b; 
      num_b <= prev_a;
    end
    else begin 
      num_a <= prev_a - prev_b; 
      num_b <= prev_b;
    end
  endcase
endmodule