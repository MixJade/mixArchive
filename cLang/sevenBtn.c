#include <windows.h>
LRESULT CALLBACK WndProc(HWND, UINT, WPARAM, LPARAM);
TCHAR WinName[]="MyWin"; 

int WINAPI WinMain(HINSTANCE This,HINSTANCE Prev,LPSTR cmd,int mode)
{
   HWND hWnd;
   MSG msg;
   WNDCLASS wc;

   wc.hInstance = This;
   wc.lpszClassName = WinName; 
   wc.lpfnWndProc = WndProc; 
   wc.style = CS_HREDRAW | CS_VREDRAW; 
   wc.hIcon = LoadIcon(NULL, IDI_APPLICATION);
   wc.hCursor = LoadCursor(NULL,IDC_ARROW);
   wc.lpszMenuName = NULL; 
   wc.cbClsExtra = 0; 
   wc.cbWndExtra = 0;

   wc.hbrBackground = (HBRUSH)(COLOR_WINDOW); 

   if(!RegisterClass(&wc)) return 0;
   int window_width = 200 + 2 * GetSystemMetrics(SM_CXFRAME);
   int window_height = 30 * 7 + GetSystemMetrics(SM_CYCAPTION) + 2 * GetSystemMetrics(SM_CYFRAME);
   hWnd=CreateWindow(WinName,
                     "S",
                     WS_OVERLAPPEDWINDOW, 
                     (GetSystemMetrics(SM_CXFULLSCREEN) - window_width) / 2,
                     (GetSystemMetrics(SM_CYFULLSCREEN) - window_height) / 2,
                     window_width,
                     window_height, 
                     HWND_DESKTOP, 
                     NULL,
                     This,
                     NULL);

   ShowWindow(hWnd, mode);

   while(GetMessage(&msg, NULL, 0, 0))
   {
      TranslateMessage(&msg);
      DispatchMessage(&msg);
   }
   return 0;
}

LRESULT CALLBACK WndProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
  switch (message)
  {
      case WM_CREATE:
        for (int i = 0; i < 7; i++) 
          CreateWindow("button", "Button",
                       WS_VISIBLE | WS_CHILD | BS_PUSHBUTTON, 
                       0, i * 30, 200, 30,
                       hWnd,
                       (HMENU) i,
                       NULL, NULL);
        break;
      case WM_COMMAND:
        if (HIWORD(wParam)==BN_CLICKED)
        {
        	switch (LOWORD(wParam))
            {
            case 0:
                MessageBox(NULL, "Button 1 clicked", "Notification", MB_OK);
                break;
            case 1:
                MessageBox(NULL, "Button 2 clicked", "Notification", MB_OK);
                break;
            default:
            	MessageBox(NULL, "xx", "Button", MB_ICONINFORMATION | MB_OK);
                break;
            }
        }
        break;
      case WM_DESTROY:
        PostQuitMessage(0);
        break;   
      default:
        return DefWindowProc(hWnd, message, wParam, lParam);
   }
   return 0;
}
