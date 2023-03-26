// 6502 assembler, v1.0, c code
// written for the R162 (see
// https://sites.google.com/site/retroelec/retroelecs-electronics-projects/r162)
// -> various restrictions
// to be compiled with the cc65 compiler (see https://www.cc65.org/)
// also compiles on linux (makefile target linux)
//
// Copyright (C) 2012-2020 retroelec <retroelec42@gmail.com>
//
// This program is free software; you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the
// Free Software Foundation; either version 3 of the License, or (at your
// option) any later version.
//
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
// or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License
// for more details.
//
// For the complete text of the GNU General Public License see
// www.gnu.org/licenses/.

// defines for hash table and string pools
#define HTARRSIZE 256
#define HTSTRINGPOOLSIZE HTARRSIZE * 10
#define PASS2POOLADDRSIZE HTARRSIZE
#define PASS2POOLSTRINGSIZE HTSTRINGPOOLSIZE

// define max. string size
#define STRSIZE 80

#include "assemble.h"
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define ushort unsigned short
#define uchar unsigned char

// states for state machine
#define S_START 1
#define S_LCO 2
#define S_LABORCONST 3
#define S_LABEL 4
#define S_CONST1 5
#define S_CONST2 6
#define S_ORG 7
#define S_WAIT 8
#define S_COMMENT 9
#define S_OPCODE 10
#define S_ARGIMM1 11
#define S_ARGIMM2 12
#define S_ARGABS 13
#define S_ARGABSXY 14
#define S_ARGABSX 15
#define S_ARGABSY 16
#define S_ARGINDIR1 17
#define S_ARGINDIR2 18
#define S_ARGINDIR3 19
#define S_ARGINDIRX1 20
#define S_ARGINDIRX2 21
#define S_ARGINDIRX3 22
#define S_ARGINDIRY1 23
#define S_ARGINDIRY2 24
#define S_PSEUDO 25
#define S_PSEUDOBYT1 26
#define S_PSEUDOBYT2 27
#define S_PSEUDODSB1 28
#define S_PSEUDODSB2 29
#define S_PSEUDOASC1 30
#define S_PSEUDOASC2 31
#define S_ERROR 32

// char classes
#define C_WS 1
#define C_NL 2
#define C_AZ 3
#define C_09 4
#define C_HASH 5
#define C_COMMA 6
#define C_X 7
#define C_Y 8
#define C_OPENBRACKET 9
#define C_CLOSEBRACKET 10
#define C_COLON 11
#define C_SEMICOLON 12
#define C_EQ 13
#define C_LOW 14
#define C_HIGH 15
#define C_ORG 16
#define C_DOT 17
#define C_DQUOTE 18
#define C_EXPR 19
#define C_OTHER 20

// types
struct s_pass2pool {
  ushort addr;
  ushort idx;
  uchar num;
};

typedef struct s_pass2pool pass2pool;

struct s_hashtable {
  char *key;
  ushort value;
};

typedef struct s_hashtable hashtable;

struct s_opcode {
  char *opc;
  uchar implicit;
  uchar immediate;
  uchar zeropage;
  uchar zeropageX;
  uchar zeropageY;
  uchar relative;
  uchar absolute;
  uchar absoluteX;
  uchar absoluteY;
  uchar indirect;
  uchar indirectX;
  uchar indirectY;
};

typedef struct s_opcode opcode;

// opcodes
static opcode opcodes[] = {
    {"adc", 255, 105, 101, 117, 0, 0, 109, 125, 121, 0, 97, 113},
    {"and", 255, 41, 37, 53, 0, 0, 45, 61, 57, 0, 33, 49},
    {"asl", 10, 0, 6, 22, 0, 0, 14, 30, 0, 0, 0, 0},
    {"bcc", 255, 0, 0, 0, 0, 144, 0, 0, 0, 0, 0, 0},
    {"bcs", 255, 0, 0, 0, 0, 176, 0, 0, 0, 0, 0, 0},
    {"beq", 255, 0, 0, 0, 0, 240, 0, 0, 0, 0, 0, 0},
    {"bit", 255, 0, 36, 0, 0, 0, 44, 0, 0, 0, 0, 0},
    {"bmi", 255, 0, 0, 0, 0, 48, 0, 0, 0, 0, 0, 0},
    {"bne", 255, 0, 0, 0, 0, 208, 0, 0, 0, 0, 0, 0},
    {"bpl", 255, 0, 0, 0, 0, 16, 0, 0, 0, 0, 0, 0},
    {"brk", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {"bvc", 255, 0, 0, 0, 0, 80, 0, 0, 0, 0, 0, 0},
    {"bvs", 255, 0, 0, 0, 0, 112, 0, 0, 0, 0, 0, 0},
    {"clc", 24, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {"cld", 216, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {"cli", 88, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {"clv", 184, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {"cmp", 255, 201, 197, 213, 0, 0, 205, 221, 217, 0, 193, 209},
    {"cpx", 255, 224, 228, 0, 0, 0, 236, 0, 0, 0, 0, 0},
    {"cpy", 255, 192, 196, 0, 0, 0, 204, 0, 0, 0, 0, 0},
    {"dec", 255, 0, 198, 214, 0, 0, 206, 222, 0, 0, 0, 0},
    {"dex", 202, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {"dey", 136, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {"eor", 255, 73, 69, 85, 0, 0, 77, 93, 89, 0, 65, 81},
    {"inc", 255, 0, 230, 246, 0, 0, 238, 254, 0, 0, 0, 0},
    {"inx", 232, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {"iny", 200, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {"jmp", 255, 0, 0, 0, 0, 0, 76, 0, 0, 108, 0, 0},
    {"jsr", 255, 0, 0, 0, 0, 0, 32, 0, 0, 0, 0, 0},
    {"lda", 255, 169, 165, 181, 0, 0, 173, 189, 185, 0, 161, 177},
    {"ldx", 255, 162, 166, 0, 182, 0, 174, 0, 190, 0, 0, 0},
    {"ldy", 255, 160, 164, 180, 0, 0, 172, 188, 0, 0, 0, 0},
    {"lsr", 74, 0, 70, 86, 0, 0, 78, 94, 0, 0, 0, 0},
    {"nop", 234, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {"ora", 255, 9, 5, 21, 0, 0, 13, 29, 25, 0, 1, 17},
    {"pha", 72, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {"php", 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {"pla", 104, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {"plp", 40, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {"rol", 42, 0, 38, 54, 0, 0, 46, 62, 0, 0, 0, 0},
    {"ror", 106, 0, 102, 118, 0, 0, 110, 126, 0, 0, 0, 0},
    {"rti", 64, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {"rts", 96, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {"sbc", 255, 233, 229, 245, 0, 0, 237, 253, 249, 0, 225, 241},
    {"sec", 56, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {"sed", 248, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {"sei", 120, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {"sta", 255, 0, 133, 149, 0, 0, 141, 157, 153, 0, 129, 145},
    {"stx", 0, 0, 134, 0, 150, 0, 142, 0, 0, 0, 0, 0},
    {"sty", 0, 0, 132, 148, 0, 0, 140, 0, 0, 0, 0, 0},
    {"tax", 170, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {"tay", 168, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {"tsx", 186, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {"txa", 138, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {"txs", 154, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
    {"tya", 152, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
};

// global variables
static uchar *inbuffer;   // inbuffer
static uchar *outbuffer;  // outbuffer
static uchar bufcheck;    // if true, an error is thrown if outbuffer > inbuffer
static uchar modeXY;      // mode for getCharClass
static uchar exprmode;    // mode for getCharClass
static uchar state;       // state for stateMachine
static char lco[STRSIZE]; // label or constant or opcode
static uchar lcoidx;      // index for lco array
static ushort address;    // address in outbuffer
static ushort startaddress;  // start address
static ushort linenum;       // line number of inbuffer
static uchar errEval;        // error flag for eval
static char errstr[STRSIZE]; // error message
static char *lcolow =
    errstr; // label or constant or opcode in lower case letter

// global variables for pass2 pool
static pass2pool pass2poolarr[PASS2POOLADDRSIZE];
static ushort pass2poolarridx;
static char pass2poolstrings[PASS2POOLSTRINGSIZE];
static ushort pass2poolstringsidx;

// global variables for hashtable for constants and labels
static hashtable hasharr[HTARRSIZE];
static ushort numofHTEntries;
static char htstringpool[HTSTRINGPOOLSIZE];
static ushort htstringpoolidx;

// calculate the hash code of a string
// returns the hashcode
uchar getHashcode(char *string) {
  char ch;
  uchar val = 0;
  while ((ch = *string++) != 0) {
    val = (val << 5) + val + ch;
  }
  return val % (HTARRSIZE - 1) + 1;
}

// init. the hash table
void initHashtable() {
  int i;
  for (i = 0; i < HTARRSIZE; i++) {
    hasharr[i].key = NULL;
  }
  htstringpoolidx = 0;
  numofHTEntries = 0;
}

// write a key/value pair to the hashtable
// returns 0 if the key was put in a new entry
// returns 1 if the key was found already in the hashtable
// returns 2 if no free entry was found in the hashtable
ushort writeToHashtable(char *key, ushort value) {
  uchar idx = getHashcode(key);
  char *key1 = hasharr[idx].key;
  if ((key1 != NULL) && (strcmp(key1, key) == 0)) {
    // key already in hashtable
    return 1;
  } else {
    // copy key to string pool
    uchar len = strlen(key);
    strcpy(htstringpool + htstringpoolidx, key);
    key = htstringpool + htstringpoolidx;
    htstringpoolidx += len + 1;
    if (key1 != NULL) {
      // search for a free entry
      int i = 0;
      while (key1 != NULL) {
        i++;
        if (i == HTARRSIZE)
          return 2;
        idx++;
        key1 = hasharr[idx % HTARRSIZE].key;
      }
    }
    // occupy free entry
    hasharr[idx].key = key;
    hasharr[idx].value = value;
    numofHTEntries++;
    return 0;
  }
}

// read the value of the given key from the hashtable
// returns 0 if the key was found in the hashtable
// returns 1 if the key was not found in the hashtable
uchar readFromHashtable(char *key, ushort *value) {
  int i = 0;
  uchar idx = getHashcode(key);
  char *key1 = hasharr[idx].key;
  if (key1 == NULL) {
    return 1;
  }
  while (strcmp(key1, key) != 0) {
    i++;
    if (i == HTARRSIZE) {
      return 1;
    }
    idx++;
    key1 = hasharr[idx % 256].key;
    if (key1 == NULL) {
      return 1;
    }
  }
  // found key
  *value = hasharr[idx].value;
  return 0;
}

// compare function for the bsearch function
int compOpc(const void *opc1, const void *opc2) {
  opcode *opct1 = (opcode *)opc1;
  opcode *opct2 = (opcode *)opc2;
  return strcmp(opct1->opc, opct2->opc);
}

// checks if the given string str is a number
// if yes, put the number in parameter num
// returns 1 if it is a number, 0 otherwise
uchar getNumber(char *str, ushort *num) {
  char ch;
  uchar i = 0;
  if (str[0] == '$') {
    ushort lnum = 0;
    ushort base = 1;
    while (str[i] != '\0') {
      i++;
    }
    while (i > 1) {
      i--;
      ch = tolower(str[i]);
      if (((ch < '0') || (ch > '9')) && ((ch < 'a') || (ch > 'f')))
        return 0;
      if ((ch >= '0') && (ch <= '9')) {
        lnum += (ch - '0') * base;
      } else {
        lnum += (ch - 'a' + 10) * base;
      }
      base *= 16;
    }
    *num = lnum;
    return 1;
  }
  while ((ch = str[i++]) != '\0') {
    if ((ch < '0') || (ch > '9'))
      return 0;
  }
  *num = atoi(str);
  return 1;
}

// checks if the given string is a char
// returns 1 if it is a char, 0 otherwise
uchar isChar(char *string) {
  if ((string[0] == '\'') && (string[2] == '\'') && (string[3] == '\0'))
    return 1;
  else
    return 0;
}

// find the given char in the given string
// returns the index in the string or -1 if the char was not found
int findChar(char *s, char c) {
  ushort cnt = 0;
  ushort i = 0;
  uchar charmode = 0;

  while (s[i] != '\0') {
    if (s[i] == '\'') {
      if (charmode)
        charmode = 0;
      else
        charmode = 1;
    } else if (!charmode) {
      if (s[i] == '(')
        cnt++;
      else if (s[i] == ')')
        cnt--;
      else if ((s[i] == c) && (cnt == 0)) {
        return i;
      }
    }
    i++;
  }
  return -1;
}

// tries to get the value of an expression
// returns the value of the expression
// sets the variable errEval to 1 if the expression could not be evaluated
ushort eval(char *s) {
  short idx;
  if ((idx = findChar(s, '-')) > 0) {
    ushort left, right;
    s[idx] = '\0';
    left = eval(s);
    right = eval(s + idx + 1);
    s[idx] = '-';
    return left - right;
  } else if ((idx = findChar(s, '+')) >= 0) {
    ushort left, right;
    s[idx] = '\0';
    left = eval(s);
    right = eval(s + idx + 1);
    s[idx] = '+';
    return left + right;
  } else if ((idx = findChar(s, '*')) >= 0) {
    ushort left, right;
    s[idx] = '\0';
    left = eval(s);
    right = eval(s + idx + 1);
    s[idx] = '*';
    return left * right;
  } else if ((idx = findChar(s, '/')) >= 0) {
    ushort left, right;
    s[idx] = '\0';
    left = eval(s);
    right = eval(s + idx + 1);
    s[idx] = '/';
    return left / right;
  } else if ((idx = findChar(s, '%')) >= 0) {
    ushort left, right;
    s[idx] = '\0';
    left = eval(s);
    right = eval(s + idx + 1);
    s[idx] = '%';
    return left % right;
  } else if ((idx = findChar(s, '<')) == 0) {
    ushort right;
    right = eval(s + idx + 1);
    return right & 255;
  } else if ((idx = findChar(s, '>')) == 0) {
    ushort right;
    right = eval(s + idx + 1);
    return right / 256;
  } else if ((idx = findChar(s, '-')) == 0) {
    ushort right;
    right = eval(s + idx + 1);
    return -right;
  } else if ((s[0] == '(') && (s[strlen(s) - 1] == ')')) {
    ushort right;
    s[strlen(s) - 1] = '\0';
    right = eval(s + 1);
    s[strlen(s) - 1] = ')';
    return right;
  } else {
    ushort val;
    if (getNumber(s, &val))
      return val;
    else if (isChar(s))
      return (ushort)(s[1]);
    else {
      uchar err = readFromHashtable(s, &val);
      if (!err)
        return val;
      else {
        errEval = 1;
        return 0;
      }
    }
  }
}

// tries to get the value of an expression
// returns 1 if a value was evaluated, 0 otherwise
// returns the evaluated value in the parameter value
uchar evalExpr(char *expr, ushort *value) {
  errEval = 0;
  *value = eval(expr);
  return (!errEval);
}

// get the char class of the given char
// returns the class
uchar getCharClass(char ch) {
  // exprmode = 0 -> start
  // exprmode = 1 -> constant-value, immediate-arg, pseudo-opcode
  // exprmode = 2 -> org-value, absolute-arg
  // exprmode = 3 -> indirect-arg
  if ((exprmode == 1) &&
      (((ch >= 'a') && (ch <= 'z')) || ((ch >= 'A') && (ch <= 'Z')) ||
       (ch == '_') || ((ch >= '0') && (ch <= '9')) || (ch == '(') ||
       (ch == ')') || (ch == '<') || (ch == '>') || (ch == '*') ||
       (ch == '/') || (ch == '%') || (ch == '+') || (ch == '-') ||
       (ch == '\'') || (ch == '$')))
    return C_EXPR;
  else if ((exprmode == 2) &&
           (((ch >= 'a') && (ch <= 'z')) || ((ch >= 'A') && (ch <= 'Z')) ||
            (ch == '_') || ((ch >= '0') && (ch <= '9')) || (ch == '(') ||
            (ch == ')') || (ch == '<') || (ch == '>') || (ch == '*') ||
            (ch == '/') || (ch == '%') || (ch == '+') || (ch == '-') ||
            (ch == '$')))
    return C_EXPR;
  else if ((exprmode == 3) &&
           (((ch >= 'a') && (ch <= 'z')) || ((ch >= 'A') && (ch <= 'Z')) ||
            (ch == '_') || ((ch >= '0') && (ch <= '9')) || (ch == '<') ||
            (ch == '>') || (ch == '*') || (ch == '/') || (ch == '%') ||
            (ch == '+') || (ch == '-') || (ch == '$')))
    return C_EXPR;
  else if ((ch == ' ') || (ch == '\t'))
    return C_WS;
  else if (ch == '\n')
    return C_NL;
  else if ((!modeXY) && (((ch >= 'a') && (ch <= 'z')) ||
                         ((ch >= 'A') && (ch <= 'Z')) || (ch == '_')))
    return C_AZ;
  else if ((ch >= '0') && (ch <= '9'))
    return C_09;
  else if (ch == '#')
    return C_HASH;
  else if (ch == ',')
    return C_COMMA;
  else if (modeXY && ((ch == 'x') || (ch == 'X')))
    return C_X;
  else if (modeXY && ((ch == 'y') || (ch == 'Y')))
    return C_Y;
  else if (ch == '(')
    return C_OPENBRACKET;
  else if (ch == ')')
    return C_CLOSEBRACKET;
  else if (ch == ':')
    return C_COLON;
  else if (ch == ';')
    return C_SEMICOLON;
  else if (ch == '=')
    return C_EQ;
  else if (ch == '<')
    return C_LOW;
  else if (ch == '>')
    return C_HIGH;
  else if (ch == '*')
    return C_ORG;
  else if (ch == '.')
    return C_DOT;
  else if (ch == '"')
    return C_DQUOTE;
  else
    return C_OTHER;
}

// put a string and the number of bytes of the corresponding value
// into the pass2 pool
void putStringToPass2Pool(char *string, uchar numBytes) {
  uchar len = strlen(string);
  pass2poolarr[pass2poolarridx].addr = address - startaddress + 1;
  pass2poolarr[pass2poolarridx].idx = pass2poolstringsidx;
  pass2poolarr[pass2poolarridx++].num = numBytes;
  strcpy(pass2poolstrings + pass2poolstringsidx, string);
  pass2poolstringsidx += len + 1;
}

// util function executed when a constant is found
void actionConstFound() {
  lco[lcoidx] = '\0';
  exprmode = 1;
  state = S_CONST1;
}

// util function executed when a label is found
void actionLabelFound() {
  uchar ret;
  lco[lcoidx] = '\0';
  state = S_LABEL;
  ret = writeToHashtable(lco, address);
  if (ret == 1) {
    snprintf(errstr, STRSIZE, "%s already defined", lco);
    state = S_ERROR;
  } else if (ret == 2) {
    snprintf(errstr, STRSIZE, "no free entry in the hashtable");
    state = S_ERROR;
  }
}

// util function executed when an invalid character is found
void actionErrorInvChar(char ch) {
  snprintf(errstr, STRSIZE, "invalid character %c", ch);
  state = S_ERROR;
}

// util function executed when an invalid address mode is found
void actionErrorInvAddressMode() {
  snprintf(errstr, STRSIZE, "invalid address mode for the command");
  state = S_ERROR;
}

// util function executed when an invalid address mode is found
void actionErrorInvExpression() {
  snprintf(errstr, STRSIZE, "expression cannot be resolved");
  state = S_ERROR;
}

// state machine to do pass 1
// returns 0 if parsing has finished (end of file or error), 1 otherwise
uchar stateMachine() {
  static uchar bytemode;
  static uchar orgflag = 0;
  static char argument[STRSIZE];
  static uchar argumentidx;
  static opcode *actopcode;
  uchar class = 0;
  char ch;
  if (bufcheck && (outbuffer > inbuffer)) {
    snprintf(errstr, STRSIZE, "range check error");
    state = S_ERROR;
  }
  ch = *inbuffer++;
  if (ch == '\0')
    return 0;
  class = getCharClass(ch);
  if (state == S_START) {
    if ((class == C_WS) || (class == C_NL) || (class == C_COLON)) {
    } else if (class == C_AZ) {
      lcoidx = 0;
      lco[lcoidx++] = ch;
      state = S_LCO;
    } else if (class == C_ORG)
      state = S_ORG;
    else if (class == C_SEMICOLON)
      state = S_COMMENT;
    else if (class == C_DOT) {
      argumentidx = 0;
      state = S_PSEUDO;
    } else {
      actionErrorInvChar(ch);
    }
  } else if (state == S_LCO) {
    if ((class == C_AZ) || (class == C_09))
      lco[lcoidx++] = ch;
    else if (class == C_EQ)
      actionConstFound();
    else if ((class == C_WS) || (class == C_NL) || (class == C_COLON)) {
      opcode key;
      int i;
      lco[lcoidx] = '\0';
      for (i = 0; lco[i]; i++) {
        lcolow[i] = tolower(lco[i]);
      }
      lcolow[i] = '\0';
      key.opc = lcolow;
      actopcode = bsearch(&key, opcodes, sizeof(opcodes) / sizeof(opcode),
                          sizeof(opcode), compOpc);
      if (actopcode == NULL) {
        if ((class == C_NL) || (class == C_COLON))
          actionLabelFound();
        else { // class == C_WS
          state = S_LABORCONST;
        }
      } else {
        if ((class == C_NL) || (class == C_COLON)) {
          if (actopcode->implicit != 255) {
            *outbuffer++ = actopcode->implicit;
            address++;
            state = S_START;
          } else {
            snprintf(errstr, STRSIZE, "missing arguments for instruction %s",
                     lco);
            state = S_ERROR;
          }
        } else { // class == C_WS
          state = S_OPCODE;
        }
      }
    }
  } else if (state == S_LABORCONST) {
    if (class == C_WS)
      state = S_LABORCONST;
    else if ((class == C_NL) || (class == C_COLON))
      actionLabelFound();
    else if (class == C_EQ)
      actionConstFound();
    else if (class == C_SEMICOLON) {
      actionLabelFound();
      state = S_COMMENT;
    } else {
      actionErrorInvChar(ch);
    }
  } else if (state == S_LABEL) {
    if (class == C_WS)
      state = S_WAIT;
    else if (class == C_NL)
      state = S_START;
    else if (class == C_SEMICOLON)
      state = S_COMMENT;
    else {
      actionErrorInvChar(ch);
    }
  } else if (state == S_CONST1) {
    if (class == C_EXPR) {
      argumentidx = 0;
      argument[argumentidx++] = ch;
      state = S_CONST2;
    } else if (class == C_WS)
      state = S_CONST1;
    else {
      actionErrorInvChar(ch);
    }
  } else if (state == S_CONST2) {
    if (class == C_EXPR)
      argument[argumentidx++] = ch;
    else if ((class == C_NL) || (class == C_WS) || (class == C_COLON) ||
             (class == C_SEMICOLON)) {
      uchar ret;
      ushort val;
      exprmode = 0;
      argument[argumentidx] = '\0';
      if (evalExpr(argument, &val)) {
        if (class == C_NL)
          state = S_START;
        else if (class == C_COLON)
          state = S_START;
        else if (class == C_WS)
          state = S_WAIT;
        else
          state = S_COMMENT;
        if (orgflag) {
          orgflag = 0;
          address = val;
          startaddress = address;
        } else {
          ret = writeToHashtable(lco, val);
          if (ret == 1) {
            snprintf(errstr, STRSIZE, "%s already defined", lco);
            state = S_ERROR;
          } else if (ret == 2) {
            snprintf(errstr, STRSIZE, "no free entry in the hashtable");
            state = S_ERROR;
          }
        }
      } else {
        actionErrorInvExpression();
      }
    } else {
      actionErrorInvChar(ch);
    }
  } else if (state == S_ORG) {
    if (class == C_WS) {
    } else if (class == C_EQ) {
      orgflag = 1;
      exprmode = 2;
      state = S_CONST1;
    } else {
      actionErrorInvChar(ch);
    }
  } else if (state == S_WAIT) {
    if (class == C_WS) {
    } else if ((class == C_NL) || (class == C_COLON))
      state = S_START;
    else if (class == C_SEMICOLON)
      state = S_COMMENT;
    else {
      actionErrorInvChar(ch);
    }
  } else if (state == S_COMMENT) {
    if (class == C_NL)
      state = S_START;
  } else if (state == S_OPCODE) {
    argumentidx = 0;
    if (class == C_WS) {
    } else if ((class == C_NL) || (class == C_COLON)) {
      if (actopcode->implicit != 255) {
        *outbuffer++ = actopcode->implicit;
        address++;
        state = S_START;
      } else {
        snprintf(errstr, STRSIZE, "missing arguments for instruction %s", lco);
        state = S_ERROR;
      }
    } else if (class == C_HASH) {
      exprmode = 1;
      state = S_ARGIMM1;
    } else if ((class == C_AZ) || (class == C_09)) {
      exprmode = 2;
      argument[argumentidx++] = ch;
      state = S_ARGABS;
    } else if (class == C_OPENBRACKET) {
      exprmode = 3;
      state = S_ARGINDIR1;
    } else {
      actionErrorInvChar(ch);
    }
  } else if (state == S_ARGIMM1) {
    if (class == C_EXPR) {
      argument[argumentidx++] = ch;
      state = S_ARGIMM2;
    } else {
      actionErrorInvChar(ch);
    }
  } else if (state == S_ARGIMM2) {
    if (class == C_EXPR)
      argument[argumentidx++] = ch;
    else if ((class == C_NL) || (class == C_COLON) || (class == C_WS) ||
             (class == C_SEMICOLON)) {
      if (actopcode->immediate) {
        ushort val;
        exprmode = 0;
        argument[argumentidx] = '\0';
        *outbuffer++ = actopcode->immediate;
        if (evalExpr(argument, &val)) {
          val = val % 256;
          *outbuffer++ = val;
        } else {
          outbuffer++;
          putStringToPass2Pool(argument, 1);
        }
        address += 2;
        if (class == C_NL)
          state = S_START;
        else if (class == C_COLON)
          state = S_START;
        else if (class == C_WS)
          state = S_WAIT;
        else
          state = S_COMMENT;
      } else {
        actionErrorInvAddressMode();
      }
    } else {
      actionErrorInvChar(ch);
    }
  } else if (state == S_ARGABS) {
    if (class == C_EXPR)
      argument[argumentidx++] = ch;
    else if ((class == C_NL) || (class == C_COLON) || (class == C_WS) ||
             (class == C_SEMICOLON)) {
      ushort val;
      exprmode = 0;
      argument[argumentidx] = '\0';
      if (evalExpr(argument, &val)) {
        if ((val < 256) && (actopcode->zeropage)) {
          *outbuffer++ = actopcode->zeropage;
          *outbuffer++ = val % 256;
          address += 2;
        } else if (actopcode->absolute) {
          *outbuffer++ = actopcode->absolute;
          *outbuffer++ = val % 256;
          *outbuffer++ = val / 256;
          address += 3;
        } else if (actopcode->relative) {
          *outbuffer++ = actopcode->relative;
          address += 2;
          *outbuffer++ = (val % 256 - address);
        } else {
          actionErrorInvAddressMode();
        }
      } else {
        if ((actopcode->zeropage) || (actopcode->absolute)) {
          *outbuffer++ = actopcode->absolute;
          outbuffer++;
          outbuffer++;
          putStringToPass2Pool(argument, 2);
          address += 3;
        } else if (actopcode->relative) {
          *outbuffer++ = actopcode->relative;
          outbuffer++;
          putStringToPass2Pool(argument, 255);
          address += 2;
        } else {
          actionErrorInvAddressMode();
        }
      }
      if (class == C_NL)
        state = S_START;
      else if (class == C_COLON)
        state = S_START;
      else if (class == C_WS)
        state = S_WAIT;
      else
        state = S_COMMENT;
    } else if (class == C_COMMA) {
      argument[argumentidx] = '\0';
      exprmode = 0;
      state = S_ARGABSXY;
      modeXY = 1;
    } else {
      actionErrorInvChar(ch);
    }
  } else if (state == S_ARGABSXY) {
    modeXY = 0;
    if (class == C_X)
      state = S_ARGABSX;
    else if (class == C_Y)
      state = S_ARGABSY;
    else {
      actionErrorInvChar(ch);
    }
  } else if (state == S_ARGABSX) {
    if ((class == C_NL) || (class == C_COLON) || (class == C_WS) ||
        (class == C_SEMICOLON)) {
      ushort val;
      argument[argumentidx] = '\0';
      if (evalExpr(argument, &val)) {
        if ((val < 256) && (actopcode->zeropageX)) {
          *outbuffer++ = actopcode->zeropageX;
          *outbuffer++ = val % 256;
          address += 2;
        } else if (actopcode->absoluteX) {
          *outbuffer++ = actopcode->absoluteX;
          *outbuffer++ = val % 256;
          *outbuffer++ = val / 256;
          address += 3;
        } else {
          actionErrorInvAddressMode();
        }
      } else {
        *outbuffer++ = actopcode->absoluteX;
        outbuffer++;
        outbuffer++;
        putStringToPass2Pool(argument, 2);
        address += 3;
      }
      if (class == C_NL)
        state = S_START;
      else if (class == C_COLON)
        state = S_START;
      else if (class == C_WS)
        state = S_WAIT;
      else
        state = S_COMMENT;
    } else {
      actionErrorInvChar(ch);
    }
  } else if (state == S_ARGABSY) {
    if ((class == C_NL) || (class == C_COLON) || (class == C_WS) ||
        (class == C_SEMICOLON)) {
      ushort val;
      argument[argumentidx] = '\0';
      if (evalExpr(argument, &val)) {
        if ((val < 256) && (actopcode->zeropageY)) {
          *outbuffer++ = actopcode->zeropageY;
          *outbuffer++ = val % 256;
          address += 2;
        } else if (actopcode->absoluteY) {
          *outbuffer++ = actopcode->absoluteY;
          *outbuffer++ = val % 256;
          *outbuffer++ = val / 256;
          address += 3;
        } else {
          actionErrorInvAddressMode();
        }
      } else {
        *outbuffer++ = actopcode->absoluteY;
        outbuffer++;
        outbuffer++;
        putStringToPass2Pool(argument, 2);
        address += 3;
      }
      if (class == C_NL)
        state = S_START;
      else if (class == C_COLON)
        state = S_START;
      else if (class == C_WS)
        state = S_WAIT;
      else
        state = S_COMMENT;
    } else {
      actionErrorInvChar(ch);
    }
  } else if (state == S_ARGINDIR1) {
    if (class == C_EXPR) {
      argument[argumentidx++] = ch;
      state = S_ARGINDIR2;
    } else {
      actionErrorInvChar(ch);
    }
  } else if (state == S_ARGINDIR2) {
    if (class == C_EXPR)
      argument[argumentidx++] = ch;
    else if (class == C_CLOSEBRACKET) {
      exprmode = 0;
      state = S_ARGINDIR3;
    } else if (class == C_COMMA) {
      modeXY = 1;
      exprmode = 0;
      state = S_ARGINDIRX1;
    } else {
      actionErrorInvChar(ch);
    }
  } else if (state == S_ARGINDIR3) {
    if ((class == C_NL) || (class == C_COLON) || (class == C_WS) ||
        (class == C_SEMICOLON)) {
      if (actopcode->indirect) {
        ushort val;
        argument[argumentidx] = '\0';
        *outbuffer++ = actopcode->indirect;
        if (evalExpr(argument, &val)) {
          *outbuffer++ = val % 256;
          *outbuffer++ = val / 256;
        } else {
          outbuffer++;
          outbuffer++;
          putStringToPass2Pool(argument, 2);
        }
        address += 3;
        if (class == C_NL)
          state = S_START;
        else if (class == C_COLON)
          state = S_START;
        else if (class == C_WS)
          state = S_WAIT;
        else
          state = S_COMMENT;
      } else {
        actionErrorInvAddressMode();
      }
    } else if (class == C_COMMA) {
      state = S_ARGINDIRY1;
      modeXY = 1;
    } else {
      actionErrorInvChar(ch);
    }
  } else if (state == S_ARGINDIRX1) {
    modeXY = 0;
    if (class == C_X)
      state = S_ARGINDIRX2;
    else {
      actionErrorInvChar(ch);
    }
  } else if (state == S_ARGINDIRX2) {
    if (class == C_CLOSEBRACKET)
      state = S_ARGINDIRX3;
    else {
      actionErrorInvChar(ch);
    }
  } else if (state == S_ARGINDIRX3) {
    if ((class == C_NL) || (class == C_COLON) || (class == C_WS) ||
        (class == C_SEMICOLON)) {
      if (actopcode->indirectX) {
        ushort val;
        argument[argumentidx] = '\0';
        *outbuffer++ = actopcode->indirectX;
        if (evalExpr(argument, &val)) {
          *outbuffer++ = val % 256;
        } else {
          outbuffer++;
          putStringToPass2Pool(argument, 1);
        }
        address += 2;
        if (class == C_NL)
          state = S_START;
        else if (class == C_COLON)
          state = S_START;
        else if (class == C_WS)
          state = S_WAIT;
        else
          state = S_COMMENT;
      } else {
        actionErrorInvAddressMode();
      }
    } else {
      actionErrorInvChar(ch);
    }
  } else if (state == S_ARGINDIRY1) {
    modeXY = 0;
    if (class == C_Y)
      state = S_ARGINDIRY2;
    else {
      actionErrorInvChar(ch);
    }
  } else if (state == S_ARGINDIRY2) {
    if ((class == C_NL) || (class == C_COLON) || (class == C_WS) ||
        (class == C_SEMICOLON)) {
      if (actopcode->indirectY) {
        ushort val;
        argument[argumentidx] = '\0';
        *outbuffer++ = actopcode->indirectY;
        if (evalExpr(argument, &val)) {
          *outbuffer++ = val % 256;
        } else {
          outbuffer++;
          putStringToPass2Pool(argument, 1);
        }
        address += 2;
        if (class == C_NL)
          state = S_START;
        else if (class == C_COLON)
          state = S_START;
        else if (class == C_WS)
          state = S_WAIT;
        else
          state = S_COMMENT;
      } else {
        actionErrorInvAddressMode();
      }
    } else {
      actionErrorInvChar(ch);
    }
  } else if (state == S_PSEUDO) {
    if (class == C_AZ)
      argument[argumentidx++] = ch;
    else if (class == C_WS) {
      argument[argumentidx] = '\0';
      if (strcmp(argument, "byt") == 0) {
        bytemode = 1;
        exprmode = 1;
        state = S_PSEUDOBYT1;
      } else if (strcmp(argument, "word") == 0) {
        bytemode = 0;
        exprmode = 1;
        state = S_PSEUDOBYT1;
      } else if (strcmp(argument, "dsb") == 0) {
        exprmode = 1;
        state = S_PSEUDODSB1;
      } else if (strcmp(argument, "asc") == 0)
        state = S_PSEUDOASC1;
      else {
        snprintf(errstr, STRSIZE, "invalid pseudo opcode %s", argument);
        state = S_ERROR;
      }
    } else {
      actionErrorInvChar(ch);
    }
  } else if (state == S_PSEUDOBYT1) {
    if (class == C_WS) {
    } else if (class == C_EXPR) {
      argumentidx = 0;
      argument[argumentidx++] = ch;
      state = S_PSEUDOBYT2;
    } else {
      actionErrorInvChar(ch);
    }
  } else if (state == S_PSEUDOBYT2) {
    if (class == C_EXPR)
      argument[argumentidx++] = ch;
    else if ((class == C_COMMA) || (class == C_NL) || (class == C_COLON) ||
             (class == C_WS) || (class == C_SEMICOLON)) {
      ushort val;
      exprmode = 0;
      argument[argumentidx] = '\0';
      if (evalExpr(argument, &val)) {
        *outbuffer++ = val % 256;
        address++;
        if (!bytemode) {
          *outbuffer++ = val / 256;
          address++;
        }
      } else {
        if (bytemode) {
          outbuffer++;
          putStringToPass2Pool(argument, 1);
          address++;
        } else {
          outbuffer += 2;
          address--;
          putStringToPass2Pool(argument, 2);
          address += 3;
        }
      }
      if (class == C_COMMA) {
        exprmode = 1;
        state = S_PSEUDOBYT1;
      } else if (class == C_NL)
        state = S_START;
      else if (class == C_COLON)
        state = S_START;
      else if (class == C_WS)
        state = S_WAIT;
      else
        state = S_COMMENT;
    } else {
      actionErrorInvChar(ch);
    }
  } else if (state == S_PSEUDODSB1) {
    if (class == C_WS) {
    } else if (class == C_EXPR) {
      argumentidx = 0;
      argument[argumentidx++] = ch;
      state = S_PSEUDODSB2;
    } else {
      actionErrorInvChar(ch);
    }
  } else if (state == S_PSEUDODSB2) {
    if (class == C_EXPR)
      argument[argumentidx++] = ch;
    else if ((class == C_NL) || (class == C_COLON) || (class == C_WS) ||
             (class == C_SEMICOLON)) {
      ushort val;
      exprmode = 0;
      argument[argumentidx] = '\0';
      if (evalExpr(argument, &val)) {
        int i;
        for (i = 0; i < val; i++)
          *outbuffer++ = 0;
        address += val;
        if (class == C_NL)
          state = S_START;
        else if (class == C_COLON)
          state = S_START;
        else if (class == C_WS)
          state = S_WAIT;
        else
          state = S_COMMENT;
      } else {
        actionErrorInvExpression();
      }
    } else {
      actionErrorInvChar(ch);
    }
  } else if (state == S_PSEUDOASC1) {
    if (class == C_WS) {
    } else if (class == C_DQUOTE) {
      argumentidx = 0;
      state = S_PSEUDOASC2;
    } else {
      actionErrorInvChar(ch);
    }
  } else if (state == S_PSEUDOASC2) {
    if (class == C_DQUOTE) {
      int i = 0;
      while (i < argumentidx) {
        *outbuffer++ = argument[i++];
        address++;
      }
      state = S_WAIT;
    } else
      argument[argumentidx++] = ch;
  } else if (state == S_ERROR) {
    return 0;
  }
  if (class == C_NL)
    linenum++;
  return 1;
}

// do pass 2
// returns 0 in case of error, 1 otherwise
uchar pass2() {
  ushort i;
  pass2pool entry;
  ushort strPtr;
  char *str;
  ushort val;
  for (i = 0; i < pass2poolarridx; i++) {
    entry = pass2poolarr[i];
    strPtr = entry.idx;
    str = pass2poolstrings + strPtr;
    val = eval(str);
    if (errEval) {
      snprintf(errstr, STRSIZE, "%s not found", str);
      return 1;
    } else {
      ushort addr = entry.addr;
      if (entry.num == 1) {
        outbuffer[addr] = val % 256;
      } else if (entry.num == 2) {
        outbuffer[addr] = val % 256;
        outbuffer[addr + 1] = val / 256;
      } else {
        outbuffer[addr] = val % 256 - (addr + startaddress + 1);
      }
    }
  }
  return 0;
}

// assemble code given in pinbuffer and put the machine code to poutbuffer,
// put the size of the compiled code in size
// returns 0 if assemble was successful, != 0 otherwise
uchar assemble(uchar *pinbuffer, uchar *poutbuffer, ushort *size,
               ushort *errlinenum, char *errmsg, uchar pbufcheck) {
  // init.
  inbuffer = pinbuffer;
  outbuffer = poutbuffer;
  bufcheck = pbufcheck;
  initHashtable();
  modeXY = 0;
  exprmode = 0;
  state = S_START;
  address = 0;
  startaddress = 0;
  pass2poolarridx = 0;
  pass2poolstringsidx = 0;
  linenum = 1;

  // pass 1
  while (stateMachine()) {
  }
  if (state == S_ERROR) {
    *errlinenum = linenum;
    strncpy(errmsg, errstr, STRSIZE);
    return 1;
  }
  *size = outbuffer - poutbuffer;
  outbuffer = poutbuffer;

  // pass 2
  if (pass2()) {
    *errlinenum = -1;
    strncpy(errmsg, errstr, STRSIZE);
    return 2;
  }
  return 0;
}

// state machine (Graphviz format)
// -> save definitions to a file called ass.gv
// -> dot -T jpg -o ass.jpg ass.gv
/*
digraph finite_state_machine {
        rankdir=LR;
        size="16,16"
        node [shape = oval];
        start -> start [ label = "[W],NL,';'" ];
        start -> lco [ label = "[a-z]" ];
        start -> org [ label = "'*'" ];
        start -> comment [ label = "';'" ];
        start -> pseudo [ label = "'.'" ];
        lco -> lco [ label = "[a-z],[0-9]" ];
        lco -> const1 [ label = "'='" ];
        lco -> label [ label = "NL,':',<noOpc>" ];
        lco -> laborconst [ label = "[W],<noOpc>" ];
        lco -> start [ label = "NL,':',<opc implicit> -> opcode" ];
        lco -> opcode [ label = "[W],<opc>" ];
        laborconst -> laborconst [ label = "[W]" ];
        laborconst -> label [ label = "NL,':'" ];
        laborconst -> const1 [ label = "'='" ];
        laborconst -> comment [ label = "';' -> label" ];
        label -> wait [ label = "[W] -> label" ];
        label -> start [ label = "NL -> label" ];
        label -> comment [ label = "';' -> label" ];
        const1 -> const2 [ label = "[EXPR]" ];
        const1 -> const1 [ label = "[W]" ];
        const2 -> const2 [ label = "[EXPR]" ];
        const2 -> start [ label = "NL,':' -> const" ];
        const2 -> wait [ label = "[W] -> const" ];
        const2 -> comment [ label = "';' -> const" ];
        org -> org [ label = "[W]" ];
        org -> const1 [ label = "'='" ];
        wait -> wait [ label = "[W]" ];
        wait -> start [ label = "NL,':'" ];
        wait -> comment [ label = "';'" ];
        comment -> comment [ label = "!NL" ];
        comment -> start [ label = "NL" ];
        opcode -> opcode [ label = "[W]" ];
        opcode -> start [ label = "NL,':' -> opcode" ];
        opcode -> argimm1 [ label = "'#'" ];
        opcode -> argabs [ label = "[a-z],[0-9]" ];
        opcode -> argindir1 [ label = "'('" ];
        argimm1 -> argimm2 [ label = "[EXPR]" ];
        argimm2 -> argimm2 [ label = "[EXPR]" ];
        argimm2 -> start [ label = "NL,':' -> opcode" ];
        argimm2 -> wait [ label = "[W] -> opcode" ];
        argimm2 -> comment [ label = "';' -> opcode" ];
        argabs -> argabs [ label = "[EXPR]" ];
        argabs -> start [ label = "NL,':' -> opcode" ];
        argabs -> wait [ label = "[W] -> opcode" ];
        argabs -> comment [ label = "';' -> opcode" ];
        argabs -> argabsxy [ label = "','" ];
        argabsxy -> argabsx [ label = "'x'" ];
        argabsxy -> argabsy [ label = "'y'" ];
        argabsx -> start [ label = "NL,':' -> opcode" ];
        argabsx -> wait [ label = "[W] -> opcode" ];
        argabsx -> comment [ label = "';' -> opcode" ];
        argabsy -> start [ label = "NL,':' -> opcode" ];
        argabsy -> wait [ label = "[W] -> opcode" ];
        argabsy -> comment [ label = "';' -> opcode" ];
        argindir1 -> argindir2 [ label = "[EXPR]" ];
        argindir2 -> argindir2 [ label = "[EXPR]" ];
        argindir2 -> argindir3 [ label = "')'" ];
        argindir2 -> argindirx1 [ label = "','" ];
        argindir3 -> start [ label = "NL,':' -> opcode" ];
        argindir3 -> wait [ label = "[W] -> opcode" ];
        argindir3 -> comment [ label = "';' -> opcode" ];
        argindir3 -> argindiry1 [ label = "','" ];
        argindirx1 -> argindirx2 [ label = "'x'" ];
        argindirx2 -> argindirx3 [ label = "')'" ];
        argindirx3 -> start [ label = "NL,':' -> opcode" ];
        argindirx3 -> wait [ label = "[W] -> opcode" ];
        argindirx3 -> comment [ label = "';' -> opcode" ];
        argindiry1 -> argindiry2 [ label = "'y'" ];
        argindiry2 -> start [ label = "NL,':' -> opcode" ];
        argindiry2 -> wait [ label = "[W] -> opcode" ];
        argindiry2 -> comment [ label = "';' -> opcode" ];
        pseudo -> pseudo [ label = "[a-z]" ];
        pseudo -> pseudobyt1 [ label = "'byt','word'" ];
        pseudo -> pseudodsb1 [ label = "'dsb'" ];
        pseudo -> pseudoasc1 [ label = "'asc'" ];
        pseudobyt1 -> pseudobyt1 [ label = "[W]" ];
        pseudobyt1 -> pseudobyt2 [ label = "[EXPR]" ];
        pseudobyt2 -> pseudobyt2 [ label = "[EXPR]" ];
        pseudobyt2 -> pseudobyt1 [ label = "',' -> pseudo" ];
        pseudobyt2 -> start [ label = "NL,':' -> pseudo" ];
        pseudobyt2 -> wait [ label = "[W] -> pseudo" ];
        pseudobyt2 -> comment [ label = "';' -> pseudo" ];
        pseudodsb1 -> pseudodsb1 [ label = "[W]" ];
        pseudodsb1 -> pseudodsb2 [ label = "[EXPR]" ];
        pseudodsb2 -> pseudodsb2 [ label = "[EXPR]" ];
        pseudodsb2 -> start [ label = "NL,':' -> pseudo" ];
        pseudodsb2 -> wait [ label = "[W] -> pseudo" ];
        pseudodsb2 -> comment [ label = "';' -> pseudo" ];
        pseudoasc1 -> pseudoasc1 [ label = "[W]" ];
        pseudoasc1 -> pseudoasc2 [ label = "'\"'" ];
        pseudoasc2 -> pseudoasc2 [ label = "!\"" ];
        pseudoasc2 -> wait [ label = "'\"' -> pseudo" ];
}
*/
