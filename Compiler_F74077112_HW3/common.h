#ifndef COMMON_H
#define COMMON_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

struct symbolTable{
    int index;
    char* name;
    char* type;
    int addr;
    int lineno;
    char* element;
    int scope;
};
#endif /* COMMON_H */
