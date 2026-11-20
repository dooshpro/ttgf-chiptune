<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This is a 8-bit chiptune piano built using Verilog. It has 8 input pins, each representing a musical note from C4 to C5. Each key uses one independent counter to generate a square wave at the required frequency. The design uses a 100 kHz clock to generate the notes. It also includes a vibrato effect that slightly changes the pitch over time. The combined audio signal is sent through output pin uo_out[7].

## How to test

Connect push buttons to the input pins and a piezo buzzer to the output pin uo_out[7]. Press the buttons to generate different musical notes. The project can also be tested using the Verilog testbench and GTKWave simulations.