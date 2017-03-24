package com.delphiworlds.firemonkey;

import android.hardware.camera2.*;

public class DWCameraDeviceStateCallback extends CameraDevice.StateCallback {

  private DWCameraDeviceStateCallbackListener mListener;

  public DWCameraDeviceStateCallback(DWCameraDeviceStateCallbackListener listener) {
    this.mListener = listener;
  }

  @Override
  public void onOpened(CameraDevice camera) {
    mListener.Opened(camera);
  }
      
  @Override
  public void onError(CameraDevice camera, int error) {
    mListener.Error(camera, error);
  }
  
  @Override
  public void onDisconnected(CameraDevice camera) {
    mListener.Disconnected(camera); 
  }

}