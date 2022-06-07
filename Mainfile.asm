# Assignment KTMT (Nhom L02 - 04)
# De 4: Nhan 2 so thuc chuan IEEE 754 chinh xac don ma khong su dung cac lenh tinh toan so thuc cua MIPS.

# Chuong trinh chinh:  Mainfile
	
# Data segment
	.data
# Cac dinh nghia bien	
filename:	.asciiz	"FLOAT2.BIN"
float:		.float	0.00000000
NAN:		.float	NaN

# Cac cau nhac nhap du lieu
CT:		.asciiz "Chuong trinh nhan 2 so thuc chuan IEEE 754 chinh xac don"
Sthuc1:		.asciiz	"So thuc thu 1 la: "
Sthuc2:		.asciiz	"So thuc thu 2 la: "
Kqua:		.asciiz	"Ket qua nhan hai so thuc: "

#----------------------
# Code segment
	.text
	.globl 	main
#-------------------------	

# Chuong trinh chinh
#-------------------------
main: 
# Mo file
	la 	$a0,filename
	li	$a1,0
	li	$v0,13
	li 	$a2,0
	syscall
	move	$s0,$v0

# Doc tu file
 	li	$v0,14
 	move 	$a0,$s0
 	la 	$a1,float
 	la	$a2,8
 	syscall
 	
# Sao chep du lieu, tu do chuyen sang phan xu li, tinh toan
# So thuc 1 duoc luu vao thanh ghi $t0, so thuc 2 duoc luu vao thanh ghi $t1.
  	la	$a3,float
  	lwc1	$f0,0($a3)
  	lwc1	$f1,4($a3)
  	mfc1	$t0,$f0
  	mfc1	$t1,$f1
  	jal 	mul2f
 
# Xuat ket qua (syscall)
	la 	$a0,CT
	addi 	$v0,$zero,4
	syscall
	addi	$a0,$zero,'\n'
	addi	$v0,$zero,11
	syscall
	
	la 	$a0,Sthuc1
	addi 	$v0,$zero,4
	syscall
	li	$v0,2
	lwc1	$f12,0($a3)
	syscall 
	addi	$a0,$zero,'\n'
	addi	$v0,$zero,11
	syscall
	
	la 	$a0,Sthuc2
	addi 	$v0,$zero,4
	syscall
	lwc1	$f12,4($a3)
	li	$v0,2
	syscall
	addi	$a0,$zero,'\n'
	addi	$v0,$zero,11
	syscall
	
	la 	$a0,Kqua
	addi 	$v0,$zero,4
	syscall
	mov.s	$f12,$f2
	li	$v0,2
	syscall
	addi	$a0,$zero,'\n'
	addi	$v0,$zero,11
	syscall
	
# Dong file
 	move 	$a0,$s0
 	li	$v0,16
 	syscall

# Ket thuc chuong trinh (syscall)		
Kthuc:	addiu 	$v0, $zero, 10
	syscall
#----------------------------------------------------#




#----------------------------------------------------#
# Ham mul2f: Tinh toan nhan 2 so thuc
   # Input: So thuc 1: $t0, So thuc 2: $t1
   # Output: $f2

mul2f:

   # Sign: Xet dau ket qua	
    	# Tach bit dau so thuc thu nhat
  	andi 	$s3,$t0,0x80000000
    	# Tach bit dau so thuc thu hai
  	andi	$s4,$t1,0x80000000
    	# Tinh toan bit dau cua ket qua
  	beq	$s3,$s4,ssign		# Neu hai so cung dau thi bit dau cua ket qua se bang 0, nguoc lai se bang 1 
  	li	$s0,0x80000000
  	j 	exp_frac
 ssign:	li	$s0,0
  
 exp_frac:	  
   # Tach phan mu va phan phan so de xet va tinh toan cac truong hop: 
	# Tach phan mu so thuc thu nhat 	(exp1)
 	andi 	$s4,$t0,0x7F800000
 	# Tach phan mu so thuc thu hai  	(exp2)
  	andi	$s5,$t1,0x7F800000
	# Tach phan phan so so thuc thu nhat	(frac1)
  	andi	$s6,$t0,0x007FFFFF
   	# Tach phan phan so so thuc thu hai	(frac2)
   	andi	$s7,$t1,0x007FFFFF
   	
   # Check exception:
   	
   	# Truong hop NaN (trong hai so thuc co so NaN): 
   	# if ((exp1 == 255 && frac1 != 0) || (exp2 == 255 && frac2 != 0)) {
   	seq	$t3,$s4,0x7F800000
   	sne	$t4,$s6,0
   	and	$t7,$t3,$t4
   	
   	seq	$t5,$s5,0x7F800000
   	sne	$t6,$s7,0
	and	$t8,$t5,$t6
	
	or 	$t9,$t7,$t8
	
	beq	$t9,0,Infi	# Neu ket qua beq dung ta se chuyen sang truong hop xet Infinity, 
				# nguoc lai thi trong hai so co it nhat mot so la NaN, khi do ket qua tra ve se la NaN
	  # Tra ve ket qua NaN
	lwc1	$f2,NAN
	jr	$ra
			
	# else		
	# if ((exp1 == 255 && frac1 == 0) || (exp2 == 255 && frac2 == 0))	
  Infi:
	seq	$t4,$s6,0
	and	$t7,$t3,$t4
	
	seq	$t6,$s7,0
	and	$t8,$t5,$t6
	
	or 	$t9,$t7,$t8
	
	beq	$t9,0,Zero	# Neu ket qua beq dung, thi hai so nay deu khong phai la so Infinity, ta se chuyen sang 
				# truong hop xet Zero, nguoc lai ta se xet tiep truong hop trong hai so nay co so 0 hay khong

	# if ((exp1 == 0 && frac1 == 0) || (exp2 == 0 && frac2 == 0))
	seq	$t3,$s4,0
	and	$t7,$t3,$t4
	
	seq	$t5,$s5,0
	and	$t8,$t5,$t6
	
	or 	$t9,$t7,$t8
	
	beq	$t9,0,Nonzero 	# Neu ket qua beq dung, ket qua nhan se la Infinity (cau lenh nhay qua Nonzero), 
				# nguoc lai ket qua se la NaN
	   
	   # Tra ve ket qua NaN (la ket qua cua truong hop Infinity x 0)
	lwc1	$f2,NAN
	jr	$ra
  Nonzero:
	   # Tra ve ket qua Infinity
	add	$t2,$zero,$s0
	addiu	$t2,$t2,0x7f800000
	mtc1	$t2,$f2
	jr	$ra

	# else
	# if ((exp1 == 0 && frac1 == 0) || (exp2 == 0 && frac2 == 0)) {
  Zero:
	seq	$t3,$s4,0
	and	$t7,$t3,$t4
	
	seq	$t5,$s5,0
	and	$t8,$t5,$t6
	
	or 	$t9,$t7,$t8

	beq	$t9,0,Denorm	# Neu ket qua beq dung, thi hai so nay deu khong phai la so 0, 
	                        # khi do ta se chuyen qua truong hop xet Denormalize, nguoc lai thi ket qua phep toan se tra ve 0
	  
	  # Tra ve ket qua 0
	add	$t2,$zero,$s0
	addiu	$t2,$t2,0
	mtc1	$t2,$f2
	jr	$ra
	
	# else
	# if ((exp1 == 0 && frac1 != 0) && (exp2 == 0 && frac2 != 0))	
  Denorm:
	sne	$t4,$s6,0
	and	$t7,$t3,$t4
	
	sne	$t6,$s7,0
	and	$t8,$t5,$t6
	
	and 	$t9,$t7,$t8
	
	beq	$t9,0,Denorm_x_Norm	# Neu nhu ket qua beq dung, ta se chuyen sang xet truong hop Denormalize x Normalize or Normalize x Denormalize
					# nguoc lai thi hai so nay deu la Denormalize, ket qua se bang 0
	   # Tra ve ket qua 0 (Denormalize x Denormalize)	  
	add	$t2,$zero,$s0
	addiu	$t2,$t2,0
	mtc1	$t2,$f2
	jr	$ra


	# else
  Denorm_x_Norm:
  	# if (exp1==0 && frac1!=0 || exp2==0 && frac2!=0)	
	or 	$t9,$t7,$t8
	beq	$t9,0,Norm	# Neu ket qua beq dung, thi ta se tinh toan truong hop Denormalize x Normalize
				# nguoc lai ta se tinh toan truong hop Normalize x Normalize
	
	# Tinh toan truong hop Denormalize x Normalize:
	  # Them bit dinh tri:
	   # Bit dinh tri cua Denormalize la 0 trong khi o Normalize la 1.
	   # Vi day la truong hop Denormalize x Normalize nen mot so se co bit d?nh tri la 0 con so con lai se co bit dinh tri la 1.
	beq	$s4,$zero,d1
   	addi	$s6,$s6,0x00800000
   	j	continue
   d1:  addi	$s7,$s7,0x00800000
   	  
   continue:
   	  # Tinh toan phan mu va phan phan so:
   	  # Phan mu:
   	  # Tinh toan exp1 + exp2 - bias (127)
   	addu	$s1,$s4,$s5
  	addi	$t2,$zero,0x3F800000
  	sltu 	$t3,$t2,$s1     # So sanh exp1 + exp2 > bias
  	#----
  	# 2 thanh ghi nay $t4,$t5 duoc thuc hien de chuan bi cho cac cau lenh sau:
        srl	$t4,$s1,23      # exp1 + exp2
  	li	$t5,126         # bias denormalize (126) 
  	#---
  	
	bne	$t3,$zero,d2	
	
   # Neu exp1 + exp2 <= bias
  	sub	$t4,$t5,$t4     # Gia tri $t4 se la so bit can dich phai sau khi nhan 2 phan phan so voi nhau 
  				# $t4 = 126 - (exp1 + exp2)
	li	$s1,0 		# Phan mu se bang 0
	j	continue2
   # Neu exp1 + exp2 > bias
   d2:	
   	subu	$s1,$t4,$t5	# Phan mu ban dau se bang (exp1 + exp2) - 126
   
   continue2:
   	# Nhan phan phan so cua 2 so thuc
   	multu	$s6,$s7      	# Ket qua phep nhan o day luon la 47 bit
   	mfhi	$s2		# (15 bit o thanh ghi hi va 32 bit o thanh ghi lo)
   	mflo	$s3		
  	bne	$t3,$zero,d3
  	# Hai truong hop exp1 + exp2 <= bias va exp1 + exp2 > bias se co giai thuat tinh phan phan so khac nhau
  	
   # Neu exp1 + exp2 <= bias
   	  # Neu exp1 + exp2 = bias (127) thi ta phai dich trai ket qua nhan 1 bit, sau do ta moi lay 23 bit cao nhat lam phan phan so
   	  # Nguoc lai ta se lay 23 bit cao nhat nhu binh thuong
   	beq	$t4,0xFFFFFFFF,bias  # $t4 = 126 - bias = -1 = 0xFFFFFFFF (exp1 + exp2 == 127)
  	sll 	$s2,$s2,8
   	srl	$s3,$s3,24
  	add	$s2,$s2,$s3     # Lay 23 bit cao nhat 
    	j 	s_right
   bias:sll	$s2,$s2,9	
   	srl	$s3,$s3,23
  	add	$s2,$s2,$s3
  	j	result
   s_right:	# Dich phai phan phan so voi so bit duoc luu trong thanh ghi $t4, sau khi thuc hien xong vong lap xuat ket qua
   	srlv	$s2,$s2,$t4     
  	
  	
   # Neu exp1 + exp2 > bias
   	# O 47 bit ket qua phep nhan ta vua tinh duoc, neu bit 47 khong bang 1 thi ta se dich trai ket qua va giam so mu cho den khi bit 47 bang 1
   	# Tiep theo ta dich trai ket qua them 1 bit nhung khong giam so mu
   	# Luu y: Neu trong qua trinh dich ma phan mu bang 0 thi ta se dung vong lap lai
   	# Cuoi cung ta lay 23 bit ket qua nhan cao nhat de lam phan phan so cho ket qua 
   d3:	
   	addi	$t4,$zero,0x00004000 
   while1:
   	and	$t5,$t4,$s2      
   	bne	$t5,0,afterw1	 # Xet bit 47 co bang 1 hay khong, neu dung chuyen xuong afterw
   	bne 	$s1,0,d4	 # Xet xem phan mu co bang 0 hay khong
   	j	afterw2
   d4:	
   	sll	$s2,$s2,1	 # Dich trai ket qua nhan va giam so mu 
   	srl	$t6,$s3,31
   	add	$s2,$s2,$t6
   	sll	$s3,$s3,1
   	subiu	$s1,$s1,1
   	j	while1
   afterw1:
   	sll	$s2,$s2,1	 # Dich trai them ket qua 1 bit nhung khong giam so mu
   	srl	$t6,$s3,31
   	add	$s2,$s2,$t6
   afterw2:
   	sll	$s3,$s3,1	 # Loai bo bit dinh tri, lay 23 bit cao nhat lam phan phan so va tra ket qua
   	sll 	$s2,$s2,8
   	srl	$s3,$s3,24
  	add	$s2,$s2,$s3
   	sll	$s1,$s1,23
   	subu	$s2,$s2,0x00800000
   	j	result
   
  			
  Norm:	# Normalize x Normalize												
  	# Tinh toan phan dinh tri (2 so deu co bit dinh tri la 1)
  	addi	$s6,$s6,0x00800000
  	addi	$s7,$s7,0x00800000	
   	# Tinh toan phan mu cua ket qua
  	addu	$s1,$s4,$s5
  	addi	$t4,$zero,0x3F800000
  	sltu 	$t3,$s1,$t4
	beq	$t3,$zero,check1    
	# Neu ket qua exp1 + exp2 < bias:
	   # k = (bias (127) - exp1 + exp2)
	   # Phan mu ket qua bang 0
	   # k chinh la so bit dinh phai cua phan phan so sau khi nhan 2 phan phan so voi nhau
  	   # Xuat ket qua 
  	   # (Giai thuat tuong tu nhu truong hop Denormalize x Normalize voi truong hop exp1 + exp2 < bias)
  	srl	$t4,$s1,23
  	li	$t5,127
  	sub	$t4,$t5,$t4
	li	$s1,0 
   	multu	$s6,$s7
   	mfhi	$s2
   	mflo	$s3
   	sll 	$s2,$s2,8
   	srl	$s3,$s3,24
  	add	$s2,$s2,$s3
   	srlv	$s2,$s2,$t4
   	j	result
   	
   	# Neu ket qua exp1 + exp2 >= bias:
   check1:	
  	subiu	$s1,$s1,0x3F800000			
   	# Tinh toan phan phan so (23 bit) cua ket qua 
   	multu	$s6,$s7
   	mfhi	$s2
   	mflo	$s3
   	andi	$t3,$s2,32768
   	# Sau khi nhan xong ta se xoa phan dinh tri va lay 23 bit cao nhat lam phan phan so cho ket qua.
   	# Khi nhan hai so 24 bit voi nhau ket qua se co 2 truong hop xay ra: 47 bit va 48 bit
   	beq	$t3,0,frac
   	# TH 48 bit   	
   	sll 	$s2,$s2,8          
   	srl	$s3,$s3,24
   	add	$s2,$s2,$s3
   	subiu	$s2,$s2,0x00800000
   	addiu	$s1,$s1,0x00800000   	
   	j 	check2
   	# TH 47 bit
  frac:	 
   	sll 	$s2,$s2,9
   	srl	$s3,$s3,23
   	add	$s2,$s2,$s3
   	subiu	$s2,$s2,0x00800000
   	
   	# Sau khi tinh xong ket qua phan mu va phan phan so, 
   	# ta se phai kiem tra xem lieu co truong hop hai so nhan voi nhau ra ket qua Infinity khong
  	# De kiem tra dieu nay ta xet xem 8 bit phan mu cua ket qua co lon hon hoac bang 11111111 (255) hay khong)
  check2:
  	addi	$t4,$zero,0x7F800000 # 01111111100000000000000000000000
  	sltu 	$t3,$s1,$t4	     # So sanh phan mu
	bne	$t3,$zero,result     # Neu phan mu lon hon ta se tra ve ket qua Infinity, nguoc lai ta se xuat ket qua nhu binh thuong
	# Tra ve ket qua Infinity
	add	$t2,$s0,$t4	     
	mtc1	$t2,$f2
   	jr 	$ra
	
	# Luu ket qua 
  result:	
	add	$t2,$s0,$s1
	add	$t2,$t2,$s2	   	
   	mtc1	$t2,$f2
   	jr 	$ra
#------------------------------------------------#
