;======================================================
; Include

  !include MUI.nsh

;======================================================
; Macro definitions
  !ifndef VERSION
    !define VERSION "1.0.0"
  !endif
  !ifndef ARCH
    !define ARCH "x86"
  !endif
  !ifndef CCON_EXE_PATH
    !define CCON_EXE_PATH "..\_build\ccon.exe"
  !endif
  !ifndef CPY_ICON_ICO_PATH
    !define CPY_ICON_ICO_PATH "cpy_icon.ico"
  !endif
  !ifndef LICENSE_PATH
    !define LICENSE_PATH "..\LICENSE"
  !endif

;======================================================
; Installer Information

  Name "ccon"
  OutFile "ccon-v${VERSION}-${ARCH}-setup.exe"
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
  !define MUI_FINISHPAGE_TEXT "Thank you for installing ccon"

;======================================================
; Installer pages

  !insertmacro MUI_PAGE_WELCOME
  !insertmacro MUI_PAGE_LICENSE ${LICENSE_PATH}
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES
  !insertmacro MUI_PAGE_FINISH

;======================================================
; Uninstaller pages

  !insertmacro MUI_UNPAGE_WELCOME
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_DIRECTORY
  !insertmacro MUI_UNPAGE_INSTFILES
  !insertmacro MUI_UNPAGE_FINISH

;======================================================
; Languages

  !insertmacro MUI_LANGUAGE "English"

;======================================================
; Installer Section

  Section "Installer"

    ; Write ccon.exe to $INSTDIR
    SetOutPath $INSTDIR
    File ${CCON_EXE_PATH}
    File ${CPY_ICON_ICO_PATH}

    ; Add $INSTDIR to the PATH user environment variable
    EnVar::SetHKCU
    EnVar::AddValue "PATH" "$INSTDIR"
    
    ; Register applications
    WriteRegStr HKEY_LOCAL_MACHINE "SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\ccon.exe" "" "$INSTDIR\ccon.exe"
    WriteRegStr HKEY_CLASSES_ROOT Applications\ccon.exe\DefaultIcon "" "$\"$INSTDIR\cpy_icon.ico$\""
    WriteRegStr HKEY_CLASSES_ROOT Applications\ccon.exe\shell\open\command "" "$\"$INSTDIR\ccon.exe$\" $\"%1$\""
    WriteRegStr HKEY_CLASSES_ROOT Applications\ccon.exe\SupportedTypes ".cpy" ""
    
    ; Configure .cpy file
    WriteRegStr HKEY_CLASSES_ROOT .cpy "" "ccon.ClipboardStateFile"
    WriteRegStr HKEY_CLASSES_ROOT .cpy "Content Type" "application/ccon"
    WriteRegStr HKEY_CLASSES_ROOT .cpy "PerceivedType" "text"
    WriteRegStr HKEY_CLASSES_ROOT ccon.ClipboardStateFile "" "Clipboard State File"
    WriteRegStr HKEY_CLASSES_ROOT ccon.ClipboardStateFile\DefaultIcon "" "$INSTDIR\cpy_icon.ico"
    WriteRegStr HKEY_CLASSES_ROOT ccon.ClipboardStateFile\shell\open\command "" "$\"$INSTDIR\ccon.exe$\" $\"%1$\""
    WriteRegStr HKEY_CLASSES_ROOT ccon.ClipboardStateFile\shell\edit\command "" "$\"%SystemRoot%\system32\notepad.exe $\"%1$\""
  
    ; Configure right click context menu
    WriteRegStr HKEY_CLASSES_ROOT *\Shell\ccon "" "Copy content"
    WriteRegStr HKEY_CLASSES_ROOT *\Shell\ccon "Extended" ""
    WriteRegStr HKEY_CLASSES_ROOT *\Shell\ccon\command "" "$\"$INSTDIR\ccon.exe$\" $\"%1$\""
    
    ; Write uninstaller
    WriteUninstaller $INSTDIR\uninst-ccon.exe

  SectionEnd

;======================================================
; Uninstaller Section

  Section "un.Uninstaller"
    
    ; Remove executables
    Delete $INSTDIR\ccon.exe
    Delete $INSTDIR\uninst-ccon.exe
    Delete $INSTDIR\cpy_icon.ico
    RMDir $INSTDIR
    
    ; Remove $INSTDIR from PATH user environment variable
    EnVar::SetHKCU
    EnVar::DeleteValue "PATH" "$INSTDIR"
    
    ; Deconfigure right click context menu
    DeleteRegKey HKEY_CLASSES_ROOT *\Shell\ccon
    
    ; Deconfigure .cpy file
    DeleteRegKey HKEY_CLASSES_ROOT .cpy
    DeleteRegKey HKEY_CLASSES_ROOT ccon.ClipboardStateFile
    DeleteRegKey HKEY_CLASSES_ROOT Applications\ccon.exe
    DeleteRegKey HKEY_LOCAL_MACHINE "SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\ccon.exe"
    
  SectionEnd

;======================================================
