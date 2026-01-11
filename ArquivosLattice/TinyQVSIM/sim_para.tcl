lappend auto_path "C:/lscc/diamond/3.14/data/script"
package require simulation_generation
set ::bali::simulation::Para(DEVICEFAMILYNAME) {ECP5U}
set ::bali::simulation::Para(PROJECT) {TinyQVSIM}
set ::bali::simulation::Para(PROJECTPATH) {C:/Users/Guilherme Blanco/Desktop/College/EmbarcatechFase3/ProjetoTinyQV/ProjetoTinyQV}
set ::bali::simulation::Para(FILELIST) {"C:/Users/Guilherme Blanco/Desktop/College/EmbarcatechFase3/ProjetoTinyQV/ProjetoTinyQV/impl1/source/latch_reg.v" "C:/Users/Guilherme Blanco/Desktop/College/EmbarcatechFase3/ProjetoTinyQV/ProjetoTinyQV/led.v" "C:/Users/Guilherme Blanco/Desktop/College/EmbarcatechFase3/ProjetoTinyQV/ProjetoTinyQV/impl1/source/peripherals_min.v" "C:/Users/Guilherme Blanco/Desktop/College/EmbarcatechFase3/ProjetoTinyQV/ProjetoTinyQV/impl1/source/qspi_flash.v" "C:/Users/Guilherme Blanco/Desktop/College/EmbarcatechFase3/ProjetoTinyQV/ProjetoTinyQV/impl1/source/uart_tx.v" "C:/Users/Guilherme Blanco/Desktop/College/EmbarcatechFase3/ProjetoTinyQV/ProjetoTinyQV/impl1/source/qspi_ctrl.v" "C:/Users/Guilherme Blanco/Desktop/College/EmbarcatechFase3/ProjetoTinyQV/ProjetoTinyQV/impl1/source/mem_ctrl.v" "C:/Users/Guilherme Blanco/Desktop/College/EmbarcatechFase3/ProjetoTinyQV/ProjetoTinyQV/impl1/source/counter.v" "C:/Users/Guilherme Blanco/Desktop/College/EmbarcatechFase3/ProjetoTinyQV/ProjetoTinyQV/impl1/source/time.v" "C:/Users/Guilherme Blanco/Desktop/College/EmbarcatechFase3/ProjetoTinyQV/ProjetoTinyQV/impl1/source/alu.v" "C:/Users/Guilherme Blanco/Desktop/College/EmbarcatechFase3/ProjetoTinyQV/ProjetoTinyQV/impl1/source/register.v" "C:/Users/Guilherme Blanco/Desktop/College/EmbarcatechFase3/ProjetoTinyQV/ProjetoTinyQV/impl1/source/core.v" "C:/Users/Guilherme Blanco/Desktop/College/EmbarcatechFase3/ProjetoTinyQV/ProjetoTinyQV/impl1/source/decode.v" "C:/Users/Guilherme Blanco/Desktop/College/EmbarcatechFase3/ProjetoTinyQV/ProjetoTinyQV/impl1/source/cpu.v" "C:/Users/Guilherme Blanco/Desktop/College/EmbarcatechFase3/ProjetoTinyQV/ProjetoTinyQV/impl1/source/tinyqv.v" "C:/Users/Guilherme Blanco/Desktop/College/EmbarcatechFase3/ProjetoTinyQV/ProjetoTinyQV/impl1/source/bram.v" "C:/Users/Guilherme Blanco/Desktop/College/EmbarcatechFase3/ProjetoTinyQV/ProjetoTinyQV/impl1/source/sim_qspi.v" "C:/Users/Guilherme Blanco/Desktop/College/EmbarcatechFase3/ProjetoTinyQV/ProjetoTinyQV/impl1/source/top.v" "C:/Users/Guilherme Blanco/Desktop/College/EmbarcatechFase3/ProjetoTinyQV/ProjetoTinyQV/impl1/source/uart_rx.v" }
set ::bali::simulation::Para(GLBINCLIST) {}
set ::bali::simulation::Para(INCLIST) {"none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none" "none"}
set ::bali::simulation::Para(WORKLIBLIST) {"work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" "work" }
set ::bali::simulation::Para(COMPLIST) {"VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" "VERILOG" }
set ::bali::simulation::Para(LANGSTDLIST) {"Verilog 2001" "Verilog 2001" "Verilog 2001" "Verilog 2001" "Verilog 2001" "Verilog 2001" "Verilog 2001" "Verilog 2001" "Verilog 2001" "Verilog 2001" "Verilog 2001" "Verilog 2001" "Verilog 2001" "Verilog 2001" "Verilog 2001" "Verilog 2001" "Verilog 2001" "Verilog 2001" "Verilog 2001" }
set ::bali::simulation::Para(SIMLIBLIST) {pmi_work ovi_ecp5u}
set ::bali::simulation::Para(MACROLIST) {}
set ::bali::simulation::Para(SIMULATIONTOPMODULE) {tinyQV_top}
set ::bali::simulation::Para(SIMULATIONINSTANCE) {}
set ::bali::simulation::Para(LANGUAGE) {VERILOG}
set ::bali::simulation::Para(SDFPATH)  {}
set ::bali::simulation::Para(INSTALLATIONPATH) {C:/lscc/diamond/3.14}
set ::bali::simulation::Para(ADDTOPLEVELSIGNALSTOWAVEFORM)  {1}
set ::bali::simulation::Para(RUNSIMULATION)  {1}
set ::bali::simulation::Para(SIMULATION_RESOLUTION)  {default}
set ::bali::simulation::Para(HDLPARAMETERS) {}
set ::bali::simulation::Para(POJO2LIBREFRESH)    {}
set ::bali::simulation::Para(POJO2MODELSIMLIB)   {}
set ::bali::simulation::Para(OPTIMIZEARGS)  {+acc}
set ::bali::simulation::Para(OPTIMIZATION_DEBUG)  {1}
::bali::simulation::QuestaSim_Run
