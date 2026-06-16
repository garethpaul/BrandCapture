#ifndef ProjectedCorners_hpp
#define ProjectedCorners_hpp

#include <cmath>
#include <cstddef>
#include <vector>

namespace brandcapture {

struct ProjectedPoint {
    ProjectedPoint(double pointX, double pointY) : x(pointX), y(pointY) {}

    double x;
    double y;
};

inline double turn(const ProjectedPoint& first,
                   const ProjectedPoint& second,
                   const ProjectedPoint& third)
{
    return (second.x - first.x) * (third.y - second.y) -
           (second.y - first.y) * (third.x - second.x);
}

inline bool hasValidProjectedCorners(const std::vector<ProjectedPoint>& corners)
{
    const std::size_t expectedCornerCount = 4;
    const double minimumAreaTwice = 2.0;

    if (corners.size() != expectedCornerCount) {
        return false;
    }

    for (std::size_t i = 0; i < corners.size(); ++i) {
        if (!std::isfinite(corners[i].x) || !std::isfinite(corners[i].y)) {
            return false;
        }
    }

    double previousTurn = 0.0;
    for (std::size_t i = 0; i < corners.size(); ++i) {
        const double currentTurn = turn(corners[i],
                                        corners[(i + 1) % corners.size()],
                                        corners[(i + 2) % corners.size()]);
        if (!std::isfinite(currentTurn) || currentTurn == 0.0) {
            return false;
        }
        if (previousTurn != 0.0 && (currentTurn > 0.0) != (previousTurn > 0.0)) {
            return false;
        }
        previousTurn = currentTurn;
    }

    double areaTwice = 0.0;
    for (std::size_t i = 0; i < corners.size(); ++i) {
        const ProjectedPoint& current = corners[i];
        const ProjectedPoint& next = corners[(i + 1) % corners.size()];
        areaTwice += current.x * next.y - next.x * current.y;
        if (!std::isfinite(areaTwice)) {
            return false;
        }
    }

    return std::fabs(areaTwice) >= minimumAreaTwice;
}

}  // namespace brandcapture

#endif /* ProjectedCorners_hpp */
