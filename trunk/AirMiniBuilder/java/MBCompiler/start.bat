@ECHO OFF

java -jar VerTest.jar
IF ERRORLEVEL 1 GOTO END

CD %USERPROFILE%\.mbcompiler
IF NOT EXIST sdkpath GOTO NOSETUP
FOR /F "delims=," %%A IN (sdkpath) DO SET FLEX_SDK=%%A


ECHO %FLEX_SDK%

REM SET FLEX_SDK=C:\Program Files\Adobe\Flash Builder Plug-in Beta\sdks\3.4.0


SET HOME=%~dp0
SET AH=-Dapplication.home=%FLEX_SDK%
SET JA=-Xmx384m -Dsun.io.useCanonCaches=false
SET JNI=-Djava.library.path=.
REM SET NOVERBOSE=-nv

CD %HOME%
java %JA% "%AH%" "%JNI%" -classpath "%HOME%jnotify-0.91.jar;%HOME%MBCompiler.jar;%FLEX_SDK%\lib\*" ro.minibuilder.MBCompiler %NOVERBOSE%

GOTO END

:NOSETUP
ECHO.
ECHO Start MiniBuilder and set Flex SDK path

:END