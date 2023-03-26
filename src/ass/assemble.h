// 6502 assembler, v1.0, c code
// written for the R162 (see
// https://sites.google.com/site/retroelec/retroelecs-electronics-projects/r162)
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

#ifndef __ASSEMBLE_H
#define __ASSEMBLE_H

unsigned char assemble(unsigned char *pinbuffer, unsigned char *poutbuffer,
                       unsigned short *size, unsigned short *errlinenum,
                       char *errmsg, unsigned char pbufcheck);

#endif /* __ASSEMBLE_H */
