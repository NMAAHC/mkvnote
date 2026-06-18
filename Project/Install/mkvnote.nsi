#NSIS: encoding=UTF-8
; Request application privileges for Windows Vista
RequestExecutionLevel admin

; Enable high-DPI support
ManifestDPIAware true

; Some defines
!define PRODUCT_NAME "mkvnote"
!define PRODUCT_PUBLISHER "MediaArea.net"
!define PRODUCT_VERSION "1.0.0"
!define PRODUCT_VERSION4 "${PRODUCT_VERSION}.0"
!define PRODUCT_WEB_SITE "https://github.com/NMAAHC/mkvnote"
!define COMPANY_REGISTRY "Software\MediaArea.net"
!define PRODUCT_REGISTRY "Software\MediaArea.net\mkvnote"
!define PRODUCT_DIR_REGKEY "Software\Microsoft\Windows\CurrentVersion\App Paths\mkvnote-gui.exe"
!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"

!define SOURCE_DIR "..\..\Release\mkvnote_ROOT\bin"

; Compression
SetCompressor /FINAL /SOLID lzma

; Conditional
!include LogicLib.nsh

; x64 stuff
!include "x64.nsh"

; Qt runtime
!include "qt.nsh"

; File size
!include FileFunc.nsh
!include WinVer.nsh

; Modern UI
!include "MUI2.nsh"
!define MUI_ABORTWARNING
; !define MUI_ICON "..\..\icons\mkvnote.ico"

; Uninstaller signing
!ifdef EXPORT_UNINST
  !uninstfinalize 'copy /Y "%1" "../../Release/${PRODUCT_NAME}_GUI_${PRODUCT_VERSION}_Windows_x64-uninst.exe"'
!endif

; Language Selection Dialog Settings
!define MUI_LANGDLL_REGISTRY_ROOT "${PRODUCT_UNINST_ROOT_KEY}"
!define MUI_LANGDLL_REGISTRY_KEY "${PRODUCT_UNINST_KEY}"
!define MUI_LANGDLL_REGISTRY_VALUENAME "NSIS:Language"

; Function to launch program with same integrity level as Windows Explorer
Function LaunchAsCurrentUser
  Exec '"$WINDIR\explorer.exe" "$INSTDIR\mkvnote-gui.exe"'
FunctionEnd

; Installer pages
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_FUNCTION "LaunchAsCurrentUser"
!insertmacro MUI_PAGE_FINISH
; Uninstaller pages
!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

; Language files
!insertmacro MUI_LANGUAGE "English"

; Info
VIProductVersion "${PRODUCT_VERSION4}"
VIAddVersionKey "CompanyName"      "${PRODUCT_PUBLISHER}"
VIAddVersionKey "ProductName"      "${PRODUCT_NAME}"
VIAddVersionKey "ProductVersion"   "${PRODUCT_VERSION4}"
VIAddVersionKey "FileDescription"  "mkvnote"
VIAddVersionKey "FileVersion"      "${PRODUCT_VERSION4}"
VIAddVersionKey "LegalCopyright"   "${PRODUCT_PUBLISHER}"
VIAddVersionKey "OriginalFilename" "${PRODUCT_NAME}_GUI_${PRODUCT_VERSION}_Windows_x64.exe"
BrandingText " "

; Modern UI end

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "..\..\Release\${PRODUCT_NAME}_GUI_${PRODUCT_VERSION}_Windows_x64.exe"
InstallDir "$PROGRAMFILES64\${PRODUCT_NAME}"
InstallDirRegKey HKLM "${PRODUCT_DIR_REGKEY}" ""
ShowInstDetails nevershow
ShowUnInstDetails nevershow

Function .onInit
  ${If} ${RunningX64}
    SetRegView 64
  ${EndIf}
FunctionEnd

Section "SectionPrincipale" SEC01
  SetOverwrite on
  SetOutPath "$SMPROGRAMS"
  CreateShortCut "$SMPROGRAMS\mkvnote.lnk" "$INSTDIR\mkvnote-gui.exe" "" "$INSTDIR\mkvnote-gui.exe" 0 "" "" "mkvnote"
  SetOutPath "$INSTDIR"
  File "${SOURCE_DIR}\mkvnote-gui.exe"
  File "${SOURCE_DIR}\mediainfo.exe"
  File "${SOURCE_DIR}\mkvextract.exe"
  File "${SOURCE_DIR}\mkvinfo.exe"
  File "${SOURCE_DIR}\mkvmerge.exe"
  File "${SOURCE_DIR}\mkvpropedit.exe"

  !insertmacro InstallQtFiles

  # Create files
  WriteIniStr "$INSTDIR\${PRODUCT_NAME}.url" "InternetShortcut" "URL" "${PRODUCT_WEB_SITE}"
SectionEnd

Section -Post
  !if /FileExists "..\..\Release\${PRODUCT_NAME}_GUI_${PRODUCT_VERSION}_Windows_x64-uninst.exe"
    File "/oname=$INSTDIR\uninst.exe" "..\..\Release\${PRODUCT_NAME}_GUI_${PRODUCT_VERSION}_Windows_x64-uninst.exe"
  !else
    WriteUninstaller "$INSTDIR\uninst.exe"
  !endif
  WriteRegStr HKLM "${PRODUCT_DIR_REGKEY}" "" "$INSTDIR\mkvnote-gui.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName"     "$(^Name)"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher"       "${PRODUCT_PUBLISHER}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayIcon"     "$INSTDIR\mkvnote-gui.exe"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion"  "${PRODUCT_VERSION}"
  WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout"    "${PRODUCT_WEB_SITE}"

  ${If} ${AtLeastWin7}
    ${GetSize} "$INSTDIR" "/S=0K" $0 $1 $2
    IntFmt $0 "0x%08X" $0 ; Convert the decimal KB value in $0 to DWORD, put it right back into $0
    WriteRegDWORD ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "EstimatedSize" "$0" ; Create/Write the reg key with the dword value
  ${EndIf}
SectionEnd


Section Uninstall
  SetRegView 64

  Delete "$INSTDIR\${PRODUCT_NAME}.url"
  Delete "$INSTDIR\uninst.exe"
  Delete "$INSTDIR\mkvnote-gui.exe"
  Delete "$INSTDIR\mediainfo.exe"
  Delete "$INSTDIR\mkvextract.exe"
  Delete "$INSTDIR\mkvinfo.exe"
  Delete "$INSTDIR\mkvmerge.exe"
  Delete "$INSTDIR\mkvpropedit.exe"

  !insertmacro UninstallQtFiles

  RMDir "$INSTDIR"
  Delete "$SMPROGRAMS\mkvnote.lnk"

  SetRegView 64
  DeleteRegKey HKLM "${PRODUCT_REGISTRY}"
  DeleteRegKey /ifempty HKLM "${COMPANY_REGISTRY}"
  DeleteRegKey HKCU "${PRODUCT_REGISTRY}"
  DeleteRegKey /ifempty HKCU "${COMPANY_REGISTRY}"
  DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"
  DeleteRegKey HKLM "${PRODUCT_DIR_REGKEY}"
  SetAutoClose true
SectionEnd
