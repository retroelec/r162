#include <stdio.h>
#include <string.h>
#include <stdlib.h>


int findChar(char *s, char c) {
   int cnt = 0;
   int i = 0;

   while (s[i] != '\0') {
      if (s[i] == '(') cnt++;
      else if (s[i] == ')') cnt--;
      else if ((s[i] == c) && (cnt == 0)) {
         return i;
      }
      i++;
   }
   return -1;
}


int eval(char *s) {
   int idx;

   if ((idx = findChar(s, '-')) >= 0) {
      int left, right;
      s[idx] = '\0';
      left = eval(s);
      right = eval(s+idx+1);
      return left - right;
   }
   else if ((idx = findChar(s, '+')) >= 0) {
      int left, right;
      s[idx] = '\0';
      left = eval(s);
      right = eval(s+idx+1);
      return left + right;
   }
   else if ((idx = findChar(s, '*')) >= 0) {
      int left, right;
      s[idx] = '\0';
      left = eval(s);
      right = eval(s+idx+1);
      return left * right;
   }
   else if ((idx = findChar(s, '/')) >= 0) {
      int left, right;
      s[idx] = '\0';
      left = eval(s);
      right = eval(s+idx+1);
      return left / right;
   }
   else if ((idx = findChar(s, '%')) >= 0) {
      int left, right;
      s[idx] = '\0';
      left = eval(s);
      right = eval(s+idx+1);
      return left % right;
   }
   else if ((s[0] == '(') && (s[strlen(s)-1] == ')')) {
      s[strlen(s)-1] = '\0';
      return eval(s+1);
   }
   else {
      return atoi(s);
   }
}


int main(int argc, char* argv[])
{
   printf("expr = %s\n", argv[1]);
   printf("val = %d\n", eval(argv[1]));

   return 0;
}
