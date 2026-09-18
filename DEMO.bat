@echo off
cd /d "%~dp0"

dosbox\dosbox.exe -conf dosbox-crobots.conf ^
  -c "mount c jogo" ^
  -c "c:" ^
  -c "cls" ^
  -c "crobots rook.r sniper.r counter.r rabbit.r" ^
  -c "pause" ^
  -c "exit" ^
  -noconsole
