@echo off

setlocal
set crsfml_dir_name=tmp-crsfml-v2.5.3

if not exist ..\%crsfml_dir_name%\ (
  echo run win_shards_install.bat first
  exit /B 0
)

if exist lib\crsfml\ (
  echo clearing out lib\crsfml
  rmdir /s /q lib\crsfml
  mkdir lib\crsfml\
)

if exist ..\%crsfml_dir_name%\.git\ (
  rmdir /s /q ..\%crsfml_dir_name%\.git
)

echo copying compiled crsfml to lib\crsfml
xcopy /s ..\%crsfml_dir_name%\ lib\crsfml\

echo removing ..\%crsfml_dir_name%
rmdir /s /q ..\%crsfml_dir_name%
endlocal

echo done!
