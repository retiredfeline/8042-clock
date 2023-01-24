#!/usr/bin/env python3
""" Generate lookup table for ternary numbers 0 to 59 """

MASKS = [0b00, 0b01, 0b10]


def toternary(i):
    """ Convert i to ternary using 2 bits per trit """
    result = 0
    for shift in range(0, 4):
        rem = i % 3
        i //= 3
        result |= (MASKS[rem] << (shift * 2))
    return result


def main():
    """ Main loop """
    for i in range(0, 60):
        value = toternary(i)
        print(f"0x{value:02x}")


if __name__ == '__main__':
    main()
