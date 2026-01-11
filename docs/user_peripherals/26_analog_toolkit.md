# Analog toolkit peripheral

Author: htfab

Peripheral index: 26

## What it does

Allows building low frequency ADCs, DACs, capacitive sensors etc. using passives only

## Register map

| Address | Name  | Access | Description                                                         |
|---------|-------|--------|---------------------------------------------------------------------|
| 0x00    | OUT0  | W      | Output channel 0 duty cycle: 1b sign, 4b exponent, 3b mantissa      |
| 0x01    | OUT1  | W      | Output channel 1 duty cycle: 1b sign, 4b exponent, 3b mantissa      |
| 0x02    | OUT2  | W      | Output channel 2 duty cycle: 1b sign, 4b exponent, 3b mantissa      |
| 0x03    | IN    | R      | Selected input duty cycle: 1b sign, 4b exponent, 3b mantissa        |
| 0x04    | DIV   | W      | Clock divider: 4b exponent, 4b mantissa                             |
| 0x05    | CH    | W      | Input channel number (0 to 7)

## How to test

Build one of the test circuits:

- ADC
  - connect `ui_in[0]` to the wiper of a 10k linear potmeter on a breadboard
  - add a 100nF capacitor between `ui_in[0]` and `uo_out[1]`
  - connect the other contacts of the potmeter to 3.3V and ground respectively
  - set DIV (register 4) to 0x60 (~64Hz clock)
  - set OUT0 (register 0) to 0x80 (1/2 duty cycle)
  - set CH (register 5) to 0 (set input to `ui_in[0]`)
  - read IN (register 3) for ADC values
  - it won't be perfectly linear but sweeping along the middle 75% of the potmeter's path
    should cover a reasonable range of values, say, 64 to 192

- DAC
  - create an RC low-pass filter from a resistor and
    a capacitor attached to `uo_out[1]`
  - generate a PWM signal by setting the frequency
    using DIV (register 4) and the duty cycle using
    OUT0 (register 0)
  - the low-pass filter should smooth the PWM output
    to a an average voltage corresponding to the
    duty cycle

- Capacitive sensor
  - connect the touch pad (or just two wires) to
    `ui_in[0]` and `uo_out[1]`
  - set DIV (register 4) to 0x60 (~64Hz clock)
  - set OUT0 (register 0) to 0x80 (1/2 duty cycle)
  - set CH (register 5) to 0 (set input to `ui_in[0]`)
  - read IN (register 3) for a value that depends on
    the capacitance between `ui_in[0]` and `uo_out[1]`
  - tweak DIV (register 4) to make the sensor
    more sensitive in the capacitance range you are
    interested in

- LED dimmer
  - connect an LED to `uo_out[1]` and ground, using a
    series resistor appropriate for the LED voltage
    drop and current rating, assuming Vcc of 3.3V
  - set DIV (register 4) to 0xa0 (~1kHz clock)
  - set OUT0 (register 0) to tweak the PWM duty cycle
  - the range 0x00 to 0x7f maps to the duty cycle
    in a quasi-exponential way, and the human eye
    percieves brightness in a quasi-logarithmic
    way, so you should see a smooth ramp in
    apparent brightness as you tweak the values
  - you can add two more LEDs to `uo_out[2]` and
    `uo_out[3]` and set their brightness using
    OUT1 (register 1) and OUT2 (register 2)
    respectively

## External hardware

Depending on the circuit you want to build it might be useful to have a few

- ceramic capacitors (100nF)
- resistors (100Ω, 10kΩ, 1MΩ)
- potmeters (10kΩ linear)
- standard through-hole LEDs
- and a breadboard with some wires
