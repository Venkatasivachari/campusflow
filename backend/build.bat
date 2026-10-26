@echo off
set "JAVA_HOME=C:\Program Files\Java\jdk-23"
call "%~dp0..\..\tools\apache-maven-3.9.9\bin\mvn.cmd" clean compile
