#include "fmt/format.h"

int main(int argc, char const *argv[])
{
    fmt::print("Hello! {}-{}-{}", "vcpkg", "handle", "cmake");
    return 0;
}
