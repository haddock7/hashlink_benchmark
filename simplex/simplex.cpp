#include "simplex.h"
#include "open_simplex.h"

extern "C" double benchmark()
{
	double result = 0.0;
	for (int pass = 0; pass < 128; pass++)
	{
		OpenSimplexNoise simplex_noise(pass);

		for (int y = 0; y < 1024; y++)
		{
			double simplex_y = y / 64.0f;
			for (int x = 0; x < 1024; x++)
			{
				double simplex_x = x / 64.0f;
				result += simplex_noise.eval(simplex_x, simplex_y);
			}
		}
	}
	return result;
}
