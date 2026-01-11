<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

The peripheral index is the number TinyQV will use to select your peripheral.  You will pick a free
slot when raising the pull request against the main TinyQV repository, and can fill this in then.  You
also need to set this value as the PERIPHERAL_NUM in your test script.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

# 8-bit RSA encryption peripheral

Author: Caio Alonso da Costa

Peripheral index: 29


## What it does

This project consists of an 8-bit RSA verilog design that implements the RSA (https://en.wikipedia.org/wiki/RSA_(cryptosystem)) encryption/decryption scheme with an 8-bit private/public key size.

The design implements modular exponentiation (https://en.wikipedia.org/wiki/Modular_exponentiation) through a series of Montgomery modular multiplication (https://en.wikipedia.org/wiki/Montgomery_modular_multiplication) to encrypt/decrypt a message using an 8-bit key.


## Register map

| Address | Name            | Access | Description                                                         |
|---------|---------------- |--------|---------------------------------------------------------------------|
| 0x00    | Test            | R/W    | Test register - Write to it and read it back for sanity check       |
| 0x01    | Command         | R/W    | Command - Control start/stop RSA encryption                         |
| 0x02    | Plain Data      | R/W    | Plain Data - Data to be encrypted                                   |
| 0x03    | Key Exponent    | R/W    | Key - Exponent                                                      |
| 0x04    | Key Modulus     | R/W    | Key - Modulus                                                       |
| 0x05    | Montgomery Const| R/W    | Montgomery Constant                                                 |
| 0x06    | Encrypted Data  | RO     | Encrypted Data - Data after encryption process                      |
| 0x07    | Status          | RO     | Status of encryption process                                        |


## Command Register

| Bit index       | Description  |
| --------------- | ---------- |
| 0               | Start RSA encryption process - Write 1'b1 to start(*) |
| 1               | Stop RSA encryption process - Write 1'b1 to stop(*)   |
| 3 - 7           | Not applicable                                        |

(*)Both registers feed a rising edge detection circuit.
In order to start a new encryption process once the current process is done, it is required to write the value 1'b0 followed by a 1'b1 on bit index 0 of the Command register.

## Status Register

| Bit index       | Description  |
| --------------- | ---------- |
| 0               | Encprytion completed(*) |
| 1 - 7           | Return '0 |

(*)Once the encryption process is completed, the bit 0 will be 1'b1. The status remains 1'b1 until a new encryption process is started through the Command register.


## How to test

Key generation example:
1. Choose two large prime numbers p and q : p = 7, q = 13
2. Compute n = p * q : n = 91
3. Compute Euller totient function φ(n) = (p - 1) * (q - 1) : φ(n) = 72
4. Choose an integer e such that 1 < e < φ(n) and gcd(e, φ(n)) = 1: e = 11
5. Determine d as d ≡ e^(−1) (mod φ(n)); that is, d is the modular multiplicative inverse of e modulo φ(n) : d = 59

Private key {e, n} = {11, 91}

Public key  {d, n} = {59, 91}

The plain text is limited to a number in the interval [0:91[, as per this example.
Since the design uses the Montgomery mutiplication, a Montgomery Constant shall be used to map the plain text into the Montgomery integer domain.

6. Compute Montgomery constant (fixed value that depends only on the value of p and q and the max-key lenght of the RSA core implementation).

Const = (2 ** (2 * hwbits)) mod n, where hwbits = (8 (RSA max key-lenght core support) + 2).

Const = (2 ** (2 * (8+2))) mod 91 = 74

Steps for start an/a encryption/decryption process:
1. Write any value between 0 and n-1 to the Plain Data register. Value suggested: 12
2. Write to the Key Exponent register the value of e: 11
3. Write to the Key Modulus register the value of n: 91
4. Write to the Montgomery Const register the value of const: 74
5. Write to the Command the value 1 - (Trigger the start encryption command).
6. Poll the Statys register for the value 1 - Encryption process done.
7. Read the Encrypted data register. Valeu expected: 38.

12 ^ 11 mod 91 = 743008370688 mod 91 = 38



## External hardware

Not required.
