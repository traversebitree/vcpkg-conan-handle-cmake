#include <curl/curl.h>
#include <fmt/core.h>
#include <zlib.h>

size_t write_callback(char *contents, size_t size, size_t nmemb, void *userp)
{
    static_cast<std::string *>(userp)->append((char *)contents, size * nmemb);
    return size * nmemb;
}

int main(int argc, char const *argv[])
{
    curl_global_init(CURL_GLOBAL_ALL);
    CURL *easyhandle = curl_easy_init();
    std::string read_buffer;
    curl_easy_setopt(easyhandle, CURLOPT_URL, "ifconfig.me");
    curl_easy_setopt(easyhandle, CURLOPT_WRITEFUNCTION, write_callback);
    curl_easy_setopt(easyhandle, CURLOPT_WRITEDATA, &read_buffer);
    curl_easy_perform(easyhandle);
    fmt::print("My IP is: {}\n", read_buffer);
    fmt::print("ZLIB VERSION: {}\n", zlibVersion());
    return 0;
}