@echo off

REM Adjust the values below for your environment
set BDS_DIR="C:\Program Files (x86)\Embarcadero\Studio\18.0"
set BDS_ANDROID=%BDS_DIR%\lib\android\release
set ANDROID_DIR="C:\Users\Public\Documents\Embarcadero\Studio\18.0\PlatformSDKs\android-sdk-windows"
set ANDROID_PLATFORM=%ANDROID_DIR%\platforms\android-23
set ANDROID_BUILD=%ANDROID_DIR%\build-tools\23.0.3
set JDK_PATH="C:\Program Files\Java\jdk1.7.0_80\bin"

set OUTPUT_DIR=.\Jar

REM Setup output paths
rmdir %OUTPUT_DIR% /S /Q> nul
mkdir %OUTPUT_DIR% 2> nul
mkdir %OUTPUT_DIR%\classes 2> nul

echo.
echo Compiling Java Sources
%JDK_PATH%\javac -Xlint:deprecation -cp %ANDROID_PLATFORM%\android.jar;%BDS_ANDROID%\fmx.jar -d %OUTPUT_DIR%\classes ^
.\Java\DWCaptureResultHelper.java ^
.\Java\DWCaptureRequestBuilderHelper.java ^
.\Java\DWCameraCharacteristicsHelper.java ^
.\Java\DWCameraDeviceStateCallback.java ^
.\Java\DWCameraDeviceStateCallbackListener.java ^
.\Java\DWCameraCaptureSessionCaptureCallback.java ^
.\Java\DWCameraCaptureSessionCaptureCallbackListener.java ^
.\Java\DWCameraCaptureSessionStateCallback.java ^
.\Java\DWCameraCaptureSessionStateCallbackListener.java

echo Creating jar containing the new classes
%JDK_PATH%\jar cf %OUTPUT_DIR%\dw-camera.jar -C %OUTPUT_DIR%\classes com

pause