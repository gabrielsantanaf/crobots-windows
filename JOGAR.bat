@echo off
cd /d "%~dp0"

if not exist "dosbox\dosbox.exe" (
  echo.
  echo ERRO: nao encontrei dosbox\dosbox.exe
  echo Leia o arquivo LEIA-ME.txt
  echo.
  pause
  exit /b 1
)

if not exist "jogo\crobots.exe" (
  echo.
  echo ERRO: nao encontrei jogo\crobots.exe
  echo Leia o arquivo LEIA-ME.txt
  echo.
  pause
  exit /b 1
)

dosbox\dosbox.exe -conf dosbox-crobots.conf ^
  -c "mount c jogo" ^
  -c "c:" ^
  -c "cls" ^
  -c "echo ================================================" ^
  -c "echo   CROBOTS" ^
  -c "echo ================================================" ^
  -c "echo." ^
  -c "echo   Ver os robos disponiveis:   dir *.r" ^
  -c "echo   Rodar uma partida:          crobots meu.r sniper.r" ^
  -c "echo   Rodar 100 partidas:         crobots -m100 meu.r sniper.r" ^
  -c "echo   Sair:                       exit" ^
  -c "echo." ^
  -noconsole
