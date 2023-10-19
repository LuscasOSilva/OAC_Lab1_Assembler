.data
	localArquivo: .asciiz "C:\Users\lucas\Desktop\UnB\8semestre\OAC\Lab1\Repositório\arquivos-exemplos\example_saida.asm"
	conteudoArquivo: .space 1024 #quantidade de bytes do arquivo
.text
	#abrir o arquivo no modo leitura
	li $v0, 13 #solicita a abertura sem especificar o tipo de abertura
	la $a0, localArquivo # endereço do arquivo
	li $a1, 0 # 0 == leitura, 1 == escrita
	syscall # descritor do arquivo vai para $v0
	
	move $s0, $v0 #copia do descritor
	
	move $a0, $s0
	li $v0, 14 #ler conteudo do arquivo referenciado por $a0 == $v0
	la $a1, conteudoArquivo #buffer que armazena o conteudo do arquivo == $a1
	li $a2, 2048 #tamanho do buffer
	syscall #leitura realizada
	
	# imprimir o conteudo do arquivo
	li $v0, 4 # imprimir string // ela esta em $a0 pois movemos $v0 para $a0
	move $a0, $a1 # movendo o conteudo do arquivo para $a0
	syscall
	
	# fecha o arquivo
	li $v0, 16 # fecha o arquivo que está em $a0
	move $a0, $s0 # mandamos o conteudo salvo em $s0 para $a0 novamente
	syscall 