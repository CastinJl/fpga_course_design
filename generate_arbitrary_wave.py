"""Generate a UART frame for the FPGA arbitrary-waveform receiver."""

import argparse
import math
from pathlib import Path


def build_frame(frequency, amplitude, offset, samples):
    frame = [0xA5, 0x5A, 0x01]
    frame.extend((frequency >> shift) & 0xFF for shift in (24, 16, 8, 0))
    checksum = 0x01

    for index in range(samples):
        value = round(offset + amplitude * math.sin(2.0 * math.pi * index / samples))
        value = max(0, min(4095, value))
        high = (value >> 8) & 0x0F
        low = value & 0xFF
        frame.extend((high, low))
        checksum ^= high
        checksum ^= low

    frame.extend((checksum, 0x5A, 0xA5))
    return frame


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--frequency", type=int, default=100_000)
    parser.add_argument("--amplitude", type=int, default=1600)
    parser.add_argument("--offset", type=int, default=2048)
    parser.add_argument("--samples", type=int, default=512)
    parser.add_argument("--output", type=Path, default=Path("arbitrary_wave_frame.hex.txt"))
    parser.add_argument("--binary", type=Path, default=Path("arbitrary_wave_frame.bin"))
    args = parser.parse_args()

    if args.samples != 512:
        raise SystemExit("The FPGA receiver currently requires exactly 512 samples.")
    if not 0 <= args.frequency <= 0xFFFFFFFF:
        raise SystemExit("frequency must fit in an unsigned 32-bit value")
    if args.offset - abs(args.amplitude) < 0 or args.offset + abs(args.amplitude) > 4095:
        raise SystemExit("offset +/- amplitude must remain within 0..4095")

    frame = build_frame(args.frequency, args.amplitude, args.offset, args.samples)
    args.output.write_text(" ".join(f"{byte:02X}" for byte in frame) + "\n", encoding="ascii")
    args.binary.write_bytes(bytes(frame))
    print(f"bytes={len(frame)} checksum={frame[-3]:02X}")
    print(f"hex={args.output}")
    print(f"binary={args.binary}")


if __name__ == "__main__":
    main()
