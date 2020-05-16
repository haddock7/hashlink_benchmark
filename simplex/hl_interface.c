#define HL_NAME(n) simplex_##n

#include <hl.h>
#include "simplex.h"

HL_PRIM double HL_NAME(benchmark)()
{
	return benchmark();
}

DEFINE_PRIM(_F64, benchmark, _NO_ARG); 