<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->
## Simplified CAN bus Controller

Author: Jesus Arias

Peripheral index: 7 

## What it does

This peripheral is a simplified CAN bus controller. A more detailed descriprion is included in the [PDF file](07_CANPerif.pdf)

## Register map

Document the registers that are used to interact with your peripheral.
All registers are 32-bit wide and are located at addresses multiple of 4:

| Address | Name  | Access | Description                                                          |
|---------|-------|--------|----------------------------------------------------------------------|
| 0x00    | ID    |   R    | bits <28:0>: received ID (only bits <10:0> valid for standard frames)|
|         |       |        | bit 30: RTR (remote request)                                         |
|         |       |        | bit 31: EXT (extended frame with 29-bit ID)                          |
|         |       |        |  (reading this reg. clears the FRMAV flag)                           |
|         |       |   W    | Same fields for transmitting                                         |
|---------|-------|--------|----------------------------------------------------------------------|
| 0x04    | DLCF  |  R/W   | DLC field, flags, baud divider, interrupt enable                     |
|         |       |        | bits <3:0> (R/W): DLC (rx DLC on reads, tx DLC on writes)            |
|         |       |        | bit 4 (RO): STUFF. Stuffing bit error on rx                          |
|         |       |        | bit 5 (RO): CRC. CRC error on rx                                     |
|         |       |        | bit 6 FRMAV (RO): Valid frame available on rx                        |
|         |       |        | bit 7 OVWR (RO): Overwrite. Frame received while FRMAV set           |
|         |       |        | bit 8 RTS (R/W): Request to send. Set to tx. Cleared when tx complete|
|         |       |        | bit 9 LOST (RO): Lost arbitration on tx                              |
|         |       |        | bit 10 BITER (RO): Bit error on tx (bus level != can_tx)             |
|         |       |        | bit 11 ACK (RO): tx frame was acknowledged by a receiver             |
|         |       |        | bits <25:16> (R/W): BAUDDIV. Bit rate = f_clk / (BAUDDIV+1)          |
|         |       |        | bit 29 INTERX (R/W): Enable rx interrupt (when FRMAV is set)         |
|         |       |        | bit 30 INTERR (R/W): Enable rx error interrupt (SFUFF or CRC set)    |
|         |       |        | bit 31 INTTX (R/W): Enable tx interrupt (when RTS is zero)           |
|---------|-------|--------|----------------------------------------------------------------------|
| 0x08    | DATA0 |   R    | Received data (bytes #0 to #3)                                       |
|         |       |   W    | Data to transmit (bytes #0 to #3)                                    |
|---------|-------|--------|----------------------------------------------------------------------|
| 0x0C    | DATA1 |   R    | Received data (bytes #4 to #7)                                       |
|         |       |   W    | Data to transmit (bytes #4 to #7)                                    |
|---------|-------|--------|----------------------------------------------------------------------|


## How to test

Frame sending:
- Write DATA0, and DATA1 if DLC>4, with the data of the frame.
- Write ID with the ID of the frame. Set bit #31 if this is an extended frame with a 29-bit ID. Set
  bit #30 if this is a Remote Request (RTR) frame.
- Write DLCF with the DLC value, the proper Baud divider, and bit #8 (RTS) set.
- Wait until RTS goes low.
- Check for ACK in DLCF. If not set check for lost arbitration or bit errors and repeat the procedure.
  (notice that all registers have to be rewritten after a transmission)

Frame receiving:
- Write DLCF with the proper Baud divider.
- Wait until FRMAV in DLCF is set. If STUFF or CRC are set instead a wrong frame was received (it 
  can be discarded)
- Read the DATA0 and DATA1 registers. The number of valid bytes is in the DLC field of the DLCF reg.
- Read the ID register. This clears the FRMAV flag and a new frame can be received.
  (after FRMAV gets set we have a minimum time of 28 CAN bits before an overwriting error)


## External hardware

CAN_TX output is located on uo_out[1]. CAN_RX input is located on ui_in[1]. These pins ough to be
connected to a can bus transceiver in order to communicate with other nodes in the CAN bus.


