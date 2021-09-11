# DESYNK

An iCEBreaker-based hardware glitching thing

## Purpose

Break black-box hardware devices by messing with their clock or power feed.

Specifically, a glitch introduced at the right time can bypass individual instructions,
which has interesting security implications.


## Setup

A target device, running something sensitive. For example, computes some hash and checks its result against a fixed "proper" value.

Connections to the Desynk board:

* CLK which drives the target device
* TRIGGER which the target sets HIGH at a fixed time before the check
* SUCCESS which the target sets HIGH if the check is bypassed
* POWER which enables the power feed to the target device
* BROWNOUT which grounds the power feed of the target device


## Usage
**This is all theoretical, since nothing is implemented**

The USR button on the iCEBreaker resets the board. On boot, a normal 16MHz clock signal is generated without glitches,
to allow for target reprogramming and such.

The top button starts glitching. The top LED indicates that glitching is underway.


## Ideas

Modular trigger mode:
* Signal pin
* UART snooping

Modular glitch mode:
* Single quick-cycle
* Skip cycle
* Multiple quick cycles
* Power glitches
