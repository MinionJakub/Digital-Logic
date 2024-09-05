//Jakub Chomiczewski

module microwave(input logic clk, nrst,door,start,finish,
               output logic heat,light,bell );

  const logic [2:0] CLOSED = 3'b000,
  					COOK   = 3'b001,
  					PAUSE  = 3'b010,
  					BELL   = 3'b011,
  					OPEN   = 3'b100;
  logic [2:0] state;
  
  always_comb begin
    light = 0;
    heat  = 0;
    bell  = 0;
    unique case(state)
      CLOSED: begin light = 0; heat = 0; bell = 0; end
      COOK:   begin light = 1; heat = 1; bell = 0; end
      PAUSE:  begin light = 1; heat = 0; bell = 0; end
      BELL:   begin light = 0; heat = 0; bell = 1; end
      OPEN:	  begin light = 1; heat = 0; bell = 0; end
    endcase
  end
  
  always_ff @(posedge clk or negedge nrst)
    if(!nrst) state <= CLOSED;
  else unique case(state)
    CLOSED: begin 
      if(door) state <= OPEN;
      else if (start & !door) state <= COOK;
    end
    COOK: begin 
      if(door) state <= PAUSE;
      else if (!door & finish) state <= BELL;
    end
    PAUSE: begin
      if(!door) state <= COOK;
    end
    BELL: begin
      if(door) state <= OPEN;
    end
    OPEN: begin
      if(!door) state <= CLOSED;
    end
  endcase
endmodule