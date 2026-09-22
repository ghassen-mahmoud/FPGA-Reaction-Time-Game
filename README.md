# FPGA Reaction Time Game

A reaction-time game implemented in **VHDL** on a **Terasic DE10-Standard FPGA board** using a **Cyclone V SoC FPGA**.

The goal is simple: press the start button, wait for the LED to turn on after a random delay, then press the button as quickly as possible. The reaction time is measured and displayed on four 7-segment displays.

## Features

* Random waiting time between **1 and 5 seconds**
* Reaction-time measurement using a **50 MHz clock**
* Measurement resolution of approximately **1 ms**
* Maximum displayed reaction time: **9999 ms**
* If the reaction time exceeds approximately **10 seconds**, the display remains at **9999**
* 4-digit 7-segment display
* Reset button
* FSM-based control
* 16-bit LFSR for pseudo-random delay generation
* 29-bit LPM counter for reaction-time measurement

## Hardware

* **FPGA Board:** Terasic DE10-Standard
* **FPGA:** Intel Cyclone V
* **Clock:** 50 MHz
* **Programming language:** VHDL
* **Development tool:** Intel Quartus Prime 18.1

## Hardware Inputs and Outputs

| Signal     | Description                            |
| ---------- | -------------------------------------- |
| `CLOCK_50` | 50 MHz FPGA clock                      |
| `KEY0`     | Start / reaction button                |
| `KEY1`     | Reset button                           |
| `LED`      | Indicates when the player should react |
| `HEX0`     | Units digit                            |
| `HEX1`     | Tens digit                             |
| `HEX2`     | Hundreds digit                         |
| `HEX3`     | Thousands digit                        |

## Game Operation

The game is controlled by a finite state machine:

```text
             KEY0
               │
               ▼
            ┌──────┐
            │ IDLE │
            └──┬───┘
               │
               ▼
       ┌────────────────┐
       │  WAIT_RANDOM   │
       │   1–5 seconds  │
       └───────┬────────┘
               │
               ▼
          ┌─────────┐
          │ LED_ON  │
          └────┬────┘
               │
          KEY0 pressed
               │
               ▼
          ┌─────────┐
          │ RESULT  │
          └─────────┘
```

If the reaction time reaches approximately **9.999 seconds**, the system enters the `case_9999` state and displays:

```text
9999
```

The value remains at `9999` until the next button press.

## Finite State Machine

The design uses five states:

### IDLE

Initial state.

* LED is OFF
* Reaction counter is reset
* Waiting for `KEY0`

### WAIT_RANDOM

A pseudo-random delay between 1 and 5 seconds is generated.

* LED is OFF
* Reaction counter remains reset
* The system waits for the selected delay

### LED_ON

The reaction phase begins.

* LED turns ON
* The 29-bit counter starts counting
* Pressing `KEY0` stops the measurement

The counter value is converted from clock cycles to milliseconds:

```text
50,000,000 clock cycles = 1 second

50,000 clock cycles = 1 ms
```

Therefore:

```text
reaction_ms = counter_value / 50000
```

### RESULT

The measured reaction time is displayed on the four 7-segment displays.

Example:

```text
0257
```

means approximately:

```text
257 ms
```

### case_9999

If the reaction time reaches approximately 10 seconds:

```text
9999
```

is displayed and maintained until the player presses `KEY0`.

## Pseudo-Random Delay

A 16-bit **LFSR (Linear Feedback Shift Register)** is used to generate a pseudo-random value.

The feedback is calculated using:

```vhdl
feedback :=
    lfsr(15) xor
    lfsr(13) xor
    lfsr(12) xor
    lfsr(10);
```

The generated value is converted into a delay from 1 to 5 seconds:

```vhdl
random_delay <=
    (to_integer(unsigned(lfsr(2 downto 0))) mod 5) + 1;
```

This prevents the LED from turning on at the same fixed time during every game.

## Reaction Counter

The project uses a **29-bit LPM counter** generated with Quartus IP.

At 50 MHz:

```text
2^29 = 536,870,912 counts
```

which corresponds to approximately:

```text
10.74 seconds
```

This provides enough range to measure up to approximately 10 seconds without counter overflow during the intended measurement range.

The counter is controlled by the `sclr` signal:

```vhdl
counter_inst : entity work.counter
    port map (
        clock => CLOCK_50,
        sclr  => counter_reset,
        q     => counter_q
    );
```

## Project Structure

```text
FPGA-Reaction-Time-Game/
│
├── reaction_game.vhd
├── counter.vhd
├── reaction_game.qsf
├── reaction_game.sdc
├── README.md
└── ...
```

## Main Technologies

* VHDL
* FPGA
* Intel Cyclone V
* Quartus Prime
* Finite State Machine (FSM)
* LFSR
* LPM Counter
* 7-Segment Display
* Digital timing
* Synchronous logic


## Author

**Ghassen Mahmoud**

Master 2 – Electronics and Embedded Systems
ESIGELEC, Rouen, France
