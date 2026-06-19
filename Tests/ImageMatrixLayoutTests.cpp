#include <cstdlib>
#include <iostream>
#include <limits>

#include "ImageMatrixLayout.hpp"

static void expectLayout(const char* name,
                         std::size_t columns,
                         std::size_t rows,
                         int channels,
                         std::size_t elementBytes,
                         std::size_t rowBytes,
                         bool expected,
                         std::size_t expectedTotalBytes)
{
    brandcapture::ImageMatrixLayout layout;
    const bool actual = brandcapture::getImageMatrixLayout(
        columns, rows, channels, elementBytes, rowBytes, &layout);
    if (actual != expected) {
        std::cerr << name << ": expected " << expected << " but was " << actual << std::endl;
        std::exit(1);
    }
    if (actual && layout.totalBytes != expectedTotalBytes) {
        std::cerr << name << ": expected " << expectedTotalBytes
                  << " bytes but was " << layout.totalBytes << std::endl;
        std::exit(1);
    }
}

int main()
{
    if (brandcapture::requiresPackedImageClone(3, 4, 12, true) ||
        !brandcapture::requiresPackedImageClone(3, 4, 16, true) ||
        !brandcapture::requiresPackedImageClone(3, 4, 12, false) ||
        !brandcapture::requiresPackedImageClone(
            std::numeric_limits<std::size_t>::max(), 4, 0, true)) {
        std::cerr << "packed clone decision failed" << std::endl;
        return 1;
    }

    expectLayout("grayscale", 3, 2, 1, 1, 3, true, 6);
    expectLayout("four channel", 3, 2, 4, 4, 12, true, 24);
    expectLayout("zero columns", 0, 2, 1, 1, 0, false, 0);
    expectLayout("zero rows", 2, 0, 1, 1, 2, false, 0);
    expectLayout("two channels", 2, 2, 2, 2, 4, false, 0);
    expectLayout("three channels", 2, 2, 3, 3, 6, false, 0);
    expectLayout("multi-byte gray", 2, 2, 1, 2, 4, false, 0);
    expectLayout("short row", 3, 2, 4, 4, 11, false, 0);
    expectLayout("padded row", 3, 2, 4, 4, 16, false, 0);
    expectLayout("row overflow",
                 std::numeric_limits<std::size_t>::max(),
                 1,
                 4,
                 4,
                 0,
                 false,
                 0);
    expectLayout("total overflow",
                 1,
                 std::numeric_limits<std::size_t>::max(),
                 4,
                 4,
                 4,
                 false,
                 0);

    brandcapture::ImageMatrixLayout layout;
    if (brandcapture::getImageMatrixLayout(1, 1, 1, 1, 1, NULL)) {
        std::cerr << "null output: expected rejection" << std::endl;
        return 1;
    }

    std::cout << "Image matrix layout C++ tests passed." << std::endl;
    return 0;
}
