
#include <uart.h>
#include <csr.h>
#include <mul.h>

static void send_pattern(void) {
    // 0x55 ('U') -> padrão 10101010, ótimo para medir o bit-time
    for (int i = 0; i < 64; i++) uart_putc('U');
    uart_puts("\r\nHello TinyQV!\r\n");
}

int main(void) {
    send_pattern();

    int a = 3;
    uart_printf("Hello %d\r\n", a);
    a = mul32x16(12, a);
    uart_printf("Hello %d\r\n", a);
    uart_printf("Cycles %u, time %u, instret %u\r\n",
                read_cycle(), read_time(), read_instret());

    while (1) { } // mantém a app viva
    return 0;
}
