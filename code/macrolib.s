.macro check(%x, %y)
# Check if we met symbol before
loop:
	lb t1 (%y)
	beqz t1 record
	beq %x t1 out 
	addi %y %y 1
	j loop
		
record:
	sb %x (%y)
			
				
out:
	
.end_macro 
###############################################################
#Length of string.
.macro strlen(%x)
strl:
    li      t0 0        
loop:
    lb      t1 (%x)   
    beqz    t1 end
    addi    t0 t0 1		
    addi    %x %x 1		
    j       loop
end:
    mv      %x t0
 
.end_macro 
.macro read(%x, %y)
###############################################################
    li   	a7 1024     	# Системный вызов открытия файла
    la      a0 %x    # Имя открываемого файла
    li   	a1 0        	# Открыть для чтения (флаг = 0)
    ecall             		# Дескриптор файла в a0 или -1)
    li		s1 -1			# Проверка на корректное открытие
    beq		a0 s1 er_name	# Ошибка открытия файла
    mv   	s0 a0       	# Сохранение дескриптора файла
    
    li a7, 9
    li a0, TEXT_SIZE	# Размер блока памяти
    ecall
    
    mv 		s3, a0			# Сохранение адреса кучи в регистре
    mv 		s5, a0			# Сохранение изменяемого адреса кучи в регистре
    li		s4, TEXT_SIZE	# Сохранение константы для обработки
    mv		s6, zero
    
###############################################################
    # Чтение информации из открытого файла
read_loop:
    li   a7, 63       # Системный вызов для чтения из файла
    mv   a0, s0       # Дескриптор файл
    la   a1, %y   # Адрес буфера для читаемого текста
    li   a2, TEXT_SIZE # Размер читаемой порции
    
    ecall             # Чтение
    
    beq		a0 s1 er_read	# Ошибка чтения
    mv   	s2 a0       	# Сохранение длины текста
    add 	s6, s6, s2		# Размер текста увеличивается на прочитанную порцию
    # При длине прочитанного текста меньшей, чем размер буфера,
    # необходимо завершить процесс.
    bne		s2 s4 end_loop
    
    li a7, 9
    li a0, TEXT_SIZE	# Размер блока памяти
    ecall
    
    add		s5 s5 s2		# Адрес для чтения смещается на размер порции
    b read_loop				# Обработка следующей порции текста из файла
end_loop:
    
    
###############################################################
    # Закрытие файла
    li   a7, 57       # Системный вызов закрытия файла
    mv   a0, s0       # Дескриптор файла
    ecall             # Закрытие файла
###############################################################
    # Установка нуля в конце прочитанной строки
    la	t0 %y	 # Адрес начала буфера
    add t0 t0 s2	 # Адрес последнего прочитанного символа
    addi t0 t0 1	 # Место для нуля
    sb	zero (t0)	 # Запись нуля в конец текста
###############################################################
.end_macro 
###############################################################
#Writing a file
.macro write(%x, %y)
default:
    la   a0, %y 

out:
    # Open (for writing) a file that does not exist
    li   a7, 1024     # system call for open file
    li   a1, 1        # Open for writing (flags are 0: read, 1: write)
    ecall             # open a file (file descriptor returned in a0)
    mv   s6, a0       # save the file descriptor

    # Write to file just opened
    li   a7, 64       # system call for write to file
    mv   a0, s6       # file descriptor
    la   a1, %x   # address of buffer from which to write
    li   a2, 44       # hardcoded buffer length
    ecall             # write to file

    # Close the file
    li   a7, 57       # system call for close file
    mv   a0, s6       # file descriptor to close
    ecall             # close file
    
.end_macro 
###############################################################
.macro exit()
    li a7, 10
    ecall
.end_macro
###############################################################
.macro intToString(%x, %y)
int_to_string:
    # Initialize variables
    li   t0, 10           # Divisor for dividing by 10  
convert_loop:
    # Amount of unique symbols less than 100, so we don't need to do loop for converting int to char.
	div t1 %x t0
	beqz t1 second
	addi t1 t1 48
	sb   t1, 0(%y)
	
	addi %y, %y, 1
second:	
	rem t1 %x t0
	addi t1 t1 48
	sb   t1, 0(%y)
	addi %y %y 1
done:
.end_macro
###############################################################
.macro push(%x)
	addi	sp, sp, -4
	sw	%x, (sp)
.end_macro
###############################################################
.macro pop(%x)
	lw	%x, (sp)
	addi	sp, sp, 4
.end_macro
