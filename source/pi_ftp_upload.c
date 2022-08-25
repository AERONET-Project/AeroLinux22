#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <termios.h>
#include <time.h>
#include <string.h>
#include <arpa/inet.h>
#include <sys/socket.h>
#include <netdb.h>
#include <ifaddrs.h>

#include <curl/curl.h>

#include "models_port.h"



size_t dataSize;


size_t upload_hb_buffer_internally(unsigned char *buffer, size_t size, size_t nmemb, unsigned char *hb_buffer)
{

    size_t total = size * nmemb;

    if (total > dataSize)
        total = dataSize;

    if (total > 0)
    {

        memcpy(buffer, hb_buffer, total);
        memcpy(hb_buffer, hb_buffer + total, dataSize - total);
        dataSize -= total;
    }
    return total;
}

int upload_hb_buffer_to_ftp(unsigned char *hb_buffer, char *upload_name)
{
    char *bufname = getlogin();
    CURL *curl;
    CURLcode res;
    char sscctt[200];
    int i;

    printf("Will upload file %s with %d bytes\n", upload_name, dataSize);

    curl = curl_easy_init();

    if (!curl)
        return 0;

    sprintf(sscctt, "ftp://aeronet.gsfc.nasa.gov/pub/incoming/raspberry_pi_heartbeat/%s/%s",bufname, upload_name);

    curl_easy_setopt(curl, CURLOPT_URL, sscctt);
    curl_easy_setopt(curl, CURLOPT_TIMEOUT, 60);
    curl_easy_setopt(curl, CURLOPT_UPLOAD, 1);
    curl_easy_setopt(curl, CURLOPT_USERPWD, "anonymous:me@email.net");

    curl_easy_setopt(curl, CURLOPT_READFUNCTION, upload_hb_buffer_internally);
    curl_easy_setopt(curl, CURLOPT_READDATA, hb_buffer);
    printf("Will perform curl\n");
    res = curl_easy_perform(curl);
    printf("Curlopt return %d\n", res);
    curl_easy_cleanup(curl);
    if (res == CURLE_OK)
        return 1;

    return 0;
}

int main(int argc, char **argv)
{

    time_t local_time, aeronet_time;
    char heartbeat_buffer[500], file_name[300], *kurka;

    AERO_EXCHANGE aerex;
    struct ifaddrs *ifaddr, *ifa;
    int family, s;
    char host[NI_MAXHOST],  hostname[100], *username;
    struct tm mtim;

    if (getifaddrs(&ifaddr) == -1)
    {
        perror("getifaddrs");
        exit(EXIT_FAILURE);
    }

    local_time = time(NULL);
    if (receive_aeronet_time(&aerex, NULL))
    {

        perform_update_routine (aerex.aeronet_time);
        
        kurka = heartbeat_buffer;


        gethostname(hostname, 99);
        username = getenv("LOGNAME");

        sprintf(kurka, "PI_HOST_NAME=%s\nUSER=%s\n", hostname, username);
        kurka += strlen(kurka);

        gmtime_r(&local_time, &mtim);
        sprintf(kurka, "PI_Time=%02d:%02d:%d,%02d:%02d:%02d\n", mtim.tm_mday, mtim.tm_mon + 1, mtim.tm_year + 1900,
                mtim.tm_hour, mtim.tm_min, mtim.tm_sec);
        kurka += strlen(kurka);

        sprintf(file_name, "%s_%02d-%02d-%d_%02d-%02d-%02d", username, mtim.tm_mday, mtim.tm_mon + 1, mtim.tm_year + 1900,
                mtim.tm_hour, mtim.tm_min, mtim.tm_sec);

        gmtime_r(&aerex.aeronet_time, &mtim);
        sprintf(kurka, "Aeronet_Time=%02d:%02d:%d,%02d:%02d:%02d\n", mtim.tm_mday, mtim.tm_mon + 1, mtim.tm_year + 1900,
                mtim.tm_hour, mtim.tm_min, mtim.tm_sec);
        kurka += strlen(kurka);


        for (ifa = ifaddr; ifa != NULL; ifa = ifa->ifa_next)
        {
            s = getnameinfo(ifa->ifa_addr, sizeof(struct sockaddr_in), host, NI_MAXHOST, NULL, 0, NI_NUMERICHOST);
            if (s == 0)
            {
                sprintf(kurka, "<Interface>: %s   <Address> %s\n", ifa->ifa_name, host);
                kurka += strlen(kurka);
            }
        }
        dataSize = strlen(heartbeat_buffer);

        printf("Formed buffer to upload:\n%s\nSize = %d\n", heartbeat_buffer, dataSize);
        upload_hb_buffer_to_ftp(heartbeat_buffer, file_name);
    }
}
