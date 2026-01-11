#define LED_ADDR (*(volatile unsigned int*)0x80000200)

void delay() {
    for (volatile int i = 0; i < 500000; i++);
}

int main() {
    while (1) {
        LED_ADDR = 1;
        delay();
        LED_ADDR = 0;
        delay();
    }
}
