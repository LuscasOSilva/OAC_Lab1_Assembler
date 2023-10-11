.data
	#Área para colocar os dados da memória principal do nosso programa
	msg: .asciiz "Olá, mundo!" #Mensagem que iremos imprimir
.text
	#Área para as instruções do programa
	li $v0, 4 #Instrução para impressão de String
	la $a0, msg #Indicar o endereço onde está a mensagem
	syscall #Comando para mandar imprimir