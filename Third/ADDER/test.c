#include <stdio.h>
#include <inttypes.h>
int main(){
  uint16_t a,b;
  a = 65535;
  b = 10;
  printf("%"PRIu16"\n",a+b);
}