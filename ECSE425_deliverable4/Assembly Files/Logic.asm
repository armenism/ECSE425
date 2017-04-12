# Differences between bitwise and logical operators (& vs &&, | vs ||)
# $1: x = 3
# $2: y = 4
# $3: z = x & y    */ bitwise AND: 0...0011 and 0...0100 = 0...0 /*
# $4: w = x && y   */ logical AND: both are nonzero, so w = 1 /*
# $5: a = x | y    */ bitwise OR: 0...0011 and 0...0100 = 0...0111 /*
# $6: b = x || y   */ logical OR: at least one is nonzero, so w = 1 /*

# Assume that your data section in memory starts from address 2000. (Of course, since you will use separate memories for code and data for this part of the project, you could put data at address 0, but in the next phase of the project, you may use a single memory for both code and data, which is why we give you this program assuming a unified memory.)


				addi $1, $0, 1  	# initializing the beginning of Data Section address in memory
				addi $2, $0, 1
				addi $3, $0, 0
				addi $4, $0, 0
				
Logical:        and 	$5, $1, $2
				or		$6, $1, $2
				nor		$7, $3, $4
				xor		$8, $1, $3
				andi 	$5, $1, 1
				ori		$6, $1, 0
				xori	$8, $3, 1
				

End:       		beq	 $11, $11, End 		#end of program (infinite loop)
