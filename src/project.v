/*
 * Copyright (c) 2026 dooshpro
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_dooshpro_chiptune (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  reg [7:0] keysync1;
  reg [7:0] keysync2;

  always @(posedge clk) begin
    if (!rst_n) begin
      keysync1 <= 8'b0;
      keysync2 <= 8'b0;
    end

    else begin
      keysync1 <= ui_in;
      keysync2 <= keysync1;
    end
  end

  wire any_key_active = |keysync2;

  localparam [7:0] reloadC4 = 190;
  localparam [7:0] reloadD4 = 169;
  localparam [7:0] reloadE4 = 151;
  localparam [7:0] reloadF4 = 142;
  localparam [7:0] reloadG4 = 127;
  localparam [7:0] reloadA4 = 113;
  localparam [7:0] reloadB4 = 100;
  localparam [7:0] reloadC5 = 95;

  reg [7:0] cnt [0:7];
  reg [7:0] tone;
  reg [15:0] vibcnt; //vibrato

  always @(posedge clk) begin
    if (!rst_n || !any_key_active)
      vibcnt <= 0;
    else
      vibcnt <= vibcnt + 1'b1;
  end

  function [7:0] getnote;
    input integer key;
    begin
      case (key)
        0: getnote = reloadC4;
        1: getnote = reloadD4;
        2: getnote = reloadE4;
        3: getnote = reloadF4;
        4: getnote = reloadG4;
        5: getnote = reloadA4;
        6: getnote = reloadB4;
        7: getnote = reloadC5;
        default: getnote = reloadC4;
      endcase
    end

  endfunction

  genvar i;
  generate
    for (i = 0; i < 8; i = i + 1) begin: notes

      wire [7:0] reloadval;
      assign reloadval =
          (vibcnt[15:14] == 2'b01) ? getnote(i) + 1'b1 : (vibcnt[15:14] == 2'b11) ? getnote(i) - 1'b1 : getnote(i);

      always @(posedge clk) begin
        if (!rst_n) begin
          cnt[i] <= 0;
          tone[i] <= 0;
        end
        else if (!keysync2[i]) begin
          cnt[i] <= 0;
          tone[i] <= 0;
        end
        else if (cnt[i] == 0) begin
          cnt[i] <= reloadval;
          tone[i] <= ~tone[i];
        end

        else begin
          cnt[i] <= cnt[i] - 1'b1;
        end
      end
    end
  endgenerate

  wire audio = |tone;

  // All output pins must be assigned. If not used, assign to 0.
  assign uo_out = {audio, 7'b0};
  assign uio_out = 8'b0;
  assign uio_oe = 8'b0;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, uio_in, 1'b0};

endmodule