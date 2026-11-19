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

  reg [7:0] reloadval;
  reg [7:0] cnt;
  reg audio;

  always @(posedge clk) begin
    if (!rst_n) begin
      cnt <= 0;
      audio <= 0;
    end
    else if (!any_key_active) begin
      cnt <= 0;
      audio <= 0;
    end

    else if (cnt == 0) begin
      cnt <= reloadval;
      audio <= ~audio;
    end
    else begin
      cnt <= cnt - 1'b1;
    end
  end

  localparam [7:0] reloadC4 = 190;
  localparam [7:0] reloadD4 = 169;
  localparam [7:0] reloadE4 = 151;
  localparam [7:0] reloadF4 = 142;
  localparam [7:0] reloadG4 = 127;
  localparam [7:0] reloadA4 = 113;
  localparam [7:0] reloadB4 = 100;
  localparam [7:0] reloadC5 = 95;

  always @(*) begin
    if (keysync2[0])
      reloadval = reloadC4;
    else if (keysync2[1])
      reloadval = reloadD4;
    else if (keysync2[2])
      reloadval = reloadE4;
    else if (keysync2[3])
      reloadval = reloadF4;
    else if (keysync2[4])
      reloadval = reloadG4;
    else if (keysync2[5])
      reloadval = reloadA4;
    else if (keysync2[6])
      reloadval = reloadB4;
    else if (keysync2[7])
      reloadval = reloadC5;
    else
      reloadval = 0;
  end

  // All output pins must be assigned. If not used, assign to 0.
  assign uo_out = {audio, 7'b0};
  assign uio_out = 8'b0;
  assign uio_oe = 8'b0;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, uio_in, 1'b0};

endmodule