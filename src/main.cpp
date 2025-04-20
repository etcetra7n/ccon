#include <windows.h>
#include <shellapi.h>
#include <cstring>
#include <string>
#include <fstream>
#include <sstream>
#include "ErrorExit.h"

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
    int argc;
    LPWSTR* argvW = CommandLineToArgvW(GetCommandLineW(), &argc);

    if (argc < 2) {
        ErrorExit("Missing argument for a filename");
    }

    // Convert wide-char filename to multibyte (char*)
    char filename[MAX_PATH];
    WideCharToMultiByte(CP_ACP, 0, argvW[1], -1, filename, MAX_PATH, NULL, NULL);

    if (!OpenClipboard(0)) {
        ErrorExit("Can't open clipboard");
    }
    if (!EmptyClipboard()) {
        ErrorExit("Can't empty the clipboard");
    }
    std::ifstream file(filename, std::ios::in);
    std::stringstream buffer;
    if (!file.good()) {
        ErrorExit("Can't open file");
    }
    buffer << file.rdbuf();
    std::string content = buffer.str();
    file.close();
    
    const size_t sz = content.length() + 1;
    HGLOBAL h = GlobalAlloc(GMEM_MOVEABLE, sz);
    if (!h) {
        ErrorExit("Memory allocation failed");
    }
    memcpy(GlobalLock(h), content.c_str(), sz);
    GlobalUnlock(h);
    if (SetClipboardData(CF_TEXT, h) == NULL) {
        ErrorExit("Can't set clipboard");
    }
    if (!CloseClipboard()) {
        ErrorExit("Can't close clipboard");
    }
    LocalFree(argvW); // cleanup
    return 0;
}
