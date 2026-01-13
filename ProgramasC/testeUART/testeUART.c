
// uart_diag.c  —  Teste de UART para TinyQV + Colorlight i9
#include <stdint.h>

//=================== Config de clock/baud ===================//
#define CLOCK_HZ        25000000u   // 25 MHz (ajuste se necessário)
#define BAUD            115200u
#define UART_DIVISOR    (CLOCK_HZ / BAUD)

// Se quiser usar ui_in[3] como RX, defina 1:
#define RX_USE_UI3      0

//=================== MMIO mapeamento UART ===================//
// user peripherals: base 0x800_0100, 64 bytes por índice
#define USER_BASE       0x8000100u
#define UART_INDEX      2u
#define UART_BASE       (USER_BASE + (UART_INDEX << 6))  // 0x800_0180

#define UART_DATA       (UART_BASE + 0x00)   // W: TX byte ; R: RX byte
#define UART_STATUS     (UART_BASE + 0x04)   // bit0=tx_busy, bit1=rx_buf
#define UART_BAUD       (UART_BASE + 0x08)   // rw divisor (LSB..)
#define UART_RXDSEL     (UART_BASE + 0x0C)   // 0=ui_in[7], 1=ui_in[3]

// Opcional: MTIME (se implementado no seu SoC)
#define CSR_TIME_LO     0xFFFFF00u  // ajuste se seu endereço for diferente
static inline uint32_t mtime(void) { return *(volatile uint32_t*)CSR_TIME_LO; }

// Acesso 8/32 bits
#define REG8(a)   (*(volatile uint8_t  *)(a))
#define REG32(a)  (*(volatile uint32_t *)(a))

//=================== Funções UART ===================//
static inline void uart_set_baud(uint32_t div)
{
    // Para o wrapper: basta escrever o valor; ele foi feito para aceitar até 13 bits
    REG32(UART_BAUD) = div;
}

static inline void uart_set_rxd_source(uint8_t use_ui3)
{
    // 0 => RX = ui_in[7] ; 1 => RX = ui_in[3]
    REG8(UART_RXDSEL) = (use_ui3 ? 1 : 0);
}

static inline uint8_t uart_tx_busy(void)
{
    return (REG8(UART_STATUS) & 0x01) ? 1 : 0;
}

static inline uint8_t uart_rx_available(void)
{
    return (REG8(UART_STATUS) & 0x02) ? 1 : 0;
}

static inline void uart_putc(uint8_t c)
{
    while (uart_tx_busy()) { /* espera liberar */ }
    REG8(UART_DATA) = c;
}

static inline int uart_getc_nonblock(void)
{
    if (uart_rx_available()) {
        return (int)REG8(UART_DATA);
    }
    return -1;
}

static void uart_print(const char *s)
{
    while (*s) {
        if (*s == '\n') uart_putc('\r');
        uart_putc((uint8_t)*s++);
    }
}

// Envia 2 hex dígitos
// static void uart_puthex8(uint8_t v)
// {
//     const char *h = "0123456789ABCDEF";
//     uart_putc(h[(v >> 4) & 0xF]);
//     uart_putc(h[(v >> 0) & 0xF]);
// }

static void uart_putdec32(uint32_t v)
{
    char buf[11]; int i = 10; buf[i] = 0;
    if (v == 0) { uart_putc('0'); return; }
    while (v && i) { buf[--i] = '0' + (v % 10); v /= 10; }
    uart_print(&buf[i]);
}

//=================== Modos de teste ===================//
static void test_tx_stream_U(void)
{
    // Loop de diagnóstico TX‑apenas (manda 'U' continuamente)
    // Útil para ver “alguma coisa” no terminal ou analisador lógico
    for (;;) {
        uart_putc('U');
        // pequeno atraso para não lotar a porta:
        uint32_t t0 = mtime();
        while ((uint32_t)(mtime() - t0) < 2000) { } // ~2 ms a depender do timebase
    }
}

//=================== main ===================//
int main(void)
{
    // 1) Ajusta fonte do RX: 0=ui_in[7] (padrão do wrapper), 1=ui_in[3].
    uart_set_rxd_source(RX_USE_UI3 ? 1 : 0);

    // 2) Ajusta baud para 115200 a partir de CLOCK_HZ
    uart_set_baud(UART_DIVISOR);

    // 3) Mensagens iniciais
    uart_print("\n\n=== TinyQV UART Diag ===\n");
    uart_print("Clock: "); uart_putdec32(CLOCK_HZ); uart_print(" Hz\n");
    uart_print("Baud:  "); uart_putdec32(BAUD);     uart_print("\n");
    uart_print("DIV:   "); uart_putdec32(UART_DIVISOR); uart_print("\n");
    uart_print("RX pin: ui_in["); uart_putc(RX_USE_UI3 ? '3' : '7'); uart_print("]\n");
    uart_print("(Digite algo: eco habilitado; '!' liga modo TX='U' continuo)\n");

    // 4) Loop principal: eco + comando especial
    for (;;) {
        int ch = uart_getc_nonblock();
        if (ch >= 0) {
            if (ch == '!') {
                uart_print("\n[Entrando no modo TX continuo de 'U'...]\n");
                test_tx_stream_U(); // não retorna
            }
            // eco com CRLF amigável
            if (ch == '\n') uart_putc('\r');
            uart_putc((uint8_t)ch);
        }
    }
}
