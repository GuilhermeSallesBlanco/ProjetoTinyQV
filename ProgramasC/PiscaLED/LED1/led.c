#define LED_BASE 0x80002000
#define LED_REG (*(volatile unsigned int*)LED_BASE)

static void delay(volatile int t)
{
    while (t--) ;
}

int main(void)
{
    while (1)
    {
        LED_REG = 1;   // liga LED
        delay(2000);

        LED_REG = 0;   // desliga LED
        delay(2000);
    }
}
