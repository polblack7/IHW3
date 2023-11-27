# Чтение текста из файла, задаваемого в диалоге, в буфер фиксированного размера
.eqv    NAME_SIZE 256	# Размер буфера для имени файла
.eqv    TEXT_SIZE 512	# Размер буфера для текста

    .data
default_name: .asciz "/Users/nikitaannenkov/Desktop/abc/testout.txt"
newfile:		.asciz "\nOutput file path: "     # Путь до читаемого файла
prompt:         .asciz "Input file path: "     # Путь до читаемого файла
er_name_mes:    .asciz "Incorrect file name\n"
er_read_mes:    .asciz "Incorrect read operation\n"
uniqcnt:		.asciz "\nNumber of unique characters: "
newstr: .asciz 
	.space TEXT_SIZE 
result: .space NAME_SIZE
final: 	.space	NAME_SIZE
file_name:      .space	NAME_SIZE		# Имячитаемого файла
strbuf:	.space TEXT_SIZE			# Буфер для читаемого текста
output_name: .space	NAME_SIZE
.include "macrolib.s"
        .text
###############################################################
    # Вывод подсказки
    la		a0 prompt
    li		a7 4
    ecall
    # Ввод имени файла с консоли эмулятора
    la		a0 file_name
    li      a1 NAME_SIZE
    li      a7 8
    ecall
    # Убрать перевод строки
    li	t4 '\n'
    la	t5	file_name
loop:
    lb	t6  (t5)
    beq t4	t6	replace
    addi t5 t5 1
    b	loop
replace:
    sb	zero (t5)
###############################################################
#Читаем файл     
read(file_name, strbuf)
###############################################################    
    
############################################################### 
#Ищем уникальные символы.  
	la 	a0 strbuf
    li s9 41
check_loop:
	la a1 newstr
	lb t0 (a0)
	beqz t0 end
	blt t0 s9 point
    check(t0, a1)
point:
    addi a0 a0 1  
    j check_loop
 
###############################################################
#Выводим все уникальные символы
end:
    la 	a0 newstr
    li 	a7 4
    ecall
###############################################################
#Выводим текст для кол-ва уникальных символов.    
    la a0 uniqcnt
    li a7 4
    ecall
###############################################################
#Преобразуем из интав в стринг.       
    la a0 newstr
    strlen(a0)    
    la a1 result
    intToString(a0, a1)
    
###############################################################
#Вывод кол ва уникальных символов
    la a0 result
    li a7 4
    ecall
    
    
###############################################################
#Вводим путь к новому файлу
    la		a0 newfile
    li		a7 4
    ecall
    
    la		a0 output_name
    li      a1 NAME_SIZE
    li      a7 8
    ecall
###############################################################
#Убираем перенос строки в конце пути
fix:   
    li	t4 '\n'
    la	t5	output_name
loop_fix:
    lb	t6  (t5)
    beq t4	t6	replace_fix
    addi t5 t5 1
    b	loop_fix
replace_fix:
    sb	zero (t5)
###############################################################
#Запись кол-ва уникальных символов в файл.
	write(result, output_name)
###############################################################
#Выход.
    exit()
###############################################################
er_name:
    # Сообщение об ошибочном имени файла
    la		a0 er_name_mes
    li		a7 4
    ecall
    # И завершение программы
    li		a7 10
    ecall
###############################################################
er_read:
    # Сообщение об ошибочном чтении
    la		a0 er_read_mes
    li		a7 4
    ecall
    # И завершение программы
    li		a7 10
    ecall
