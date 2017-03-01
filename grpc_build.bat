@echo off
pushd %~dp0

call "%VS140COMNTOOLS%..\..\VC\vcvarsall.bat" amd64

echo #### grpc build start!

cd grpc\third_party\zlib
mkdir build & cd build
mkdir debug & cd debug
cmake -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Debug ^
-DCMAKE_INSTALL_PREFIX=../../../../../install/debug ../..
nmake & nmake install

cd ..
mkdir release & cd release
cmake -G "NMake Makefiles" -DCMAKE_BUILD_TYPE=Release ^
-DCMAKE_INSTALL_PREFIX=../../../../../install/release ../..
nmake & nmake install

cd ../../../../../install/release/bin
set PATH=%PATH%;%cd%\bin

popd
pushd %~dp0

cd grpc\third_party\protobuf\cmake
mkdir build & cd build
mkdir solution & cd solution
cmake -G "Visual Studio 14 2015 Win64" -Dprotobuf_BUILD_TESTS=OFF ^
-Dprotobuf_WITH_ZLIB=ON ^
-DCMAKE_INSTALL_PREFIX=../../../../../../install/debug ../..
devenv.com protobuf.sln /build "Debug|x64" /project ALL_BUILD
if not %ERRORLEVEL% == 0 goto Finish
devenv.com protobuf.sln /build "Debug|x64" /project INSTALL


cmake -G "Visual Studio 14 2015 Win64" -Dprotobuf_BUILD_TESTS=OFF ^
-Dprotobuf_WITH_ZLIB=ON ^
-DCMAKE_INSTALL_PREFIX=../../../../../../install/release ../..
devenv.com protobuf.sln /build "Release|x64" /project ALL_BUILD
if not %ERRORLEVEL% == 0 goto Finish
devenv.com protobuf.sln /build "Release|x64" /project INSTALL


cd ..\..\..\..\..\vsprojects
devenv.com grpc_protoc_plugins.sln /build "Release|x64"
if not %ERRORLEVEL% == 0 goto Finish
robocopy .\x64\Release\ ..\..\install\release\bin /XF *.lib *.iobj *.ipdb
devenv.com grpc_protoc_plugins.sln /clean "Release|x64"

devenv.com grpc.sln /clean "Debug"
devenv.com grpc.sln /clean "Release"
devenv.com grpc.sln /build "Debug|x64" /project grpc++
devenv.com grpc.sln /build "Debug|x64" /project grpc++_unsecure
if not %ERRORLEVEL% == 0 goto Finish
robocopy /e .\x64\Debug ..\..\install\debug\lib

devenv.com grpc.sln /build "Release|x64" /project grpc++
devenv.com grpc.sln /build "Release|x64" /project grpc++_unsecure
if not %ERRORLEVEL% == 0 goto Finish
robocopy /e .\x64\Release ..\..\install\release\lib /XF *grpc_cpp_plugin*

devenv.com grpc.sln /clean "Debug"
devenv.com grpc.sln /clean "Release"
devenv.com grpc.sln /build "Debug-DLL|x64" /project grpc++
devenv.com grpc.sln /build "Debug-DLL|x64" /project grpc++_unsecure
if not %ERRORLEVEL% == 0 goto Finish
robocopy /e .\x64\Debug-DLL ..\..\install\debug\lib\dll

devenv.com grpc.sln /build "Release-DLL|x64" /project grpc++
devenv.com grpc.sln /build "Release-DLL|x64" /project grpc++_unsecure
if not %ERRORLEVEL% == 0 goto Finish
robocopy /e .\x64\Release-DLL ..\..\install\release\lib\dll /XF *grpc_cpp_plugin*

robocopy /e ..\include ..\..\install\debug\include
robocopy /e ..\include ..\..\install\release\include

echo #### grpc build done!

:Finish
rem devenv.com protobuf.sln /clean "Debug|x64"
rem devenv.com protobuf.sln /clean "Release|x64"
rem devenv.com grpc_protoc_plugins.sln /clean "Release|x64" /project grpc_cpp_plugin
rem devenv.com grpc.sln /clean "Debug|x64" /project grpc++
rem devenv.com grpc.sln /clean "Release|x64" /project grpc++
popd
pause
