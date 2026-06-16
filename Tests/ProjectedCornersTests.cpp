#include <cstdlib>
#include <iostream>
#include <limits>
#include <vector>

#include "ProjectedCorners.hpp"

using brandcapture::ProjectedPoint;

static void expectValidity(const char* name,
                           const std::vector<ProjectedPoint>& corners,
                           bool expected)
{
    const bool actual = brandcapture::hasValidProjectedCorners(corners);
    if (actual != expected) {
        std::cerr << name << ": expected " << expected << " but was " << actual << std::endl;
        std::exit(1);
    }
}

int main()
{
    expectValidity("clockwise square", {{0, 0}, {0, 2}, {2, 2}, {2, 0}}, true);
    expectValidity("counter-clockwise square", {{0, 0}, {2, 0}, {2, 2}, {0, 2}}, true);
    expectValidity("exact minimum area", {{0, 0}, {1, 0}, {1, 1}, {0, 1}}, true);
    expectValidity("below minimum area", {{0, 0}, {0.5, 0}, {0.5, 1}, {0, 1}}, false);
    expectValidity("concave", {{0, 0}, {2, 0}, {1, 0.5}, {0, 2}}, false);
    expectValidity("crossing", {{0, 0}, {2, 2}, {0, 2}, {2, 0}}, false);
    expectValidity("collinear", {{0, 0}, {1, 0}, {2, 0}, {3, 0}}, false);
    expectValidity("duplicate point", {{0, 0}, {2, 0}, {2, 0}, {0, 2}}, false);
    expectValidity("three corners", {{0, 0}, {2, 0}, {0, 2}}, false);
    expectValidity("five corners", {{0, 0}, {2, 0}, {2, 2}, {1, 3}, {0, 2}}, false);
    expectValidity("nan coordinate", {{0, 0}, {2, 0}, {2, 2}, {0, std::numeric_limits<double>::quiet_NaN()}}, false);
    expectValidity("infinite coordinate", {{0, 0}, {2, 0}, {2, 2}, {0, std::numeric_limits<double>::infinity()}}, false);

    std::cout << "Projected corner C++ tests passed." << std::endl;
    return 0;
}
