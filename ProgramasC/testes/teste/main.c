#include <stdio.h>

volatile int counter = 0;

int main(void) {
    while (1) {
        counter++;
	counter--;
    }
    return 0;
}
