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
<img width="1600" height="766" alt="image" src="https://github.com/user-attachments/assets/fb2d0e85-69b8-4d53-87ba-39a1b63dd328" />
<img width="935" height="114" alt="image" src="https://github.com/user-attachments/assets/f7185840-0abd-445f-a5f9-76a93f3874ed" />
Repositório do toolchain: https://github.com/MichaelBell/riscv-gnu-toolchain

Foi utilizado o RISC-V GNU Toolchain customizado para o TinyQV, compilado a partir do repositório oficial riscv-gnu-toolchain, configurado para a arquitetura rv32ec_zcb_zicond e ABI ilp32e. O compilador riscv32-unknown-elf-gcc foi gerado com sucesso. Assim, foi possível criar os arquivos .hex, .elf e .bin necessários para a inclusão do programa no TinyQV.

## 29/12 - 01/01: Correção do toolchain, instalação do SDK e mais testes
Durante a etapa de testes de outros programas criados para o TinyQV (https://github.com/MichaelBell/tinyQV-projects), percebeu-se que nenhum deles estavam sendo compilados corretamente. Isso foi por conta do fato do SDK não ter sido instalado corretamente, e o Makefile antigo apresentava alguns problemas. Após instalar o SDK e fazer vários ajustes ao Makefile, verificou-se que o toolchain previamente instalado veio com alguns problemas (o toolchain havia sido compilado para RV32I com ABI ilp32, enquanto o TinyQV requer  a arquitetura RV32EC com ABI ilp32e), e que teria de ser instalado novamente. 

Da última vez, eu não tinha percebido que o toolchain (https://github.com/MichaelBell/riscv-gnu-toolchain) havia uma página de "releases", que facilitou muito o processo de instalação. Assim feita essa instalação "semi-automática", foi possível compilar programas que utilizavam do SDK do TinyQV (especialmente os programas que usam bibliotecas presentes no SDK).

Os próximos passos envolvem mais testes com mais bibliotecas, inclusão de periféricos no projeto Verilog para comunicação com a FPGA e colocar o TinyQV na FPGA (após ter certeza de que ele foi corretamente inserido no projeto Verilog).

## 01/01 - 21/01: Reinstalação do SDK, desistência do Lattice, LED piscando corretamente
Ao passar do tempo, percebeu-se que a utilização do Lattice Diamond estava atrapalhando mais que ajudando. Assim, eu desisti dessa ideia e usei o Yosys para geração do bitstream, já que é o programa recomendado pelo próprio repositório do TinyQV. Para que o Yosys funcionasse na placa Colorlight-i9 (que é do tipo ECP5), o Makefile providenciado pelo repositório do TinyQV precisava ser alterado para que o Yosys realizasse o processo de geração de bitstream correto. Esse processo inclui, assim como no Lattice, a inclusão de um arquivo LPF.

Adicionalmente, eu percebi que o SDK que estava utilizando era uma versão desatualizada, assim, tive que reinstalar ele novamente e recompilar os programas C que estava usando no SDK novo, isso incluindo as alterações necessárias aos diversos Makefiles sendo utilizados (geração de bitstream, código C -> código hex (a versão correta está dentro de testeUART), etc).

Em algum momento, eu estava em dúvida se eu havia clonado o repositório do TinyQV corretamente, e decidi reiniciar todo o processo de clonagem do TinyQV. Isso levou a alguns problemas: lidar com o fato de que talvez esteja usando todos os periféricos de usuários (acabou não sendo o caso, pois peripherals.v não chama todos os periféricos como eu imaginava); lidar com uma leve desorganização dos diretórios; gerenciar três terminais diferentes (um terminal WSL para usar o Yosys, outro WSL para usar o SDK e um terminal do Windows para usar o oss-cad-suite para colocar o bitstream na placa), entre outros desafios.

Eventualmente, eu consegui controlar o LED da FPGA por meio de um programa C, comprovando que o processador estava realizando seu papel corretamente. Os próximos passos incluem a utilização de outros periféricos e programas C mais complexos, como a inclusão de sinais de entrada para controle de saída.