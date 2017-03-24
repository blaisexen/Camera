package com.delphiworlds.firemonkey;

import android.hardware.camera2.*;

public interface DWCameraCaptureSessionCaptureCallbackListener {

  void CaptureProgressed(CameraCaptureSession session, CaptureRequest request, CaptureResult partialResult);

  void CaptureCompleted(CameraCaptureSession session, CaptureRequest request, TotalCaptureResult result);
  
}