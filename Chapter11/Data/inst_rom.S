.org 0x0
.global _start
.set noat
_start:
    ori $1, $0, 0x1100
    ori $1, $1, 0x0020
    ori $1, $1, 0x4400
    ori $1, $1, 0x0044