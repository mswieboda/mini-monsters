@echo off

echo shards install --skip-postinstall
shards install --skip-postinstall

setlocal
set current_path=%cd%
set crsfml_dir_name=tmp-crsfml-v2.5.3

if exist ..\%crsfml_dir_name%\ (
  echo %crsfml_dir_name% already exists
  echo run win_shards_postinstall.bat
  exit /B 0
)

echo cloning crsfml v2.5.3 to temp dir ..\%crsfml_dir_name%
git clone --branch v2.5.3 https://github.com/oprypin/crsfml.git ..\%crsfml_dir_name%

echo run win_shards_postinstall.bat after this make compiles (it might fail but still works)
pause

echo compiling crsfml v2.5.3
cd ..\%crsfml_dir_name% && make

echo run win_shards_postinstall.bat
endlocal