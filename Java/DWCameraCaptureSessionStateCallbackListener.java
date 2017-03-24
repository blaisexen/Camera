package com.delphiworlds.firemonkey;

import android.hardware.camera2.CameraCaptureSession;

public interface DWCameraCaptureSessionStateCallbackListener {

  void Configured(CameraCaptureSession session);

  void ConfigureFailed(CameraCaptureSession session);
  
}