#include <stdlib.h>
#include <stdio.h>

void select_sort(int length, int * tab){
  //outer loop
  for(int i = 0; i < length; i++){
    int elem = tab[i];

    //inner loop
    for(int j= i+1; j < length;j++){
      int val = tab[j];

      //swap
      if(val < elem){
        tab[j] = elem;
        elem = val;
      }
    }

    tab[i] = elem;
  }
}

int main(){
  int tab[7] = {12,123,1,265,12,23,7};
  select_sort(7,tab);
  for(int i = 0; i < 7; i++){
    printf("%d\t",tab[i]);
  }
  printf("\n");
}