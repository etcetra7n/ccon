;======================================================
; Include

!include MUI2.nsh
!include "Sections.nsh"

;======================================================
; Macro definitions
!ifndef VERSION
  !define VERSION "1.1.0"
!endif
!ifndef ARCH
  !define ARCH "x86"
!endif
!ifndef CCON_EXE_PATH
  !define CCON_EXE_PATH "..\_build\Release\ccon.exe"
!endif
!ifndef CPY_ICON_ICO_PATH
  !define CPY_ICO_PATH "cpy.ico"
!endif
!ifndef LICENSE_PATH
  !define LICENSE_PATH "..\LICENSE"
!endif

;======================================================
; Installer Information

Name "CCON v${VERSION}"
OutFile "ccon-v${VERSION}-win-${ARCH}-setup.exe"
!if ${ARCH} == "x86"
  InstallDir $PROGRAMFILES\ccon
!else if ${ARCH} == "x64"
  InstallDir $PROGRAMFILES64\ccon
!endif

;======================================================
; Interface Configuration

!define MUI_HEADERIMAGE
!define MUI_ABORTWARNING
!define MUI_COMPONENTSPAGE_SMALLDESC
!define MUI_HEADERIMAGE_BITMAP_NOSTRETCH
!define MUI_FINISHPAGE
BrandingText "CCON ${VERSION}"

;======================================================
; Installer pages

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE ${LICENSE_PATH}
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

;======================================================
; Uninstaller pages

!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_COMPONENTS
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

;======================================================
; Languages

!insertmacro MUI_LANGUAGE "English"

;======================================================
; Installer Section

Section "Basic installation" SEC_BASIC_INSTALLATION
  ; Write ccon.exe to $INSTDIR
  SetOutPath $INSTDIR
  File ${CCON_EXE_PATH}
  File ${CPY_ICO_PATH}

  ; Register application
  WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\ccon.exe" "" "$INSTDIR\ccon.exe"
  WriteRegStr HKCR Applications\ccon.exe\DefaultIcon "" "$INSTDIR\cpy.ico"
  WriteRegStr HKCR Applications\ccon.exe\shell\open\command "" "$\"$INSTDIR\ccon.exe$\" $\"%1$\""

  ; Write uninstaller
  WriteUninstaller $INSTDIR\uninst-ccon.exe
SectionEnd

Section "Add to PATH" SEC_ADD_TO_PATH
  EnVar::SetHKCU
  EnVar::AddValue "PATH" "$INSTDIR"
SectionEnd

Section "Configure .cpy file typy" SEC_CONFIG_CPY_FILE
  WriteRegStr HKCR .cpy "" "CCON.ClipboardStateFile.1"
  WriteRegStr HKCR .cpy "Content Type" "text/plain"
  WriteRegStr HKCR .cpy "PerceivedType" "text"
  WriteRegStr HKCR CCON.ClipboardStateFile.1 "" "Clipboard State File"
  WriteRegStr HKCR CCON.ClipboardStateFile.1\DefaultIcon "" "$INSTDIR\cpy.ico"
  WriteRegStr HKCR CCON.ClipboardStateFile.1\shell\open\command "" "$\"$INSTDIR\ccon.exe$\" $\"%1$\""
  WriteRegStr HKCR CCON.ClipboardStateFile.1\shell\edit\command "" "$\"%SystemRoot%\system32\NOTEPAD.EXE $\"%1$\""
  WriteRegStr HKCU Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.cpy\UserChoice "Progid" "CCON.ClipboardStateFile.1"
SectionEnd

Section "Enable right click context menu" SEC_ENABLE_CONTEXT_MENU
  WriteRegStr HKCR *\Shell\ccon "" "Copy content"
  WriteRegStr HKCR *\Shell\ccon "Extended" ""
  WriteRegStr HKCR *\Shell\ccon\command "" "$\"$INSTDIR\ccon.exe$\" $\"%1$\""
SectionEnd

;======================================================
; Uninstaller Section

Section "un.Basic uninstallation" UNSEC_BASIC_UNINSTALLATION
  ; Remove executables
  Delete $INSTDIR\ccon.exe
  Delete $INSTDIR\uninst-ccon.exe
  Delete $INSTDIR\cpy.ico
  RMDir $INSTDIR

  ; Unregister application
  DeleteRegKey HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\ccon.exe"
  DeleteRegKey HKCR Applications\ccon.exe
SectionEnd

Section "un.Remove from PATH" UNSEC_REMOVE_FROM_PATH
  EnVar::SetHKCU
  EnVar::DeleteValue "PATH" "$INSTDIR"
SectionEnd

Section "un.Unconfigure .cpy file type" UNSEC_UNCONFIG_CPY_FILE
  DeleteRegKey HKCR CCON.ClipboardStateFile.1
  DeleteRegKey HKCU Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.cpy
SectionEnd

Section "un.Disable right click context menu" UNSEC_DISABLE_CONTEXT_MENU
  DeleteRegKey HKCR *\Shell\ccon
SectionEnd

;======================================================
; Component Description

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_BASIC_INSTALLATION} "Places ccon.exe in the installation directory"
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_ADD_TO_PATH} "Lets you to use the ccon command in the command line"
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_CONFIG_CPY_FILE} "Lets you use .cpy files on your system"
  !insertmacro MUI_DESCRIPTION_TEXT ${SEC_ENABLE_CONTEXT_MENU} "Adds a $\"Copy content$\" option to the right click context menu of every file types"
!insertmacro MUI_FUNCTION_DESCRIPTION_END

!insertmacro MUI_UNFUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${UNSEC_BASIC_UNINSTALLATION} "Removes ccon.exe from the installation directory"
  !insertmacro MUI_DESCRIPTION_TEXT ${UNSEC_REMOVE_FROM_PATH} "You will no longer be able to use the ccon command in the command line"
  !insertmacro MUI_DESCRIPTION_TEXT ${UNSEC_UNCONFIG_CPY_FILE} "Removes .cpy file configuration from your system"
  !insertmacro MUI_DESCRIPTION_TEXT ${UNSEC_DISABLE_CONTEXT_MENU} "Removes the $\"Copy content$\" option from the right click context menu"
!insertmacro MUI_UNFUNCTION_DESCRIPTION_END

;======================================================
; Callback Functions

Function .onInstSuccess
  SendMessage ${HWND_BROADCAST} ${WM_SETTINGCHANGE} 0x002A 0 /TIMEOUT=5000
FunctionEnd

Function un.onUninstSuccess
  SendMessage ${HWND_BROADCAST} ${WM_SETTINGCHANGE} 0x002A 0 /TIMEOUT=5000
FunctionEnd

;======================================================
