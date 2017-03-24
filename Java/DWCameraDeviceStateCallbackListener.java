package com.delphiworlds.firemonkey;

import android.hardware.camera2.CameraDevice;

public interface DWCameraDeviceStateCallbackListener {

  void Opened(CameraDevice camera);

  void Disconnected(CameraDevice camera);

  void Error(CameraDevice camera, int error);
  
}