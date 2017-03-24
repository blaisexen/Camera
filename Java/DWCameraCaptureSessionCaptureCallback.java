package com.delphiworlds.firemonkey;

import android.hardware.camera2.*;

public class DWCameraCaptureSessionCaptureCallback extends CameraCaptureSession.CaptureCallback {

  private DWCameraCaptureSessionCaptureCallbackListener mListener;

  public DWCameraCaptureSessionCaptureCallback(DWCameraCaptureSessionCaptureCallbackListener listener) {
    this.mListener = listener;
  }

  @Override
  public void onCaptureProgressed(CameraCaptureSession session, CaptureRequest request, CaptureResult partialResult) {
    mListener.CaptureProgressed(session, request, partialResult);
  }

  @Override
  public void onCaptureCompleted(CameraCaptureSession session, CaptureRequest request, TotalCaptureResult result) {
    mListener.CaptureCompleted(session, request, result);
  }

}