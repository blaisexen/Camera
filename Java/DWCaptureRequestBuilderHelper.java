package com.delphiworlds.firemonkey;

import android.hardware.camera2.CaptureRequest;
import android.hardware.camera2.CameraMetadata;

public class DWCaptureRequestBuilderHelper {

  private CaptureRequest.Builder mBuilder;

  public void setCaptureRequestBuilder(CaptureRequest.Builder builder) {
    this.mBuilder = builder;
  }

  public void setFaceDetectMode(int mode) {
    switch (mode) {
      case 0:
        this.mBuilder.set(CaptureRequest.STATISTICS_FACE_DETECT_MODE, CameraMetadata.STATISTICS_FACE_DETECT_MODE_OFF);
        break;
      case 1:
        this.mBuilder.set(CaptureRequest.STATISTICS_FACE_DETECT_MODE, CameraMetadata.STATISTICS_FACE_DETECT_MODE_SIMPLE);
        break;
      case 2:
        this.mBuilder.set(CaptureRequest.STATISTICS_FACE_DETECT_MODE, CameraMetadata.STATISTICS_FACE_DETECT_MODE_FULL);
        break;
    }
  }

}