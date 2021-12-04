#!/usr/bin/env python3
""" Generate lookup table for ternary numbers 0 to 59 """


TERNARY = [0b00000, 0b00001, 0b00010, 0b00100, 0b00101,
           0b00110, 0b01000, 0b01001, 0b01010, 0b10000]


def main():
    """ Main loop """
    for tens in range(0, 6):
        for units in range(0, 10):
            value = TERNARY[tens] << 5 | TERNARY[units]
            print(f"0x{value:02x}")


if __name__ == '__main__':
    main()
