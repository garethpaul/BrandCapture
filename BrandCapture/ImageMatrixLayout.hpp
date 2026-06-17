#ifndef ImageMatrixLayout_hpp
#define ImageMatrixLayout_hpp

#include <cstddef>
#include <limits>

namespace brandcapture {

struct ImageMatrixLayout {
    ImageMatrixLayout() : rowBytes(0), totalBytes(0), channelCount(0) {}

    std::size_t rowBytes;
    std::size_t totalBytes;
    int channelCount;
};

inline bool requiresPackedImageClone(std::size_t columns,
                                     std::size_t elementBytes,
                                     std::size_t rowBytes,
                                     bool isContinuous)
{
    const std::size_t maximum = std::numeric_limits<std::size_t>::max();
    if (columns == 0 || elementBytes == 0 || columns > maximum / elementBytes) {
        return true;
    }
    return !isContinuous || rowBytes != columns * elementBytes;
}

inline bool getImageMatrixLayout(std::size_t columns,
                                 std::size_t rows,
                                 int channelCount,
                                 std::size_t elementBytes,
                                 std::size_t rowBytes,
                                 ImageMatrixLayout* layout)
{
    if (layout == NULL || columns == 0 || rows == 0 ||
        (channelCount != 1 && channelCount != 4) ||
        elementBytes != static_cast<std::size_t>(channelCount)) {
        return false;
    }

    const std::size_t maximum = std::numeric_limits<std::size_t>::max();
    if (columns > maximum / elementBytes) {
        return false;
    }

    const std::size_t packedRowBytes = columns * elementBytes;
    if (rowBytes != packedRowBytes || rows > maximum / rowBytes) {
        return false;
    }

    layout->rowBytes = rowBytes;
    layout->totalBytes = rowBytes * rows;
    layout->channelCount = channelCount;
    return true;
}

}  // namespace brandcapture

#endif /* ImageMatrixLayout_hpp */
