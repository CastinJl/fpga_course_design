# Arbitrary waveform UART protocol

UART settings:

- Baud rate: 115200
- Data bits: 8
- Parity: none
- Stop bits: 1
- Send mode: hexadecimal bytes

## Frame

The FPGA accepts exactly one fixed-length frame:

```text
A5 5A 01 F3 F2 F1 F0 S0H S0L S1H S1L ... S511H S511L CK 5A A5
```

The complete frame contains 1034 bytes:

```text
3-byte header/command
4-byte frequency
1024-byte sample data
1-byte checksum
2-byte tail
```

Field meanings:

- `A5 5A`: frame header.
- `01`: arbitrary waveform download command.
- `F3 F2 F1 F0`: output frequency in Hz, big-endian unsigned 32-bit value.
- `SxH SxL`: one 12-bit DAC sample. The valid value is 0 to 4095. The high byte uses only its low four bits.
- `CK`: XOR of `01`, all four frequency bytes, and all 1024 sample bytes.
- `5A A5`: frame tail.

Examples:

```text
frequency 100000 Hz = 00 01 86 A0
sample 0            = 00 00
sample 2048         = 08 00
sample 4095         = 0F FF
```

The FPGA writes the new frame into the inactive RAM bank. It changes to the new waveform only after the checksum and tail are correct. A bad or incomplete frame leaves the currently playing waveform unchanged.

After a valid frame, the waveform becomes available as a selectable source for both the DAC and VGA. Press `KEY7` to cycle through `FM -> ASK -> FSK -> PSK -> arbitrary waveform -> normal waveform`. Reset returns the system to the original waveform path.
