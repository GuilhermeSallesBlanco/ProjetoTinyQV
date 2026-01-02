#include <uart.h>
#define printf uart_printf

int main(void) {
    printf("Hello TinyQV!\n");
    while (1);
}
