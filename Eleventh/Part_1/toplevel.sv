//Jakub Chomiczewski
module circuit(input clk, nrst,start,input logic [15:0] inx, 
               input logic [7:0] inn,output ready, output logic [15:0] out);
  const logic READY = 1'b1;
  const logic BUSY = 1'b0;
  logic [15:0] new_value,powers,result;
  logic [7:0] new_exp, old_exp;
  always_comb begin 
    old_exp = new_exp;
    result = (new_exp[0] ? new_value : powers) * powers; 
  end
  always_ff @(posedge clk or negedge nrst)
  if(!nrst) begin ready <= READY; end
  else case(ready) 
  READY:if(start) begin
    new_value <= 1;
    powers <= inx;
    new_exp <= inn;
    ready <= BUSY;
  end
  BUSY:if (old_exp == 0) begin
    out <= new_value;
    ready <= READY;
  end
  else if (old_exp[0]) begin
    new_exp <= {old_exp[7:1],1'b0};
    new_value <= result;
  end
  else begin 
    new_exp <= {1'b0,old_exp[7:1]};
    powers <= result;
  end
  endcase
endmodule