//#include <windows.h>
#include <winuser.h>
#include <winbase.h>
#include <cstring>
#include <string>
#include "ErrorExit.h"

int main(int argc, char **argv){
    if (argc < 2){
        ErrorExit("Missing argument for a filename");
    }
    if (!OpenClipboard(0)){
        ErrorExit("Can't open clipboard");
    }
    if (!EmptyClipboard()){
        ErrorExit("Can't empty the clipboard");
    }

    std::ifstream file(argv[1]);
    if (!file.good()){
        ErrorExit("Can't open file");
    }
    std::string content((std::istreambuf_iterator<char>(file)), (std::istreambuf_iterator<char>()));
    const size_t sz = content.length()+1;

    HGLOBAL h = GlobalAlloc(GMEM_MOVEABLE, sz);
    memcpy(GlobalLock(h), content.c_str(), sz);
    GlobalUnlock(h);

    if (SetClipboardData(CF_TEXT, h) == NULL){
        ErrorExit("Can't set clipboard");
    }
    if (!CloseClipboard()){
        ErrorExit("Can's close clipboard");
    }

    return 0;
}
