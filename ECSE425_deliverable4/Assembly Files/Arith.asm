# Differences between bitwise and logical operators (& vs &&, | vs ||)
# $1: x = 3
# $2: y = 4
# $3: z = x & y    */ bitwise AND: 0...0011 and 0...0100 = 0...0 /*
# $4: w = x && y   */ logical AND: both are nonzero, so w = 1 /*
# $5: a = x | y    */ bitwise OR: 0...0011 and 0...0100 = 0...0111 /*
# $6: b = x || y   */ logical OR: at least one is nonzero, so w = 1 /*

# Assume that your data section in memory starts from address 2000. (Of course, since you will use separate memories for code and data for this part of the project, you could put data at address 0, but in the next phase of the project, you may use a single memory for both code and data, which is why we give you this program assuming a unified memory.)


				addi $1,  $0, 100  	# initializing the beginning of Data Section address in memory
				addi $10, $0, 10
				
Arith:        	addi $2, $0, 200
                and  $3, $1, $2         
				sub	 $4, $3, $2
	
				mult $4, $15			# $lo=4*$10, for word alignment 
				mflo $5				# assume small numbers
				div $4, $15			# $lo=4*$10, for word alignment 
				mflo $6
				
				slt $7, $6, $5
				slti $8, $6, 10000
				

End:       		beq	 $11, $11, End 		#end of program (infinite loop)
