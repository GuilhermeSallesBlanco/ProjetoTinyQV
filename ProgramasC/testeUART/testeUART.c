
// uart_diag.c  —  Teste de UART para TinyQV + Colorlight i9
#include <stdint.h>

#define CLOCK_HZ        25000000u   // 25 MHz
#define BAUD            115200u
#define UART_DIVISOR    (CLOCK_HZ / BAUD)
#define RX_USE_UI3      0           // 0 => RX = ui_in[7], 1 => RX = ui_in[3]

#define USER_BASE       0x8000100u
#define UART_INDEX      2u
#define UART_BASE       (USER_BASE + (UART_INDEX << 6))  // 0x8000180

#define UART_DATA       (UART_BASE + 0x00)   // W: TX byte ; R: RX byte
#define UART_STATUS     (UART_BASE + 0x04)   // bit0=tx_busy, bit1=rx_buf
#define UART_BAUD       (UART_BASE + 0x08)   // rw divisor
#define UART_RXDSEL     (UART_BASE + 0x0C)   // 0=ui_in[7], 1=ui_in[3]

// Se tiver CSR TIME mapeado, ajuste; se não, remova o uso.
#define CSR_TIME_LO     0xFFFFF00u
static inline uint32_t mtime(void) { return *(volatile uint32_t*)CSR_TIME_LO; }

#define REG8(a)   (*(volatile uint8_t  *)(a))
#define REG32(a)  (*(volatile uint32_t *)(a))

static inline void uart_set_baud(uint32_t div)     { REG32(UART_BAUD)  = div; }
static inline void uart_set_rxd_source(uint8_t s)  { REG8(UART_RXDSEL) = s ? 1 : 0; }
static inline uint8_t uart_tx_busy(void)           { return (REG8(UART_STATUS) & 0x01) ? 1 : 0; }
static inline uint8_t uart_rx_available(void)      { return (REG8(UART_STATUS) & 0x02) ? 1 : 0; }

static inline void uart_putc(uint8_t c) {
    while (uart_tx_busy()) { /* espera liberar */ }
    REG8(UART_DATA) = c;
}

static inline int uart_getc_nonblock(void) {
    if (uart_rx_available()) return (int)REG8(UART_DATA);
    return -1;
}

// static void uart_print(const char *s) {
//     while (*s) { if (*s == '\n') uart_putc('\r'); uart_putc((uint8_t)*s++); }
// }

// static void uart_putdec32(uint32_t v) {
//     char buf[11]; int i = 10; buf[i] = 0;
//     if (v == 0) { uart_putc('0'); return; }
//     while (v && i) { buf[--i] = '0' + (v % 10); v /= 10; }
//     uart_print(&buf[i]);
// }

// static void test_tx_stream_U(void) {
//     for (;;) {
//         uart_putc('U');
//         uint32_t t0 = mtime();
//         while ((uint32_t)(mtime() - t0) < 2000) { } // pequeno delay (~2 ms)
//     }
// }

int main(void)
{
    // Se RX usar ui_in[7], mantenha 0:
    REG8(UART_RXDSEL) = 0;

    // Reafirme baud=115200 a 25 MHz (se CLOCK_HZ=25e6 na sua build):
    REG32(UART_BAUD) = (uint32_t)(25000000u / 115200u);

    // ===== TX contínuo de 'U' (0x55) =====
    for (;;) {
        while (REG8(UART_STATUS) & 0x01) { /* tx_busy */ }
        REG8(UART_DATA) = 'U';
    }
}


