.data
	localArquivo: .ascii "" # Caminho do arquivo
	conteudoArquivo: .space 1024 # Quantidade de bytes do arquivo
	inputPrompt: .asciiz "Digite o caminho completo do arquivo: " # Mostrar mensagem para usuario
	localArquivoData: .space 1024 # Caminho do arquivo _data.mif que será criado
	localArquivoText: .space 1024 # Caminho do arquivo _text.mif que será criado
	dataExtension: .asciiz "_data.mif"
    	textExtension: .asciiz "_text.mif"
    	startData: .ascii "DEPTH = 16384;\nWIDTH = 32;\nADDRESS_RADIX = HEX;\nDATA_RADIX = HEX;\nCONTENT\nBEGIN\n\n"
    	startText: .ascii "DEPTH = 4096;\nWIDTH = 32;\nADDRESS_RADIX = HEX;\nDATA_RADIX = HEX;\nCONTENT\nBEGIN\n\n"

	lw_opcode: .asciiz "000010"
	add_opcode: .asciiz "000000"
	sub_opcode: .asciiz "000000"
	and_opcode: .asciiz "000000"
	or_opcode: .asciiz "000000"
	nor_opcode: .asciiz "000000"
	xor_opcode: .asciiz "000000"
	sw_opcode: .asciiz "101011"
	j_opcode: .asciiz "000010"
	jr_opcode: .asciiz "000000"
	jal_opcode: .asciiz "000011"
	beq_opcode: .asciiz "000100"
	bne_opcode: .asciiz "000101"
	slt_opcode: .asciiz "000000"
	lui_opcode: .asciiz "001111"
	addu_opcode: .asciiz "000000"
	subu_opcode: .asciiz "000000"
	sll_opcode: .asciiz "000000"
	srl_opcode: .asciiz "000000"
	addi_opcode: .asciiz "001000"
	andi_opcode: .asciiz "001100"
	ori_opcode: .asciiz "001101"
	xori_opcode: .asciiz "001110"
	mult_opcode: .asciiz "000000"
	div_opcode: .asciiz "000000"
	mfhi_opcode: .asciiz "000000"
	mflo_opcode: .asciiz "000000"
	bgez_opcode: .asciiz "000001"
	clo_opcode: .asciiz "011100"
	srav_opcode: .asciiz "000000"
	sra_opcode: .asciiz "000000"
	bgezal_opcode: .asciiz "000001"
	addiu_opcode: .asciiz "001001"
	lb_opcode: .asciiz "100000"
	movn_opcode: .asciiz "000000"
	mul_opcode: .asciiz "011100"
	sb_opcode: .asciiz "101000"
	slti_opcode: .asciiz "001010"
	sltu_opcode: .asciiz "000000"

	reg_zero: .asciiz "00000"
	reg_at: .asciiz "00001"
	reg_v0: .asciiz "00010"
	reg_v1: .asciiz "00011"
	reg_a0: .asciiz "00100"
	reg_a1: .asciiz "00101"
	reg_a2: .asciiz "00110"
	reg_a3: .asciiz "00111"
	reg_t0: .asciiz "01000"
	reg_t1: .asciiz "01001"
	reg_t2: .asciiz "01010"
	reg_t3: .asciiz "01011"
	reg_t4: .asciiz "01100"
	reg_t5: .asciiz "01101"
	reg_t6: .asciiz "01110"
	reg_t7: .asciiz "01111"
	reg_s0: .asciiz "10000"
	reg_s1: .asciiz "10001"
	reg_s2: .asciiz "10010"
	reg_s3: .asciiz "10011"
	reg_s4: .asciiz "10100"
	reg_s5: .asciiz "10101"
	reg_s6: .asciiz "10110"
	reg_s7: .asciiz "10111"
	reg_t8: .asciiz "11000"
	reg_t9: .asciiz "11001"
	reg_k0: .asciiz "11010"
	reg_k1: .asciiz "11011"
	reg_gp: .asciiz "11100"
	reg_sp: .asciiz "11101"
	reg_fp: .asciiz "11110"
	reg_ra: .asciiz "11111"

	resultOpcode: .asciiz ""
	resultRs: .asciiz ""
	resultRt: .asciiz ""
	resultRd: .asciiz ""
	resultShamt: .asciiz ""
	resultFunc: .asciiz ""
	
	resultImm: .asciiz ""
	
	resultOffset: .asciiz ""
.text
.globl main

main:
    ##################################################################
    # Receber arquivo asm
    ##################################################################
    # Solicitar o caminho completo do arquivo
    li $v0, 4 # Imprimir String
    la $a0, inputPrompt # Mostra mensagem em $a0
    syscall

    # Ler o caminho do arquivo fornecido pelo usuário
    li $v0, 8 # Pegar input do usuario
    la $a0, localArquivo # Onde ficará armazenada a entrada
    li $a1, 1024 # Tamanho máximo da entrada
    syscall

    # Remover o caractere de nova linha (linefeed) da string de entrada
    la $t0, localArquivo  # Registrador $t0 aponta para a string
    lb $t1, ($t0)       # Carrega o primeiro caractere da string
    while:
        beqz $t1, done  # Se o caractere for nulo, saia do loop
        beq $t1, 10, remove_nl  # Se o caractere for uma nova linha (10), vá para a etapa de remoção
        addi $t0, $t0, 1  # Avance para o próximo caractere
        lb $t1, ($t0)     # Carregue o próximo caractere da string
        j while

    remove_nl:
        # Substitua o caractere de nova linha por um caractere nulo
        sb $zero, ($t0)  # Armazena um caractere nulo para substituir o caractere de nova linha
    
    ###################################################### CRIANDO OS NOVOS ARQUIVOS data.mif e text.mif
    done:
    # Inicialize registradores
    la $s0, localArquivo  # Aponte para o início de localArquivo
    la $s1, localArquivoData  # Aponte para o espaço de localArquivoData
    la $s2, localArquivoText  # Aponte para o espaço de localArquivoText

    # Copie o conteúdo de localArquivo em localArquivoData e localArquivoText
    copy_loop:
        lb $t0, ($s0)  # Carregue o caractere de localArquivo
        beqz $t0, copy_extensions  # Se for nulo, vá para a cópia das extensões
        beq $t0, 46, copy_extensions  # Se for um ponto, vá para a cópia das extensões
        sb $t0, ($s1)  # Copie o caractere para localArquivoData
        sb $t0, ($s2)  # Copie o caractere para localArquivoText
        addi $s0, $s0, 1  # Avance para o próximo caractere em localArquivo
        addi $s1, $s1, 1  # Avance para o próximo caractere em localArquivoData
        addi $s2, $s2, 1  # Avance para o próximo caractere em localArquivoText
        j copy_loop

    copy_extensions:
    # Copie as extensões em localArquivoData e localArquivoText
    la $s3, dataExtension  # Aponte para a extensão "_data.mif"
    la $s4, textExtension  # Aponte para a extensão "_text.mif"

    copy_data_extension:
        lb $t0, ($s3)  # Carregue o caractere da extensão "_data.mif"
        beqz $t0, copy_text_extension  # Se for nulo, vá para a cópia da extensão "_text.mif"
        sb $t0, ($s1)  # Copie o caractere para localArquivoData
        addi $s1, $s1, 1  # Avance para o próximo caractere em localArquivoData
        addi $s3, $s3, 1  # Avance para o próximo caractere na extensão "_data.mif"
        j copy_data_extension

    copy_text_extension:
        lb $t0, ($s4)  # Carregue o caractere da extensão "_text.mif"
        beqz $t0, copy_done  # Se for nulo, termine
        sb $t0, ($s2)  # Copie o caractere para localArquivoText
        addi $s2, $s2, 1  # Avance para o próximo caractere em localArquivoText
        addi $s4, $s4, 1  # Avance para o próximo caractere na extensão "_text.mif"
        j copy_text_extension

    copy_done:
    # Terminar as strings com um caractere nulo
    sb $zero, ($s1)
    sb $zero, ($s2)
    	
    ######################################################
    
    #abrir o arquivo de entrada no modo leitura
    li $v0, 13 #solicita a abertura sem especificar o tipo de abertura
    la $a0, localArquivo # endereço do arquivo
    li $a1, 0 # 0 == leitura, 1 == escrita
    syscall # Descritor do arquivo vai para $v0
    
    move $s7, $v0 # Cópia do descritor
    
    move $a0, $s0
    li $v0, 14 #ler conteudo do arquivo referenciado por $a0 == $v0
    la $a1, conteudoArquivo #buffer que armazenará o conteudo do arquivo == $a1
    li $a2, 1024 #tamanho do buffer
    syscall #leitura realizada
    ############################################
    # Ler arquivo de entrada
    
    
    
    
    
    
    ##################################################################
    # Criar arquivo 
    ##################################################################
    # Abrir o arquivo para escrita (ou criar se não existir)
    li $v0, 13            # Código da chamada de sistema para abrir ou criar arquivo
    la $a0, localArquivoData     # Carregue o endereço da string com o nome do arquivo
    li $a1, 1             # Modo de abertura (1 para escrita)
    li $a2, 0             # Permissões (não importa para escrita)
    syscall

    move $s6, $v0 #copia do descritor
    
    # Abrir o arquivo para escrita (ou criar se não existir)
    li $v0, 13            # Código da chamada de sistema para abrir ou criar arquivo
    la $a0, localArquivoText     # Carregue o endereço da string com o nome do arquivo
    li $a1, 1             # Modo de abertura (1 para escrita)
    li $a2, 0             # Permissões (não importa para escrita)
    syscall

    move $s5, $v0 #copia do descritor
    
    # Escrever a string inicial no arquivo de data
    li $v0, 15 # Código da chamada de sistema para escrever no arquivo
    move $a0, $s6 # Descritor de arquivo para escrita
    la $a1, startData # Endereço da string a ser escrita
    li $a2, 81 # Comprimento da string a ser escrita (ajuste conforme necessário)
    syscall
    
    # Escrever a string inicial no arquivo de texto
    li $v0, 15 # Código da chamada de sistema para escrever no arquivo
    move $a0, $s5 # Descritor de arquivo para escrita
    la $a1, startText # Endereço da string a ser escrita
    li $a2, 80 # Comprimento da string a ser escrita (ajuste conforme necessário)
    syscall
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    # fecha o arquivo
    li $v0, 16 # fecha o arquivo que está em $a0
    move $a0, $s7 # mandamos o conteudo salvo em $s0 para $a0 novamente
    syscall
    
    # Fechar o arquivo
    li $v0, 16 # Código da chamada de sistema para fechar arquivo
    move $a0, $s6 # Descritor de arquivo a ser fechado
    syscall
    
    # Fechar o arquivo
    li $v0, 16 # Código da chamada de sistema para fechar arquivo
    move $a0, $s5 # Descritor de arquivo a ser fechado
    syscall
    
    # Encerrar o programa
    li $v0, 10
    syscall
