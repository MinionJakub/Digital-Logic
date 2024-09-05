// Write your modules here!

//Memory module z wykladu z jednym portem wejscia i wyjscia
module memory( input logic rd, wr, clk, input logic [9:0] rdaddr, wraddr,
              input logic [15:0] in, output logic [15:0] out
);
  logic [15:0] mem [0:999];
  always_ff @(posedge clk) if (rd) out <= mem[rdaddr];
  always_ff @(posedge clk) if (wr) mem[wraddr] <= in;
endmodule

module circuit(input nrst, step, push, 
               input logic [15:0] d, input logic [1:0] op,
               output logic [15:0] out, output logic [9:0] cnt
);
  logic [15:0] register, second;
  logic [9:0] newcnt;
  assign out = nrst ? register : 0;
  assign cnt = nrst ? newcnt : 0;
  memory stos(1,1,step,newcnt-2,newcnt-1,register,second);
  always_ff @(posedge step) 
  	if(nrst) begin 
    	if(push) begin 
    		if (newcnt < 1000 ) begin 
      			register <= d; 
      			newcnt <= cnt + 1; 
    		end 
  		end
  	else unique case(op)
    1 : if(cnt > 0) begin  register <= 0 - out; newcnt <= cnt; end
    2 : if(cnt > 1) begin  register <= out + second; newcnt <= cnt - 1; end
    3 : if(cnt > 1) begin  register <= out * second; newcnt <= cnt - 1; end
    endcase
    end
    else begin register <= out; newcnt <= cnt; end
endmodule