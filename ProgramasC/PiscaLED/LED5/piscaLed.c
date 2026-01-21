
#include <stdint.h>
#include <gpio.h>  // set_debug_sel, set_gpio_func, set_outputs, get_outputs

// --- delay usando MTIME (1 MHz) ---
// TIME.MTIME está em 0xFFFFF00 no TinyQV.
static inline uint32_t mtime_us(void) {
  return *(volatile uint32_t*)0xFFFFF00;
}
static void delay_us(uint32_t us) {
  uint32_t start = mtime_us();
  while ((uint32_t)(mtime_us() - start) < us) { /* busy-wait */ }
}

// --- configurações ---
#define LED_PIN        7       // use 7 se seu LED está em uo_out[7] (L2 na i9 v7.2)
#define LED_ACTIVE_LOW 1       // 1 = pino em '0' acende; 0 = pino em '1' acende

static inline void led_write(int on) {
  // Lê o OUT atual, zera o bit do LED, e escreve com o bit conforme a polaridade.
  uint32_t out = get_outputs();
  uint32_t mask = (1u << LED_PIN);

#if LED_ACTIVE_LOW
  // ativo-baixo: '0' = ON, '1' = OFF
  out = (on ? (out & ~mask) : (out | mask));
#else
  // ativo-alto: '1' = ON, '0' = OFF
  out = (on ? (out | mask) : (out & ~mask));
#endif

  set_outputs(out);
}

int main(void) {
  // 1) Libera overlay de debug e deixa periféricos dirigirem os pinos
  //    (DEBUG.SEL=0xff e register_debug=0)
  enable_all_outputs();

  // 2) Garante que o pino LED_PIN é dirigido pelo GPIO (func=1)
  set_gpio_func(LED_PIN, 1);

  // 3) Blink: alterna somente o bit do LED
  for (;;) {
    led_write(1);
    delay_us(100000);       // 200 ms
    led_write(0);
    delay_us(100000);
  }
  return 0;
}
