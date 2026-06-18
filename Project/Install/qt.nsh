!ifndef FILE_QT_NSH_INCLUDED
!define FILE_QT_NSH_INCLUDED

; Installation macro
!macro InstallQtFiles
File "${SOURCE_DIR}\d3dcompiler_47.dll"
File "${SOURCE_DIR}\opengl32sw.dll"
File "${SOURCE_DIR}\Qt6Core.dll"
File "${SOURCE_DIR}\Qt6Gui.dll"
File "${SOURCE_DIR}\Qt6Network.dll"
File "${SOURCE_DIR}\Qt6Svg.dll"
File "${SOURCE_DIR}\Qt6Widgets.dll"
SetOutPath "$INSTDIR\generic"
File "${SOURCE_DIR}\generic\qtuiotouchplugin.dll"
SetOutPath "$INSTDIR\iconengines"
File "${SOURCE_DIR}\iconengines\qsvgicon.dll"
SetOutPath "$INSTDIR\imageformats"
File "${SOURCE_DIR}\imageformats\qgif.dll"
File "${SOURCE_DIR}\imageformats\qico.dll"
File "${SOURCE_DIR}\imageformats\qjpeg.dll"
File "${SOURCE_DIR}\imageformats\qsvg.dll"
SetOutPath "$INSTDIR\networkinformation"
File "${SOURCE_DIR}\networkinformation\qnetworklistmanager.dll"
SetOutPath "$INSTDIR\platforms"
File "${SOURCE_DIR}\platforms\qwindows.dll"
SetOutPath "$INSTDIR\styles"
File "${SOURCE_DIR}\styles\qwindowsvistastyle.dll"
SetOutPath "$INSTDIR\tls"
File "${SOURCE_DIR}\tls\qcertonlybackend.dll"
File "${SOURCE_DIR}\tls\qopensslbackend.dll"
File "${SOURCE_DIR}\tls\qschannelbackend.dll"
!macroend

; Uninstallation macro
!macro UninstallQtFiles
  Delete "$INSTDIR\d3dcompiler_47.dll"
  Delete "$INSTDIR\opengl32sw.dll"
  Delete "$INSTDIR\Qt6Core.dll"
  Delete "$INSTDIR\Qt6Gui.dll"
  Delete "$INSTDIR\Qt6Network.dll"
  Delete "$INSTDIR\Qt6Svg.dll"
  Delete "$INSTDIR\Qt6Widgets.dll"
  Delete "$INSTDIR\generic\qtuiotouchplugin.dll"
  Delete "$INSTDIR\iconengines\qsvgicon.dll"
  Delete "$INSTDIR\imageformats\qgif.dll"
  Delete "$INSTDIR\imageformats\qico.dll"
  Delete "$INSTDIR\imageformats\qjpeg.dll"
  Delete "$INSTDIR\imageformats\qsvg.dll"
  Delete "$INSTDIR\networkinformation\qnetworklistmanager.dll"
  Delete "$INSTDIR\platforms\qwindows.dll"
  Delete "$INSTDIR\styles\qwindowsvistastyle.dll"
  Delete "$INSTDIR\tls\qcertonlybackend.dll"
  Delete "$INSTDIR\tls\qopensslbackend.dll"
  Delete "$INSTDIR\tls\qschannelbackend.dll"
  RMDir "$INSTDIR\generic"
  RMDir "$INSTDIR\iconengines"
  RMDir "$INSTDIR\imageformats"
  RMDir "$INSTDIR\networkinformation"
  RMDir "$INSTDIR\platforms"
  RMDir "$INSTDIR\styles"
  RMDir "$INSTDIR\tls"
!macroend

!endif ; FILE_QT_NSH_INCLUDED
