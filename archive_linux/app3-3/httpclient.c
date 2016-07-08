#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>

static int sofd;
static struct hostent     *shost;
static struct sockaddr_in sv_addr;

int main (int argc, char *argv[]) {

    char *target_host;
    char target_uri[1024 +1];
    int  target_portno;

    char http_res[1024];
    char http_all[4096];

    char *pos_coeff;
    char *pos_br;
    char str_a0[32];
    char str_a1[32];
    char str_a2[32];
    char str_b1[32];
    char str_b2[32];

    FILE *fp;
    char *fname = "coeff.txt";

    int htmlerr = 0;
    int n;
    int total = 0;

    if (argc >=2 && strncmp(argv[1], "-h", 2) == 0) {
        fprintf(stderr, "1st arg is HOSTNAME of httpd server (required).\n");
        fprintf(stderr, "2nd arg is URI of request (default is '/')\n");
        fprintf(stderr, "3rd arg is PORT_NO of httpd server (default is 80)\n");
        return 0;
    }

    if (argc < 2) {
        fprintf(stderr, "1st arg must be HOSTNAME of httpd server.\n");
        fprintf(stderr, "if you want to show help, run '%s -h'\n", argv[0]);
        return -1;
    }
    target_host = argv[1];

    if (argc >= 3) {
        if (strncmp(argv[2], "/", 1) != 0) {
            fprintf(stderr, "URI of request must be started with '/'\n");
            return -1;
        }
        if (strlen(argv[2]) >= 1024) {
            fprintf(stderr, "URI of request must be under 1024bytes\n");
            return -1;
        }
        strcpy(target_uri, argv[2]);
    } else {
        strcpy(target_uri, "/");
    }

    if (argc >= 4) {
        target_portno = atoi(argv[3]);
        if (target_portno < 0 || target_portno > 65536) {
            fprintf(stderr, "PORT_NO of httpd server is invalid\n");
            return -1;
        }
    } else {
        target_portno = 80;
    }

    sofd = socket(AF_INET, SOCK_STREAM, 0);
    if (sofd < 0) {
        fprintf(stderr, "can not open SOCKET.\n");
        return 1;
    }

    shost = gethostbyname(target_host);
    if (shost == NULL) {
        fprintf(stderr, "err happend in gethostbyname function.\n");
        return 1;
    }

    memset(&sv_addr, '\0', sizeof(sv_addr));
    sv_addr.sin_family = AF_INET;
    sv_addr.sin_port   = htons(target_portno);
    memcpy((char *)&sv_addr.sin_addr, (char *)shost->h_addr, shost->h_length);

    if (connect(sofd, (const struct sockaddr*)&sv_addr, sizeof(sv_addr)) < 0) {
        fprintf(stderr, "err happend in connect function.\n");
        return 1;
    }

    send(sofd, "GET ",      strlen("GET "),      0);
    send(sofd, target_uri,  strlen(target_uri),  0);
    send(sofd, " HTTP/1.0", strlen(" HTTP/1.0"), 0);
    send(sofd, "\r\n",      strlen("\r\n"),      0);
    send(sofd, "Host: ",    strlen("Host: "),    0);
    send(sofd, target_host, strlen(target_host), 0);
    send(sofd, "\r\n",      strlen("\r\n"),      0);
    send(sofd, "\r\n",      strlen("\r\n"),      0);

    while (1) {
        n = recv(sofd, http_res, sizeof(http_res), 0);
        if(n > 0) {
          total += n;
          if(total < sizeof(http_all)) strcat(http_all, http_res);
          memset(&http_res, '\0', sizeof(http_res));
        } else {
          break;
        }
    }

    printf("%s",http_all);

    memset(&str_a0, '\0', sizeof(str_a0));
    memset(&str_a1, '\0', sizeof(str_a1));
    memset(&str_a2, '\0', sizeof(str_a2));
    memset(&str_b1, '\0', sizeof(str_b1));
    memset(&str_b2, '\0', sizeof(str_b2));

    pos_coeff = strstr(http_all, "a0 =");
    if(pos_coeff != NULL) pos_br = strstr(pos_coeff, "<BR>");
    if(pos_coeff != NULL && pos_br != NULL ) {
      strncpy(str_a0, pos_coeff+4, pos_br-(pos_coeff+4));
      printf("%s   %d\n", str_a0, pos_br-(pos_coeff+4));
    } else {
      htmlerr = 1;
    }
 
    pos_coeff = strstr(http_all, "a1 =");
    if(pos_coeff != NULL) pos_br = strstr(pos_coeff, "<BR>");
    if(pos_coeff != NULL && pos_br != NULL ) {
      strncpy(str_a1, pos_coeff+4, pos_br-(pos_coeff+4));
      printf("%s   %d\n", str_a1, pos_br-(pos_coeff+4));
    } else {
      htmlerr = 1;
    }
 
    pos_coeff = strstr(http_all, "a2 =");
    if(pos_coeff != NULL) pos_br = strstr(pos_coeff, "<BR>");
    if(pos_coeff != NULL && pos_br != NULL ) {
      strncpy(str_a2, pos_coeff+4, pos_br-(pos_coeff+4));
      printf("%s   %d\n", str_a2, pos_br-(pos_coeff+4));
    } else {
      htmlerr = 1;
    }
 
    pos_coeff = strstr(http_all, "b1 =");
    if(pos_coeff != NULL) pos_br = strstr(pos_coeff, "<BR>");
    if(pos_coeff != NULL && pos_br != NULL ) {
      strncpy(str_b1, pos_coeff+4, pos_br-(pos_coeff+4));
      printf("%s   %d\n", str_b1, pos_br-(pos_coeff+4));
    } else {
      htmlerr = 1;
    }
 
    pos_coeff = strstr(http_all, "b2 =");
    if(pos_coeff != NULL) pos_br = strstr(pos_coeff, "<BR>");
    if(pos_coeff != NULL && pos_br != NULL ) {
      strncpy(str_b2, pos_coeff+4, pos_br-(pos_coeff+4));
      printf("%s   %d\n", str_b2, pos_br-(pos_coeff+4));
    } else {
      htmlerr = 1;
    }

    fp = fopen( fname, "w" );
    if( fp == NULL || htmlerr != 0 ){
      printf( "%s cannot be opened.\n", fname );
      return -1;
    } else {
      fputs( str_a0, fp);
      fputs( "\n", fp);
      fputs( str_a1, fp);
      fputs( "\n", fp);
      fputs( str_a2, fp);
      fputs( "\n", fp);
      fputs( str_b1, fp);
      fputs( "\n", fp);
      fputs( str_b2, fp);
      fputs( "\n", fp);
    }

    fclose(fp);
    close(sofd);

    return 1;
}
