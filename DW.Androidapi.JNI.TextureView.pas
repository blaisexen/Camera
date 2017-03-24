unit DW.Androidapi.JNI.TextureView;

interface

uses
  // Android
  Androidapi.JNIBridge, Androidapi.JNI.GraphicsContentViewText, Androidapi.JNI.JavaTypes, Androidapi.JNI.Os, Androidapi.JNI.Util;

type
  JTextureView = interface;//android.view.TextureView
  JTextureView_SurfaceTextureListener = interface;//android.view.TextureView$SurfaceTextureListener

  JTextureViewClass = interface(JViewClass)
    ['{B61657F8-975F-44DD-98BD-627EDAEAA15D}']
    {class} function init(context: JContext): JTextureView; cdecl; overload;
    {class} function init(context: JContext; attrs: JAttributeSet): JTextureView; cdecl; overload;
    {class} function init(context: JContext; attrs: JAttributeSet; defStyleAttr: Integer): JTextureView; cdecl; overload;
    {class} function init(context: JContext; attrs: JAttributeSet; defStyleAttr: Integer; defStyleRes: Integer): JTextureView; cdecl; overload;
  end;

  [JavaSignature('android/view/TextureView')]
  JTextureView = interface(JView)
    ['{F0FC4FB8-64C8-4BA6-B768-A4E67C9397CC}']
    procedure buildLayer; cdecl;
    procedure draw(canvas: JCanvas); cdecl;
    function getBitmap: JBitmap; cdecl; overload;
    function getBitmap(width: Integer; height: Integer): JBitmap; cdecl; overload;
    function getLayerType: Integer; cdecl;
    function getSurfaceTexture: JSurfaceTexture; cdecl;
    function getSurfaceTextureListener: JTextureView_SurfaceTextureListener; cdecl;
    function getTransform(transform: JMatrix): JMatrix; cdecl;
    function isAvailable: Boolean; cdecl;
    function isOpaque: Boolean; cdecl;
    function lockCanvas: JCanvas; cdecl; overload;
    function lockCanvas(dirty: JRect): JCanvas; cdecl; overload;
    procedure setLayerPaint(paint: JPaint); cdecl;
    procedure setLayerType(layerType: Integer; paint: JPaint); cdecl;
    procedure setOpaque(opaque: Boolean); cdecl;
    procedure setSurfaceTexture(surfaceTexture: JSurfaceTexture); cdecl;
    procedure setSurfaceTextureListener(listener: JTextureView_SurfaceTextureListener); cdecl;
    procedure setTransform(transform: JMatrix); cdecl;
    procedure unlockCanvasAndPost(canvas: JCanvas); cdecl;
  end;
  TJTextureView = class(TJavaGenericImport<JTextureViewClass, JTextureView>) end;

  JTextureView_SurfaceTextureListenerClass = interface(IJavaClass)
    ['{079709DF-C144-4083-888E-2318271F676F}']
  end;

  [JavaSignature('android/view/TextureView$SurfaceTextureListener')]
  JTextureView_SurfaceTextureListener = interface(IJavaInstance)
    ['{1E496A42-F10C-4473-BDE1-43960E671F09}']
    procedure onSurfaceTextureAvailable(surface: JSurfaceTexture; width: Integer; height: Integer); cdecl;
    function onSurfaceTextureDestroyed(surface: JSurfaceTexture): Boolean; cdecl;
    procedure onSurfaceTextureUpdated(surface: JSurfaceTexture); cdecl;
    procedure onSurfaceTextureSizeChanged(surface: JSurfaceTexture; width: Integer; height: Integer); cdecl;
  end;
  TJTextureView_SurfaceTextureListener = class(TJavaGenericImport<JTextureView_SurfaceTextureListenerClass, JTextureView_SurfaceTextureListener>) end;

implementation

end.

