volatile int counter = 0;

void main() {
    for (int i = 0; i < 100000; i++) {
        counter++;
    }
}