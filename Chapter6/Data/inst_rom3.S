.org 0x0
.global _start
.set noat
_start:
	lui $1, 0x0000
	lui $2, 0xffff
	lui $3, 0x0505
	lui $4, 0x0000
	
	// 对于 movz 指令而言，由于寄存器 $1 为 0
	// 因此将 $2 的值赋给 $4
	movz $4, $2, $1
	
	// 对于 movn 指令而言，由于寄存器 $1 为 0
	// 所以不幅值，$4 保持不变
	movn $4, $3, $1
	
	// 对于 movn 指令而言，由于寄存器 $2 不为 0
	// 所以将 $3 的值赋给 $4 
	movn $4, $3, $2
	
	// 对于 movz 指令而言，由于寄存器 $3 不为 0
	// 所以不幅值，$4 的值保持不变
	movz $4, $2, $3
	
	// 分别将寄存器 $0,$2,$3 的值保存到 HI 寄存器
	mthi $0
	mthi $2
	mthi $3
	
	mfhi $4
	
	
	// 分别将寄存器 $3,$2,$1 的值保存到 LO 寄存器
	mtlo $3
	mtlo $2
	mtlo $1
	
	mflo $4
	
	
	
	
	

	
	