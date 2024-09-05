// Jakub Chomiczewski
module funnel_shifter(input [7:0] a,b,input [3:0] n,output [7:0] o);
  /*
  Zalozylem ze nie wolno uzywac shiftow by uzyskac shift.
  Idea rozwiazania najpierw sprawdzamy czy liczba zadana to 8 lub wieksza
  jesli tak to dajemy zawsze a wpp.
  sprawdzamy czy dane n jest wieksz badz rowne 4 jesli tak
  to sprawdzamy czy dane n jest wieksze badz rowne od 2 po odjeciu 4 jesli tak
  to sprawdzamy czy dane n jest wieksz badz rowne od 1 po odjeciu 2 to jesli tak to n = 7
  i odpowiednio przesuwamy wpp to n = 6 i odpowiednio przesuwamy wpp. ... 
  analogicznie dla reszty.
  Uzyskujemy to patrzac na odpowiednie bity.
  */
  assign o = n[3] ? //czy wieksze badz rowne 8
              a // tak 
              : n[2] ? // czy wieksze badz rowne 4  
             (n[1] ?  // czy wieksze badz rowne 6
             (n[0] ? {a[6 : 0], b[7]} : {a[5 : 0], b[7:6]}) : //czy rowne 7
                (n[0] ? {a[4 : 0], b[7:5]} : {a[3 : 0], b[7:4]})) // czy rowne 5
              :(n[1] ?  // czy wieksze badz rowne 2
              (n[0] ? {a[2 : 0], b[7:3]} : {a[1 : 0], b[7:2]}) : // czy rowne 3
                     (n[0] ? {a[0], b[7:1]} : b)); // czy rowne 1

endmodule

module circuit(input [7:0] i, input [3:0] n, input ar,lr,rot,output [7:0] o);
  /* 
  Idea rozwiazania to obliczenie odpowiednio wartosci do funnel shiftera jak
  zadanie sugeruje. Dla rotacji to jest prosto bo wystarczy zduplikowac wejście "i".
  Dla przesunieciu w lewo tez jest prosto poniewaz zawsze to bedzie i oraz 8 zer.
  Natomiast jedynym problematycznym wejsciem jest shift right, z powodu tego 
  ze zalezy czy mamy logiczne czy arytmetyczne przesuniecie. Wlasciwie jedynie gdy
  zamiast 8 zer i "i" jako wejscie do funnel_shiftera jest gdy mamy zapolony bit
  ar i pierwszy pod starszenstwem bit "i". Z tego powodu sprawdzamy to oraz odpowiednio
  ustawiamy wejscie.
  */
  
  wire [3:0] shift;
  wire [7:0] left,right;
  wire [15:0] l,r,m;
  wire one;
  // Lewe przesuniecie
  assign l = {i,8'b0};
  // rotacja
  assign m = {i,i};
  assign shift = lr ? (8 - n) : n;
  //sprawdzenie czy mamy w prawy przesunieciu arytmetycznym czy mamy jedynki w kazdym innym
  // przypadku mamy zera
  assign one = ar & i[7];
  assign r = {{one,one,one,one,one,one,one,one},i};
  // wybranie odpowiedniego przesuniecia
  assign {left,right} = rot ? m : lr ? l : r;
  funnel_shifter value(left,right,shift,o);
endmodule