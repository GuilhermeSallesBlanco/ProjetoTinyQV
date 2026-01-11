/*
 * Copyright (c) 2024 Caio Alonso da Costa
 * SPDX-License-Identifier: Apache-2.0
 */

 module rsa_en_logic (rstb, clk, ena, start, stop, en_rsa, clear_rsa, eoc_rsa, irq);

  // Inputs
  input logic rstb;
  input logic clk;
  input logic ena;

  // Start/Stop
  input logic start;
  input logic stop;

  // Control outputs for rsa_unit
  output logic en_rsa;
  output logic clear_rsa;

  // End of convertion (encryption from rsa_unit)
  input logic eoc_rsa;
  // IRQ
  output logic irq;

  // FSM states type
  typedef enum logic [2:0] {
    STATE_RESET, STATE_IDLE, STATE_EN, STATE_CLEAR_RELEASE, STATE_WAIT_EOC, STATE_IRQ
  } rsa_fsm_state;

  // FSM states
  rsa_fsm_state state, next_state;

  // Auxiliar logic
  logic start_d;
  logic stop_d;
  logic start_comb;
  logic stop_comb;
  logic en_rsa_i;
  logic clear_rsa_i;
  logic irq_i;
  logic irq_reg;

  // Outputs
  assign en_rsa = en_rsa_i;
  assign clear_rsa = clear_rsa_i;
  assign irq = irq_reg;

  // Delay for rising edge detector - start and stop
  always_ff @(negedge(rstb) or posedge(clk)) begin
    if (!rstb) begin
      start_d <= 1'b0;
      stop_d  <= 1'b0;
    end else begin
      if (ena == 1'b1) begin
        start_d <= start;
        stop_d  <= stop;
      end
    end
  end

  // Rising edge detector - start and stop
  assign start_comb = start & !start_d;
  assign stop_comb  = stop  & !stop_d;

  // Register irq
  always_ff @(negedge(rstb) or posedge(clk)) begin
    if (!rstb) begin
      irq_reg <= 1'b0;
    end else begin
      if (ena == 1'b1) begin
        if ((start_comb == 1'b1) || (stop_comb == 1'b1)) begin
          irq_reg <= 1'b0;
        end else begin
          if (state == STATE_IRQ) begin
            irq_reg <= irq_i;
          end
        end
      end
    end
  end

  // Next state transition
  always_ff @(negedge(rstb) or posedge(clk)) begin
    if (!rstb) begin
      state <= STATE_RESET;
    end else begin
      if (ena == 1'b1) begin
        state <= next_state;
      end
    end
  end

  always_comb begin

    // default assignments
    en_rsa_i = 1'b0;
    clear_rsa_i = 1'b0;
    irq_i = 1'b0;
    next_state = state;

    case (state)

      STATE_RESET : begin
        en_rsa_i = 1'b0;
        clear_rsa_i = 1'b0;
        irq_i = 1'b0;
        next_state = STATE_IDLE;
      end

      STATE_IDLE : begin
        en_rsa_i = 1'b0;
        clear_rsa_i = 1'b0;
        irq_i = 1'b0;
        if (start_comb == 1'b1) begin
          next_state = STATE_EN;
        end else begin
          next_state = STATE_IDLE;
        end
      end

      STATE_EN : begin
        en_rsa_i = 1'b1;
        clear_rsa_i = 1'b0;
        irq_i = 1'b0;
        if (stop_comb == 1'b1) begin
          next_state = STATE_IDLE;
        end else begin
          next_state = STATE_CLEAR_RELEASE;
        end
      end

      STATE_CLEAR_RELEASE : begin
        en_rsa_i = 1'b1;
        clear_rsa_i = 1'b1;
        irq_i = 1'b0;
        if (stop_comb == 1'b1) begin
          next_state = STATE_IDLE;
        end else begin
          next_state = STATE_WAIT_EOC;
        end
      end

      STATE_WAIT_EOC : begin
        en_rsa_i = 1'b1;
        clear_rsa_i = 1'b1;
        irq_i = 1'b0;
        if (stop_comb == 1'b1) begin
          next_state = STATE_IDLE;
        end else begin
          if (eoc_rsa == 1'b1) begin
            next_state = STATE_IRQ;
          end else begin
            next_state = STATE_WAIT_EOC;
          end
        end
      end

      STATE_IRQ : begin
        en_rsa_i = 1'b1;
        clear_rsa_i = 1'b1;
        irq_i = 1'b1;
        next_state = STATE_IDLE;
      end

      default : begin
        en_rsa_i = 1'b0;
        clear_rsa_i = 1'b0;
        irq_i = 1'b0;
        next_state = STATE_RESET;
      end

    endcase

  end

endmodule
