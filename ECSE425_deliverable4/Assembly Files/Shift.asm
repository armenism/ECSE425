# Differences between bitwise and logical operators (& vs &&, | vs ||)
# $1: x = 3
# $2: y = 4
# $3: z = x & y    */ bitwise AND: 0...0011 and 0...0100 = 0...0 /*
# $4: w = x && y   */ logical AND: both are nonzero, so w = 1 /*
# $5: a = x | y    */ bitwise OR: 0...0011 and 0...0100 = 0...0111 /*
# $6: b = x || y   */ logical OR: at least one is nonzero, so w = 1 /*

# Assume that your data section in memory starts from address 2000. (Of course, since you will use separate memories for code and data for this part of the project, you could put data at address 0, but in the next phase of the project, you may use a single memory for both code and data, which is why we give you this program assuming a unified memory.)


				addi $1, $0, 100 	# initializing the beginning of Data Section address in memory

Shift:       	sw	 $1, 0($2)
				sw	 $1, 1($2)
				sw	 $1, 2($2)
				sw	 $1, 3($2)
				sw	 $1, 4($2)
				lw	 $3, 0($2)
				lw	 $4, 1($2)
				lw	 $5, 2($2)
				lw	 $6, 3($2)
				lw	 $7, 4($2)
				

End:       		beq	 $11, $11, End 		#end of program (infinite loop)