// Jakub Chomiczewski
module circuit(output o, input [3:0] i);
  logic carry1,carry2,add1,add2,all_one;
  /* 
    carry1 oraz carry2 służą do stwierdzenia czy jeśli by się dodało odpowiednio dwa pierwsze bity 
    i dwa ostatnie bity to czy byłoby przeniesienie czy nie
  */
  assign carry1 = i[0]&i[1];
  assign carry2 = i[2]&i[3];
  /*
    add1/add2 służy do determinacji czy jest jakikolwiek bit zapalony na pierwszych/ostatnich 
    dwóch bitach czy nie  
  */
  assign add1 = i[0]|i[1];
  assign add2 = i[2]|i[3];
  and(all_one,i[0],i[1],i[2],i[3]);
  /*
    notacja c1 = carry1, c2 = carry2, a1 = add1, a2 = add2
    wyjaśnienie jak działa wynik: 
      - rozpatrzmy najpierw formułę (carry1 | carry2 | (add1 & add2)): 
        - jeśli wszystkie bity są zgaszone to c1,c2,a1,a2 = 0 zatem wartość całego wyrażenia to 0
        - jeśli dokładnie jeden bit jest zapalony to c1 i c2 są nadal zerem, jednakże a1 bądź a2 jest 
          równe 1 ale nie oba zatem któryś z nich jest równy 0 zatem ich and jest równy zero
        - jeśli dokładnie dowolne dwa bity są zapalone to albo c1 albo c2 albo oba a1,a2 są równe 1 zatem wyrażenie daje 1
        - jeśli są 3 zapalone to któreś dwa pierwsze bądź dwa ostatnie są zapalone więc wynik to 1
        - jeśli są wszystkie zapalone to c1,c2,a1,a2 są równe zero zatem wynik wyrażenie to 1
      -Jak widać jedynie czego chcemy się pozbyć to ostatniej możliwość więc "dedektujemy" kiedy zachodzi
       i tworzymy formułę która dla wszystkich innych przyjmie wartość z pierwszego wyrażenia,
       a dla ostatniego zamieni na 0.
  */
  assign o = (carry1 | carry2 | (add1 & add2)) & ~all_one;
endmodule