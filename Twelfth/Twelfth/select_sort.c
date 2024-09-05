#include <stdio.h>
#include <stdlib.h>

void sort(int length, int * tab){
  for(int i = 0; i < length; i++){
    int value = tab[i];
    for(int j = i+1; j < length; j++){
      if(tab[j] < value){
        int pom = tab[j];
        tab[j] = value;
        value = pom;
      }
    }
    tab[i] = value;
  }
}

void select_sort(int length, int * tab){
  for(int i = 0; i < length; i++){
    int min_val = tab[i];
    int min_pos = i;
    for(int j = i + 1; j < length; j++){
      if(min_val > tab[j]){
        min_val = tab[j];
        min_pos = j;
      }
    }
    if(i != min_pos){
      tab[min_pos] = tab[i];
      tab[i] = min_val;
    }
  }
}

void bubble_sort(int length, int * tab){
  for(int i = 0; i < length; i++){
    for(int j = i+1; j < length; j++){
      if(tab[i] > tab[j]){
        int pom = tab[i];
        tab[i] = tab[j];
        tab[j] = pom;
      }
    }
  }
}

int main(){
  int tab [] = {29,161,221,224,226,25,208,15};
  bubble_sort(8,tab);
  for(int i = 0; i < 8; i++) printf("%d\t",tab[i]);
  printf("\n");
}