#pragma once

#include <vector>

class OpenSimplexNoise
{
private:
	std::vector<int> m_perm;

	double extrapolate(int xsb, int ysb, double dx, double dy);
public:
	OpenSimplexNoise(int seed);
	double eval(double x, double y);
};