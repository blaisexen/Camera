package com.delphiworlds.firemonkey;

import android.hardware.camera2.CameraCharacteristics;
import android.hardware.camera2.params.StreamConfigurationMap;

public class DWCameraCharacteristicsHelper {

  private CameraCharacteristics mCharacteristics;

  public void setCameraCharacteristics(CameraCharacteristics characteristics) {
    this.mCharacteristics = characteristics;
  }

  public int getLensFacing() {
    return this.mCharacteristics.get(CameraCharacteristics.LENS_FACING);
  }

  public int[] getFaceDetectModes() {
    return this.mCharacteristics.get(CameraCharacteristics.STATISTICS_INFO_AVAILABLE_FACE_DETECT_MODES);
  }

  public StreamConfigurationMap getMap() {
    return this.mCharacteristics.get(CameraCharacteristics.SCALER_STREAM_CONFIGURATION_MAP);
  }

}

