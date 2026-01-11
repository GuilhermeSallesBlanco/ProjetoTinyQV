#include <stdint.h>
#define REG32(a) (*(volatile uint32_t*)(a))

// FUNC_SEL por pino: base 0x8000060, 4 bytes por pino
#define GPIO_FUNC_SEL_BASE  0x8000060u

// Simple peripherals: base 0x8000400
#define SIMPLE_BASE         0x8000400u
#define LED_SIMPLE_SLOT     0
#define LED_CTRL            (SIMPLE_BASE + (LED_SIMPLE_SLOT<<4) + 0x0)
#define LED_STAT            (SIMPLE_BASE + (LED_SIMPLE_SLOT<<4) + 0x1)
#define MTIME               0xFFFFF00u

static inline void gpio_set_func_sel_simple(unsigned pin, unsigned slot) {
    // bit4=1 (simple), bits3:0=slot
    uint32_t val = (1u<<4) | (slot & 0xF);
    REG32(GPIO_FUNC_SEL_BASE + 4*pin) = val;
}

static void delay_us(uint32_t us) {
    uint32_t t0 = REG32(MTIME);
    while ((uint32_t)(REG32(MTIME) - t0) < us) { }
}

int main(void) {
    gpio_set_func_sel_simple(0, LED_SIMPLE_SLOT);  // uo_out[0] -> simple slot 0

    for (;;) {
        (*(volatile uint8_t*)LED_CTRL) = 1;  // se ativo-baixo: 1 => ~led_state=0 => apaga
        delay_us(200000);
        (*(volatile uint8_t*)LED_CTRL) = 0;  // 0 => ~led_state=1 => acende
        delay_us(200000);
    }
}
