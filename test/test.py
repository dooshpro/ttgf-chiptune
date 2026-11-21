# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles


@cocotb.test()
async def test_project(dut):
    dut._log.info("start")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # Reset
    dut._log.info("reset")
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.rst_n.value = 0
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1

    await ClockCycles(dut.clk, 3)
    assert ((int(dut.uo_out.value) >> 7) & 1) == 0

    # C4 test
    dut._log.info("c4 test")
    dut.ui_in.value = 1
    prev = (int(dut.uo_out.value) >> 7) & 1
    toggles = 0
    for _ in range(500):
        await ClockCycles(dut.clk, 1)
        now = (int(dut.uo_out.value) >> 7) & 1
        if now != prev:
            toggles += 1
            prev = now
    assert toggles >= 2

    # C5 test
    dut._log.info("c5 test")
    dut.ui_in.value = 0x80
    prev = (int(dut.uo_out.value) >> 7) & 1
    toggles = 0
    for _ in range(400):
        await ClockCycles(dut.clk, 1)
        now = (int(dut.uo_out.value) >> 7) & 1
        if now != prev:
            toggles += 1
            prev = now
    assert toggles >= 2

    # C4 + E4 test
    dut._log.info("multikey test")
    dut.ui_in.value = 0x05
    await ClockCycles(dut.clk, 4)

    prev = (int(dut.uo_out.value) >> 7) & 1
    toggles = 0
    for _ in range(500):
        await ClockCycles(dut.clk, 1)
        now = (int(dut.uo_out.value) >> 7) & 1
        if now != prev:
            toggles += 1
        prev = now
    assert toggles >= 2

    # Release C4, keep E4
    dut._log.info("release c4 test")
    dut.ui_in.value = 0x04
    await ClockCycles(dut.clk, 4)

    prev = (int(dut.uo_out.value) >> 7) & 1
    toggles = 0
    for _ in range(300):
        await ClockCycles(dut.clk, 1)
        now = (int(dut.uo_out.value) >> 7) & 1
        if now != prev:
            toggles += 1
        prev = now
    assert toggles >= 2

    # Mute test
    dut._log.info("mute test")
    dut.ui_in.value = 0
    await ClockCycles(dut.clk, 5)
    assert ((int(dut.uo_out.value) >> 7) & 1) == 0