package com.delphiworlds.firemonkey;

import android.hardware.camera2.CaptureResult;
import android.hardware.camera2.params.Face;

public class DWCaptureResultHelper {

  private CaptureResult mCaptureResult;

  public void setCaptureResult(CaptureResult captureResult) {
    this.mCaptureResult = captureResult;
  }

  public Face[] getFaces() {
    return this.mCaptureResult.get(CaptureResult.STATISTICS_FACES);
  }

  public int getFaceDetectMode() {
    return this.mCaptureResult.get(CaptureResult.STATISTICS_FACE_DETECT_MODE);
  }

}