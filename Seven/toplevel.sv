//Jakub Chomiczewski

//Kod z wykladu
module tff(output q, nq, 
           input t, clk, nrst);
  logic ns, nr, ns1, nr1, j, k;
  nand n1(ns, clk, j), n2(nr, clk, k),
  n3(q, ns, nq), n4(nq, nr,  q, nrst), n5(ns1,!clk, t, nq), 
  n6(nr1, !clk, t, q), n7(j, ns1, k), n8(k, nr1, j, nrst);
endmodule

/*
* Idea rozwiazania:
* Na początek bierzemy z listy rozwiązanie z listy na układ liczący
* w górę i w dół i rozszerzamy go o kolejny "bit".
* Następnie by otrzymać to co chcemy czyli że mamy krok o 2
* to należy odpowiednio ustawić rejestry. 
* Główna obserwacja jest taka że jeśli mamy step o 2 
* to pierwszy rejestr się nie zmienia. Natomiast drugi
* rejest działa tak jakby był pierwszym rejestrem w liczniku.
* Ten układ realizuje tą ideę. 
*/
module counter(output  [3:0] q,
              input en, clk, nrst, down,step);
  logic [2:0] temp;
  logic [1:0] in;
  assign in[0] = step ? 0 : en;
  tff t1(q[0],,in[0],clk,nrst);
  assign temp[0] = en & (down ? !q[0] : q[0]);
  assign in[1] = step ? en : temp[0]; 
  tff t2(q[1],,in[1],clk,nrst);
  assign temp[1] = in[1] & (down ? !q[1] : q[1]);
  tff t3(q[2],,temp[1],clk,nrst);
  assign temp[2] = temp[1] & (down? !q[2] : q[2]); 
  tff t4(q[3],,temp[2],clk,nrst);
endmodule

/*
* Obcięcie sygnały enable, ustalenie by było jak w specyfikacji 
* oraz dla prosteszego czytania wyniku.
*/
module answear(output [3:0] out,input down,step,nrst,clk);
  counter c(out,1,clk,nrst,down,step);
endmodule