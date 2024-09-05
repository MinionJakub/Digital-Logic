// Write your modules here!



module circuit(input nrst, step, push, 
               input logic [15:0] d, input logic [1:0] op,
               output logic [15:0] out, output logic [9:0] cnt
);
  logic [15:0] register, second;
  logic [9:0] newcnt;
  logic [15:0] stos [0:999];
  assign out = nrst ? register : 0;
  assign cnt = nrst ? newcnt : 0;
  always_ff @(posedge step) begin
  	if(nrst) begin 
    	if(push) begin 
    		if (newcnt < 1000 ) begin 
      			register <= d; 
      			newcnt <= cnt + 1; 
              stos[cnt] <= d;
    		end 
  		end
  	else unique case(op)
      1 : if(cnt > 0) begin  register <= 0 - out; newcnt <= cnt; stos[cnt-1] <= 0 - out;end
      2 : if(cnt > 1) begin  register <= out + stos[cnt-2]; newcnt <= cnt - 1; stos[cnt-2] <=out + second; end
      3 : if(cnt > 1) begin  register <= out * stos[cnt-2]; newcnt <= cnt - 1; stos[cnt-2] <=out * second; end
    endcase
    end
    else begin register <= out; newcnt <= cnt; end
  end
endmodule