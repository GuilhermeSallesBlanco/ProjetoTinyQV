/*
 * Copyright (c) 2025 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_tqv_jesari_CAN (
    input         clk,          // Clock - the TinyQV project clock is normally set to 64MHz.
    input         rst_n,        // Reset_n - low to reset.

    input  [7:0]  ui_in,        // The input PMOD, always available.  Note that ui_in[7] is normally used for UART RX.
                                // The inputs are synchronized to the clock, note this will introduce 2 cycles of delay on the inputs.

    output [7:0]  uo_out,       // The output PMOD.  Each wire is only connected if this peripheral is selected.
                                // Note that uo_out[0] is normally used for UART TX.

    input [5:0]   address,      // Address within this peripheral's address space
    input [31:0]  data_in,      // Data in to the peripheral, bottom 8, 16 or all 32 bits are valid on write.

    // Data read and write requests from the TinyQV core.
    input [1:0]   data_write_n, // 11 = no write, 00 = 8-bits, 01 = 16-bits, 10 = 32-bits
    input [1:0]   data_read_n,  // 11 = no read,  00 = 8-bits, 01 = 16-bits, 10 = 32-bits
    
    output [31:0] data_out,     // Data out from the peripheral, bottom 8, 16 or all 32 bits are valid on read when data_ready is high.
    output        data_ready,

    output        user_interrupt  // Dedicated interrupt request for this peripheral
);
	// changing the bus interface to LaRVa's...

	// Chip select: only 32-bit wide reads & writes allowed
	wire cs = (data_write_n==2'b10) | (data_read_n==2'b10);
	// write lanes
	wire [3:0]bsel = (data_write_n==2'b10) ? 4'b1111 : 4'b0000;

	// peripheral instance
	wire irqrx, irqrxerr, irqtx, can_tx, can_rx;
	CAN CAN0 (
		.clk(clk), .reset(~rst_n),
		.cs(cs), 
		.rs(address[3:2]),
		.bytesel(bsel),
		.d(data_in),
		.q(data_out),
		.irqrx(irqrx),
		.irqrxerr(irqrxerr),
		.irqtx(irqtx),
		.can_tx(can_tx),
		.can_rx(can_rx)
	);
	assign user_interrupt = irqrx | irqrxerr | irqtx;
	assign can_rx = ui_in[1];
	assign uo_out[1] = can_tx;
	assign data_ready = 1'b1;
	
    // List all unused inputs to prevent warnings
    // data_read_n is unused as none of our behaviour depends on whether
    // registers are being read.
    wire _unused = &{ui_in[0], ui_in[7:2], address[5:4], address[1:0], 1'b0};
	assign uo_out[7:2]=6'b0;
	assign uo_out[0]=1'b0;

endmodule


///////////////////////////////////////////////////////////////////////////////
//                  simplified CAN bus controller                            //
//                       Jesús Arias (2022)                                  //
//                                                                           //
// Public Domain code (bugs included).                                       //
///////////////////////////////////////////////////////////////////////////////


module CAN (
	input 	clk,		// Main clock input
	input   reset,		// async reset

	// Core interface
	input 	cs,				// Peripheral chip select
	input 	[1:0]rs,		// Register select
	input 	[3:0]bytesel,	// Byte select for writes
	output 	[31:0]q,		// output bus
	input	[31:0]d,		// input bus

	// IRQs
	output	irqrx,			// Valid frame received
	output	irqrxerr,		// received errors
	output	irqtx,  		// Ready to transmit
	
	// CAN lines
	input	can_rx,			// receiver input
	output 	can_tx			// Transmitter output
	
);

//////////////// System interface //////////////
wire csid   = cs & (~rs[1]) & (~rs[0]);
wire csdlcf	= cs & (~rs[1]) & ( rs[0]);
wire csdata0= cs & ( rs[1]) & (~rs[0]);
wire csdata1= cs & ( rs[1]) & ( rs[0]);

// output register mapping
assign q =
	(csid    ? {ext,rtr,1'b0,rx_id} : 0) |
	(csdlcf  ? {irqen,3'h0,bauddiv,4'h0,ackf,bitf,lostf,rts,ovwr,frmav,crcerr,stufferr,dlc} : 0) |
	(csdata0 ? {rdata[3],rdata[2],rdata[1],rdata[0]} : 0 ) |
	(csdata1 ? {rdata[7],rdata[6],rdata[5],rdata[4]} : 0 ) ;

assign irqrx=irqen[0]& frmav;
assign irqrxerr=irqen[1]&(stufferr|crcerr);
assign irqtx=irqen[2]&(~rts);
	
//////////////// BAUD reg ////////////////

reg [9:0]bauddiv; //=10'h3FF;
reg [2:0]irqen; //=0;

always @(posedge clk or posedge reset) 
	if (reset) begin 
		bauddiv<=0; 
		irqen <= 0;
	end else if (csdlcf & bytesel[3] & bytesel[2]) begin 
		bauddiv <= d[25:16];
		irqen   <= d[31:29];
	end

/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
//                      CAN RECEIVER
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////

/// clock sync
reg [1:0]rrxd; //=2'b11; // RXD, muted during TX, and registered 2 times
always @(posedge clk or posedge reset) 
	if (reset) rrxd<= 2'b11; else rrxd<={rrxd[0],can_rx|txing};
wire resinc = rrxd[0]^rrxd[1];	// change at the input if 1

reg [9:0] divrx; //=0;		// Clock divider
wire sample= (divrx==({1'b0,bauddiv[9:1]})); // Sampling pulse (at half bit time)
wire clki0 = (divrx==0);	// Bit end (full bit time)
always @ (posedge clk or posedge reset) 
	if (reset) divrx <= 0;
	else divrx <= (resinc|clki0) ? bauddiv: divrx-1;

// Bit destuffing
reg [4:0]lastbits; //=0;
always @ (posedge clk) if (sample) lastbits<={lastbits[3:0],rrxd[0]};
wire stuffbit = (lastbits==5'h0) || (lastbits==5'h1f);
wire errorfrm = (lastbits==5'h0)&(~rrxd[0]);
wire passive = (lastbits==5'h1f)&rrxd[0];

// Input sample reg
reg [20:0]sh;	//=0;
// Note: delay required due to t_hold simulation issues
always @ (posedge clk) if (sample&(~stuffbit)) sh<={sh[19:0],rrxd[0]};

// State names
parameter IDLE		= 3'b000;
parameter IDSTD		= 3'b001;
parameter IDEXT		= 3'b010;
parameter DLC 		= 3'b011;
parameter DATA		= 3'b100;
parameter CRC		= 3'b101;
parameter ACK		= 3'b110;
parameter ERR		= 3'b111;

reg [2:0]st;
wire btc=(~stuffbit)&bittc;
//wire extbit=sh[1];

always @(posedge clk or posedge reset)
if (reset) st<=IDLE; else
begin
  if (sample)
     case (st)
        IDLE:   if (~rrxd[0]) st<=IDSTD;
		IDSTD:	st<=errorfrm ? ERR : (passive ? IDLE : (btc ? (sh[1]? IDEXT : DLC) : IDSTD));
		IDEXT:	st<=errorfrm ? ERR : (passive ? IDLE : (btc ? DLC:IDEXT));
		DLC:	st<=errorfrm ? ERR : (passive ? IDLE : (btc ? (((sh[3:0]!=0)&(~rtr)) ? DATA : CRC):DLC));
		DATA:	st<=errorfrm ? ERR : (passive ? IDLE : (btc ? CRC:DATA));
		CRC:	st<=errorfrm ? ERR : (passive ? IDLE : (btc ? ((~badcrc)?ACK:IDLE):CRC));
		ACK:	if (bittc) st<=IDLE;
		ERR:	if (rrxd[0]) st<=IDLE;
        endcase
end

wire [5:0]nbits=
	((st==IDLE)? 6'd15: 0) |
	((st==IDSTD)? (sh[1]? 6'd20:6'd4): 0) |
	((st==IDEXT)? 6'd4: 0) |
	((st==DLC)? (((sh[3:0]!=0)&(~rtr))?{sh[2:0],3'b000}:6'd15): 0) |
	((st==DATA)? 6'd15: 0) |
	((st==CRC)? 6'd3: 0) ;

// Bit counter
reg [5:0]bitcnt; //=14;
wire bittc=(bitcnt==1);

always @ (posedge clk) 
	if (st==IDLE) bitcnt<=nbits;
	else if (sample&((~stuffbit)|(st==ACK)))
		if (bittc) bitcnt<=nbits;
		else bitcnt<=bitcnt-1;

// Byte counter
reg [2:0]bytecnt;
always @ (posedge clk)
	if (sample&((~stuffbit))) bytecnt<=(st!=DATA) ? 0 : ((bitcnt[2:0]==1)? bytecnt+1: bytecnt);
	
// BIT ACK
reg ackb; //=0;
always @ (posedge clk or posedge reset)
  if (reset) ackb<=0; else  
	if (st!=ACK) ackb<=1;
	else if (clki0) ackb<=~(bitcnt[0]&bitcnt[1]);

// Regs
reg [28:0]rx_id;
always @ (posedge clk) begin
	if (sample&(~stuffbit)&bittc&(st==IDSTD)) rx_id<={18'h0,sh[13:3]};
	if (sample&(~stuffbit)&bittc&(st==IDEXT)) rx_id<={rx_id[10:0],sh[20:3]};
end
reg rtr;
always @ (posedge clk) begin
	if (sample&(~stuffbit)&bittc&(st==IDSTD)) rtr<=sh[2];
	if (sample&(~stuffbit)&bittc&(st==IDEXT)) rtr<=sh[2];
end
reg ext;
always @ (posedge clk) 
	if (sample&(~stuffbit)&bittc&(st==IDSTD)) ext<=sh[1];

reg [3:0]dlc;
always @ (posedge clk) 
	if (sample&(~stuffbit)&bittc&(st==DLC)) dlc<=sh[3:0];

reg [7:0]rdata[0:7];
always @ (posedge clk) 
	if (sample&(~stuffbit)&(st==DATA)&(bitcnt[2:0]==1)) rdata[bytecnt]<=sh[7:0];

// CRC
reg [14:0]crcr;
always @ (posedge clk) 
	if (st==IDLE) crcr<=0;
	else if (sample&(~stuffbit)) 
		crcr<= {crcr[13:0],1'b0}^((crcr[14]^rrxd[0])? 15'h4599 : 0 );
// Flags
wire badcrc=(crcr!=0);
reg crcerr; //=0;		// CRC error
reg stufferr; //=0;	// Bit stuffing error (Error frames)
reg frmav; //=0;	// Frame available
reg ovwr; //=0;		// Overwrite
always @ (posedge clk or posedge reset)
  if (reset) {crcerr,stufferr,frmav,ovwr} <=0; else 
	// Reading ID reg clears these flags
	if (csid&(bytesel==4'b0000)) begin frmav<=0; ovwr<=0; crcerr<=0; stufferr<=0; end
	else begin 
		if (sample&(~stuffbit)&bittc&(st==CRC)) frmav<=~badcrc;
		if (sample&(~stuffbit)&bittc&(st==CRC)) crcerr<=badcrc;
		if (sample&(~stuffbit)&bittc&(st==IDSTD)) ovwr<=frmav;
		if ((st==IDSTD)&(bitcnt==15)) stufferr<=0;
		else if (sample&(st>IDLE)&(st<ACK)&(errorfrm|passive)) stufferr<=~txing;
	end


/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
//                      CAN TRANSMITTER
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
// Clear to Send timer (11 recessive bits before TX)
wire cts = (ctscnt==10);
reg [3:0]ctscnt; //=0;
always @(posedge clk or posedge reset) 
	if (reset) ctscnt<=0; else
		if (~can_rx) ctscnt<=0;
		else if ((~cts)&clki0) ctscnt<=ctscnt+1;
// TX clock
reg [9:0] divtx; //=1;
wire clk0tx=(divtx==0);	// reload pulse
wire txsample=(divtx=={1'b0,bauddiv[9:1]});
always @ (posedge clk or posedge reset)
  if (reset) divtx<=0; else 
	divtx <= ((txst==TXWAIT)&(~cts)&(~can_rx))? 0 : ((clk0tx) ? bauddiv: divtx-1);

// registers
// ID shift reg
reg txrtr;	// copy of RTR
reg txext;	// copy of EXT
reg [31:0]txid;
always @(posedge clk) begin
	if (csid & (bytesel==4'b1111)) begin
		txext<=d[31];
		txrtr<=d[30];
		txid<=d[31]? {d[28:18],2'b11,d[17:0],d[30]} : {d[10:0],d[30],20'h0};
	end
	else if(clk0tx & (~txstuff)&(txst==TXID)) txid<={txid[30:0],1'b0};
end

// DLC shift rreg
reg [5:0]txdlc;		// two reserved bits plus DLC field
reg [3:0]txdlccopy;
always @(posedge clk) begin
	if (csdlcf  & bytesel[0]) txdlc<={2'b00,d[3:0]};
	else if(clk0tx & (~txstuff)&(txst==TXDLC)) txdlc<={txdlc[4:0],1'b0};
end
always @(posedge clk) if (csdlcf  & bytesel[0]) txdlccopy<=d[3:0];

// DATA shift rreg
reg [31:0]txdata0;
reg [31:0]txdata1;
always @(posedge clk) begin
	if(clk0tx & (~txstuff)&(txst==TXDATA))
		{txdata0,txdata1}<={txdata0[30:0],txdata1,1'b0};
	else begin
		// Endian conversion on data regs
		if (csdata0 & bytesel[3]) txdata0[ 7: 0]<=d[31:24];
		if (csdata0 & bytesel[2]) txdata0[15: 8]<=d[23:16];
		if (csdata0 & bytesel[1]) txdata0[23:16]<=d[15: 8];
		if (csdata0 & bytesel[0]) txdata0[31:24]<=d[ 7: 0];
		if (csdata1 & bytesel[3]) txdata1[ 7: 0]<=d[31:24];
		if (csdata1 & bytesel[2]) txdata1[15: 8]<=d[23:16];
		if (csdata1 & bytesel[1]) txdata1[23:16]<=d[15: 8];
		if (csdata1 & bytesel[0]) txdata1[31:24]<=d[ 7: 0];
	end
end

// CRC
reg [14:0]txcrc;
always @ (posedge clk) 
	if (txst==TXSTART) txcrc<=0;
	else if (clk0tx & (~txstuff)) 
		txcrc<=({txcrc[13:0],1'b0}^(((txcrc[14]^txselout)&(txst!=TXCRC))? 15'h4599 : 0 ));
		
//// RTS flag (request tio send)
wire txstrobe = csdlcf & bytesel[1] & d[8]; 
wire txend = (txst==TXIDLE);
reg rts; //=0;
always @(posedge clk or posedge reset) 
  if (reset) rts<=0; else rts<= txstrobe ? 1 : (txend ? 0 : rts);

// Bit error monitor (for arbitration)
wire biterr = (can_tx^can_rx);

// State names
parameter TXIDLE	= 3'b000;	// Nothing to transmit
parameter TXWAIT	= 3'b001;	// Waiting for CTS
parameter TXSTART	= 3'b010;	// Start bit
parameter TXID		= 3'b011;	// Shifting ID+RTR (arbitration)
parameter TXDLC 	= 3'b100;	// Shifting DLC
parameter TXDATA	= 3'b101;	// Shifting data
parameter TXCRC		= 3'b110;	// Shifting CRC
parameter TXEOF		= 3'b111;	// Trailing recessive bits & ACK detection

reg [2:0]txst;
wire txing = (txst>TXID)&(txst<TXEOF);	// Transmitting: mute RX after ID

// Data selection
wire txselout=	((txst==TXID) ? txid[31]     : 1'b1 ) &
				((txst==TXDLC)? txdlc[5]     : 1'b1 ) &
				((txst==TXDATA)? txdata0[31] : 1'b1 ) &
				((txst==TXCRC)? txcrc[14]    : 1'b1 ) &
				((txst==TXSTART)? 1'b0       : 1'b1 ) ;

// Bit stuffing
reg [4:0]otx; //=0;
always @(posedge clk) if (clk0tx) otx<={otx[3:0],txout};
wire txstuff=((otx==0)|(otx==5'b11111))&(txst>TXSTART)&(txst<TXEOF);
wire txout=txstuff ? (~otx[0]):txselout;

////// Bit counter //////
reg [5:0]txbitcnt; //=0;
// values for counter reload
wire [5:0]txnbit=
	((txst==TXWAIT) ? 1 					:0)	|
	((txst==TXSTART)? (txext ? 32 : 12) 	:0)	|
	((txst==TXID)	? 6 					:0)	|
	((txst==TXDLC)	? (((txdlccopy==0)|(txrtr))?15:{txdlccopy[2:0],3'b000}) :0)	|
	((txst==TXDATA)	? 15 					:0)	|
	((txst==TXCRC)	? 11 					:0)	;
	
wire txbittc =(txbitcnt==1);
always @(posedge clk) 
	if (txst==TXWAIT) txbitcnt<=1;
	else if (clk0tx & (~txstuff)) txbitcnt<=(txbittc?txnbit:txbitcnt-1);

////// State machine //////
always @(posedge clk or posedge reset)
if (reset) txst <= TXIDLE; else 
begin
	case (txst)
	TXIDLE:		if (txstrobe) txst<=TXWAIT;
	TXWAIT:		if (clk0tx & cts) txst<=TXSTART;
	TXSTART:	if (clk0tx) txst<=TXID;
	TXID:		if (biterr&txsample) txst<=TXIDLE; else if(txbittc&clk0tx) txst<=TXDLC;
	TXDLC:		if (biterr&txsample) txst<=TXIDLE; else if(txbittc&clk0tx) txst<=((txdlccopy==0)|(txrtr))?TXCRC:TXDATA;
	TXDATA:		if (biterr&txsample) txst<=TXIDLE; else if(txbittc&clk0tx) txst<=TXCRC;
	TXCRC:		if (biterr&txsample) txst<=TXIDLE; else if(txbittc&clk0tx) txst<=TXEOF;
	TXEOF:		if (txbittc&clk0tx) txst<=TXIDLE;
	endcase
end

////// TX flags //////
reg	lostf; //=0;	// Arbitration Lost flag
always @(posedge clk) 
	if (txst==TXSTART) lostf<=0;
	else if ((txst==TXID)&biterr&txsample) lostf<=1;
	
reg bitf; //=0;		// Bit error flag
always @(posedge clk) 
	if (txst==TXSTART) bitf<=0;
	else if ((txst>TXID)&(txst<TXEOF)&biterr&txsample) bitf<=1;
reg ackf; //=0;		// ACK received flag
always @(posedge clk) 
	if ((txst==TXEOF)&(txbitcnt==10)&txsample) ackf<=~can_rx;

// CAN Output
assign can_tx = ackb & txout;

endmodule

