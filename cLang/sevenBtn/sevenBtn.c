#include <windows.h>

LRESULT CALLBACK WndProc(HWND, UINT, WPARAM, LPARAM);

TCHAR WinName[] = TEXT("MyWin");

// 预定义按钮颜色和文本颜色
static HBRUSH hButtonBrushes[7];
static COLORREF buttonColors[] = {
        RGB(255, 0, 0),    // 红色
        RGB(0, 255, 0),    // 绿色
        RGB(0, 0, 255),    // 蓝色
        RGB(255, 255, 0),  // 黄色
        RGB(255, 0, 255),  // 品红
        RGB(0, 255, 255),  // 青色
        RGB(192, 192, 192) // 浅灰色
};

static COLORREF textColors[] = {
        RGB(255, 255, 255), // 白色
        RGB(0, 0, 0),       // 黑色
        RGB(255, 255, 255), // 白色
        RGB(0, 0, 0),       // 黑色
        RGB(255, 255, 255), // 白色
        RGB(0, 0, 0),       // 黑色
        RGB(0, 0, 0)        // 黑色
};

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow) {
    HWND hWnd;
    MSG msg;
    WNDCLASS wc = {0};

    wc.hInstance = hInstance;
    wc.lpszClassName = WinName;
    wc.lpfnWndProc = WndProc;
    wc.style = CS_HREDRAW | CS_VREDRAW;
    wc.hIcon = LoadIcon(NULL, IDI_APPLICATION);
    wc.hCursor = LoadCursor(NULL, IDC_ARROW);
    wc.lpszMenuName = NULL;
    wc.cbClsExtra = 0;
    wc.cbWndExtra = 0;
    wc.hbrBackground = (HBRUSH) (COLOR_WINDOW + 1);

    if (!RegisterClass(&wc)) return 0;

    int window_width = 190 + 2 * GetSystemMetrics(SM_CXFRAME);
    int window_height = 29 * 7 + GetSystemMetrics(SM_CYCAPTION) + 2 * GetSystemMetrics(SM_CYFRAME);

    // 修改窗口样式，去掉 WS_THICKFRAME 和 WS_MAXIMIZEBOX
    hWnd = CreateWindow(WinName,
                        TEXT("S"),
                        WS_OVERLAPPEDWINDOW & ~WS_THICKFRAME & ~WS_MAXIMIZEBOX,
                        (GetSystemMetrics(SM_CXFULLSCREEN) - window_width) / 2,
                        (GetSystemMetrics(SM_CYFULLSCREEN) - window_height) / 2,
                        window_width,
                        window_height,
                        HWND_DESKTOP,
                        NULL,
                        hInstance,
                        NULL);

    ShowWindow(hWnd, nCmdShow);
    UpdateWindow(hWnd);

    while (GetMessage(&msg, NULL, 0, 0)) {
        TranslateMessage(&msg);
        DispatchMessage(&msg);
    }
    return (int) msg.wParam;
}

LRESULT CALLBACK WndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam) {
    switch (message) {
        case WM_CREATE: {
            // 创建颜色画刷
            for (int i = 0; i < 7; i++) {
                hButtonBrushes[i] = CreateSolidBrush(buttonColors[i]);
            }

            // 创建自绘按钮
            const TCHAR *buttonLabels[] = {
                    TEXT("Button 1"), TEXT("Button 2"), TEXT("Button 3"),
                    TEXT("Button 4"), TEXT("Button 5"), TEXT("Button 6"),
                    TEXT("Button 7")
            };

            for (int i = 0; i < 7; i++) {
                CreateWindow(TEXT("BUTTON"), buttonLabels[i],
                             WS_VISIBLE | WS_CHILD | BS_OWNERDRAW,
                             0, i * 30, 200, 30,
                             hWnd,
                             (HMENU) i,
                             ((LPCREATESTRUCT) lParam)->hInstance,
                             NULL);
            }
            break;
        }

        case WM_DRAWITEM: {
            LPDRAWITEMSTRUCT pDis = (LPDRAWITEMSTRUCT) lParam;
            if (pDis->CtlType == ODT_BUTTON) {
                int btnId = pDis->CtlID;
                if (btnId >= 0 && btnId < 7) {
                    // 填充背景
                    FillRect(pDis->hDC, &pDis->rcItem, hButtonBrushes[btnId]);

                    // 设置文本颜色
                    SetTextColor(pDis->hDC, textColors[btnId]);
                    SetBkMode(pDis->hDC, TRANSPARENT);

                    // 绘制按钮文本
                    TCHAR btnText[256];
                    GetWindowText(pDis->hwndItem, btnText, 256);
                    DrawText(pDis->hDC, btnText, -1, &pDis->rcItem,
                             DT_CENTER | DT_VCENTER | DT_SINGLELINE);

                    // 绘制按钮边框
                    if (pDis->itemState & ODS_SELECTED) {
                        DrawEdge(pDis->hDC, &pDis->rcItem, EDGE_SUNKEN, BF_RECT);
                    } else {
                        DrawEdge(pDis->hDC, &pDis->rcItem, EDGE_RAISED, BF_RECT);
                    }
                }
                return TRUE;
            }
            break;
        }

        case WM_COMMAND: {
            if (HIWORD(wParam) == BN_CLICKED) {
                int btnId = LOWORD(wParam);
                TCHAR msgText[256];
                wsprintf(msgText, TEXT("Button %d clicked"), btnId + 1);
                MessageBox(hWnd, msgText, TEXT("Notification"), MB_OK);
            }
            break;
        }

        case WM_DESTROY: {
            // 清理画刷资源
            for (int i = 0; i < 7; i++) {
                DeleteObject(hButtonBrushes[i]);
            }
            PostQuitMessage(0);
            break;
        }

        default:
            return DefWindowProc(hWnd, message, wParam, lParam);
    }
    return 0;
}