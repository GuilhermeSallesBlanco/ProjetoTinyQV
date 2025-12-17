# Introdução
[explicar propósito do projeto e relevância do TinyTapeout]

# Alterações feitas
O projeto original, disponibilizado pela TinyTapeout nos repositórios:
- https://github.com/TinyTapeout/tinyqv-byte-peripheral-template
- https://github.com/MichaelBell/tinyQV

utilizava as ferramentas yosys para sintetizar os arquivos Verilog. Eles disponibilizaram um Makefile para automatizar o processo, mas, como o yosys não está sendo utilizado, algumas alterações tiveram que ser feitas na estrutura do projeto.
Essencialmente, foram colocados os arquivos verilog necessários no Lattice Diamond e gerado um arquivo .bit disso. Todos os arquivos verilog precisaram ser levemente editados para que o sintetizador do Lattice realizasse suas funções corretamente. 
Algumas das regras impostas pelo Lattice que tiveram que ser corrigidas são:
- rejeita default_nettype none sem declarar tipos explícitos (explicitar wire nas entradas)
- não aceita loops em initial
- não aceita certas expressões com sinais logic/wire misturados
- precisa de BRAMs seguindo padrões específicos
- não suporta lógica combinacional “implícita” do jeito que Yosys aceita
- não aceita memórias inicializadas com loops

Um grande ponto que precisou ser alterado por conta de restrições da placa FPGA foi o fato do programa original TinyQV já vir com vários periféricos dentro dele (dentro de peripherals.v). Esse arquivo era instanciado em top.v e, como não estava claro se a FPGA iria aguentar muitos periféricos, foi criado o arquivo peripherals_min.v, que possui apenas alguns periféricos básicos para a inicialização do processador.

# Progresso
## 20/11: Inclusão inicial de arquivos verilog
O arquivo sim_qspi.v não fazia parte desse commit, pois eu imaginava que era apenas para simulação. Mas, como escrito em https://github.com/TinyTapeout/ttsky25a-tinyQV/tree/main/fpga/generic, as memórias ROM e RAM são, na verdade, disponibilizadas por esse arquivo.
![WhatsApp Image 2025-11-20 at 15 59 10_0c4aa025](https://github.com/user-attachments/assets/950f3981-dd37-4066-8cf5-07aa25e5549f)

Arquivo .bit sintetizado com sucesso, mas sem colocar na placa ainda.

## 27/11: Inclusão do programa ledstrip.hex e sim_qspi.v.
O programa de exemplo do repositório do TinyQV (ledstrip.hex) foi adicionado ao projeto, assim como o arquivo sim_qspi.v. Supostamente, ele está carregando o programa e sintetizando o arquivo .bit.
<img width="815" height="574" alt="image" src="https://github.com/user-attachments/assets/7dd90058-b5e8-4276-9fcd-912cf7d8391b" />
<img width="987" height="409" alt="image" src="https://github.com/user-attachments/assets/f18c0ec2-40a0-4a11-b1cc-0afb1de152fb" />
bram.v também teve que ser alterado por conta de incompatibilidade de alguns comandos com o Lattice Diamond.

## 15/12 - 17/12: Instalação do riscv-gnu-toolchain 
<img width="1366" height="104" alt="image" src="https://github.com/user-attachments/assets/db470c67-7c8b-4566-994d-d0cbf42a3c45" />
Repositório do toolchain: https://github.com/MichaelBell/riscv-gnu-toolchain

Foi utilizado o RISC-V GNU Toolchain customizado para o TinyQV, compilado a partir do repositório oficial riscv-gnu-toolchain, configurado para a arquitetura rv32ec_zcb_zicond e ABI ilp32e. O compilador riscv32-unknown-elf-gcc foi gerado com sucesso.
