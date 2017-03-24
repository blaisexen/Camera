package com.delphiworlds.firemonkey;

import android.hardware.camera2.*;

public class DWCameraCaptureSessionStateCallback extends CameraCaptureSession.StateCallback {

  private DWCameraCaptureSessionStateCallbackListener mListener;

  public DWCameraCaptureSessionStateCallback(DWCameraCaptureSessionStateCallbackListener listener) {
    this.mListener = listener;
  }

  @Override
  public void onConfigured(CameraCaptureSession session) {
    mListener.Configured(session);
  }
  
  @Override
  public void onConfigureFailed(CameraCaptureSession session) {
    mListener.ConfigureFailed(session);
  }

}