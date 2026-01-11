# Neural Processing Unit (NPU)

Author: Sohaib Errabii

Peripheral index: 4

## What it does

This peripheral implements a processing unit for running 4bit quantized models that follows the integer-only quantization specification 
of google's litert (see https://ai.google.dev/edge/litert/models/quantization_spec or https://arxiv.org/abs/1712.05877).

The peripheral contains four int4 MACs in chain, an int16 accumulation register and a scaler unit
for scaling the int16 accumulation back to int4 by performing a saturating mulh between uint15 and int16 (3bits at a time for a latency of 6cycles).
![NPU Diagram](04_npu_diagram.svg)


## Register map

Document the registers that are used to interact with your peripheral

| Address   | Name    | Access   | Description                                                                   |
| --------- | ------- | -------- | ----------------------------------------------------------------------------- |
| 0x01      | DAT     | W        | packed 4 int4 weights and 4 int4 activations to send to the mac array         |
| 0x02      | ACC     | RW       | Initialize or read the int16 accumulation register                            |
| 0x04      | SHAMT   | W        | The shift amount used for scaling the output, must be in range [0, 31]        |
| 0x08      | QMUL    | W        | The uin15 quantized multiplier used for scaling the output                    |
| 0x10      | RELU_ZP | W        | data_in[0] whether to apply RELU / data_in[1:4] output int4 zero point        |

## How to test

test/utils.py contains some helper functions for running a fully connected layer on the peripheral.
The function 'qfc' stands for quantized fully connected which is the software baseline.
'tb_qfc' is the cocotb equivalent that drives the peripheral. Both are implemented to tile in software a fully connected layer of arbitrary
dimensions for running on the small 4x1 macarray and accumulation register.
However, since the accumulation register is int16 there is risk of overflow starting from a reduce dimension of 512.

test.py has two tests.
The first one runs a tests of the same dimensions as the peripheral (weights of shape [4, 1] and a single activation row [1, 4])

The second one runs a toy two layer MLP model pretrained on mnist (see assets/model.json. The weights/bias are stored in assets/tensors.bin). 
It takes a dozen seconds to perform inference for a single 12x12 MNIST image.

`FAST=1 make -C test -B` to only run the trivial test. `FAST=1` to also run the MNIST model.
