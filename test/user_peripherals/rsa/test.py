# SPDX-FileCopyrightText: © 2025 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import math
import random

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

from tqv import TinyQV

# When submitting your design, change this to 16 + the peripheral number
# in peripherals.v.  e.g. if your design is i_user_simple00, set this to 16.
# The peripheral number is not used by the test harness.
PERIPHERAL_NUM = 16+13

# Return bit value from bit index
def get_bit(value, bit_index):
  temp = value & (1 << bit_index)
  return temp

# Montgomey modular multiplication
def mmm (a, b, m, nbits):
  r = 0
  idx = 0
  while idx < nbits:
    r0 = r % 2
    b0 = b % 2
    a_bit = ( get_bit(a, idx) >> idx )
    q0 = r0 + b0 * a_bit
    q0 = q0 % 2
    r = ( r + a_bit * b + q0 * m ) // 2
    idx = idx + 1
  return r;

# Montgomey modular exponentiation
def mem (p, e, m, nbits):
  # Mapping constant
  const_m = (2 ** (2 * nbits)) % m

  # Mapping
  p_int = mmm (const_m, p, m, nbits)
  r_int = mmm (const_m, 1, m, nbits)

  cocotb.log.info(f"MEM mapping P, R: ( {p_int}, {r_int} )")
  
  idx = 0
  while idx < nbits:
    if ( ( get_bit(e, idx) >> idx ) == 1 ):
      r_int = mmm (r_int, p_int, m, nbits)
    
    p_int = mmm (p_int, p_int, m, nbits)
    cocotb.log.info(f"MEM idx, P, R: ( {idx}, {p_int}, {r_int} )")
    idx = idx + 1

  # Remapping  
  r = mmm (1, r_int, m, nbits)
  return r

# Prime check
def is_prime(num):
  if (num <= 2) :
    return 0;
  else :
    # Iterate from 2 to n // 2
    for i in range(2, ((num // 2) + 1)) :
      # If num is divisible by any number between
      # 2 and n / 2, it is not prime
      if (num % i) == 0:
        #print(num, "is not a prime number")
        return 0

    return 1


@cocotb.test()
async def test_rsa(dut):
    dut._log.info("Start")
    
    # Set the clock period to 100 ns (10 MHz)
    clock = Clock(dut.clk, 100, units="ns")
    cocotb.start_soon(clock.start())
    
    # Interact with your design's registers through this TinyQV class.
    # This will allow the same test to be run when your design is integrated
    # with TinyQV - the implementation of this class will be replaces with a
    # different version that uses Risc-V instructions instead of the SPI 
    # interface to read and write the registers.
    tqv = TinyQV(dut, PERIPHERAL_NUM)
    
    # Reset, always start the test by resetting TinyQV
    await tqv.reset()
    
    dut._log.info("Test project behavior")
    
    # Test register write and read back
    await tqv.write_reg(0, 20)
    assert await tqv.read_reg(0) == 20
    
    # Check output is the same as Test register
    assert dut.uo_out.value == await tqv.read_reg(0)
    
        
    # Number of bits in implementation
    bits = 8
    max_value = (2 ** bits) - 1
    min_prime = 3
    max_upper_boundary = max_value // min_prime
    
    
    # ITERATIONS 
    iterations = 0
    
    while iterations < 100:
        
        cocotb.log.info(f"Start of iteration: {iterations}")
        
        while True:
            p = random.randint(min_prime, max_upper_boundary)
            p_is_prime = is_prime(p)
            q = random.randint(min_prime, max_upper_boundary)
            q_is_prime = is_prime(q)
            m = p * q
            #cocotb.log.info(f"RSA RANDOM, P: {p}, Q: {q}, M: {m}")
            if ( ( m <= max_value ) and ( p != q ) and ( p_is_prime == 1 ) and ( q_is_prime == 1 ) ):
                break
            
        phi_m = (p-1) * (q-1)
        cocotb.log.info(f"RSA, P: {p}, Q: {q}, M: {m}, PHI(M): {phi_m}")
        
        while True:
            e = random.randint(min_prime, phi_m)
            #e_is_prime = is_prime(e)
            e_gdc = math.gcd(e, phi_m)
            #if ( ( e < phi_m ) and ( e_is_prime == 1 ) ):
            if ( ( e < phi_m ) and ( e_gdc == 1 ) ):
                break
            #if (cryptomath.gcd(e, phi_m) == 1):
            #  break
            
        cocotb.log.info(f"Public key: ( {e}, {m} )")
        
        # DEBUG
        #p = 3
        #q = 11
        #m = p * q
        #phi_m = (p-1) * (q-1)
        #e = 7
        # DEBUG
        
        #d = invmod(e, phi_m)  ->  d*e == 1 mod phi_m
        d = pow(e, -1, phi_m)
        #d = cryptomath.findModInverse(e, phi_m)
        
        cocotb.log.info(f"Private key: ( {d}, {m} )")
        
        # Number of bits for RSA implementation
        hwbits = bits + 2
        # DEBUG
        #hwbits = 8 + 2
        # DEBUG
        
        # Montgomery constant
        const = (2 ** (2 * hwbits)) % m
        
        cocotb.log.info(f"Montgomery constant: {const}")
        
        while True:
            plain_text = random.randint(0, m-1)
            if (plain_text != 0):
                break
            
        cocotb.log.info(f"Plain text: {plain_text}")
        
        # DEBUG
        #plain_text = 0x1
        #plain_text = 0x2
        #plain_text = 0x58
        # DEBUG
        
        #cocotb.log.info(f"RSA, P: {p}, Q: {q}, M: {m}, PHI(M): {phi_m}")
        #cocotb.log.info(f"Public key: ( {e}, {m} )")
        #cocotb.log.info(f"Private key: ( {d}, {m} )")
        #cocotb.log.info(f"Montgomery constant: {const}")
        #cocotb.log.info(f"Plain text: {plain_text}")
        
        # Write plain data
        await tqv.write_reg(2, plain_text)
        # Write key exponent ( e )
        await tqv.write_reg(3, e)
        # Write key modulus( m )
        await tqv.write_reg(4, m)
        # Write Montgomery constant ( const )
        await tqv.write_reg(5, const)
        # Write Command register ( start )
        await tqv.write_reg(1, 1)
        
        # Predict encrypted text using standard encryption formula
        encrypted_text = ( plain_text ** e ) % m
        cocotb.log.info(f"Encrypted text: {encrypted_text}")
        
        # Predict encrypted text using Modular exponentiation algorithm with Montgomery Modular Multiplication
        encrypted_text_mem = mem (plain_text, e, m, hwbits)
        cocotb.log.info(f"Encrypted text MMExp: {encrypted_text_mem}")
        
        # Predict decrypted message
        decrypted_text = ( encrypted_text ** d ) % m
        cocotb.log.info(f"Decrypted text: {decrypted_text}")
        
        # Give enough time to finish encryption process
        await ClockCycles(dut.clk, 150)
        
        # Read status register and assert that IRQ is set high
        assert await tqv.read_reg(7) == 1
        
        # Read encrypted text ( encrypted_text_design )
        encrypted_text_design = await tqv.read_reg(6)
        cocotb.log.info(f"Encrypted text design: {encrypted_text_design}")
        
        # Sanity checks
        assert plain_text == decrypted_text
        assert encrypted_text == encrypted_text_mem
        assert encrypted_text == encrypted_text_design

        # Write Command register ( deassert start )
        await tqv.write_reg(1, 0)
        
        cocotb.log.info(f"End of iteration: {iterations}")
        
        iterations = iterations + 1
        
    await ClockCycles(dut.clk, 10)
