#include <windows.h>
#include <stdio.h>

// 全局标志用于跟踪状态设置
static BOOL g_stateSet = FALSE;

BOOL WINAPI ConsoleHandler(DWORD dwCtrlType) {
    switch (dwCtrlType) {
        case CTRL_C_EVENT:
        case CTRL_CLOSE_EVENT:    // 控制台窗口关闭
        case CTRL_LOGOFF_EVENT:   // 用户注销
        case CTRL_SHUTDOWN_EVENT: // 系统关机
            if (g_stateSet) {
                // 正确恢复系统默认设置：清除所有执行状态请求
                SetThreadExecutionState(ES_CONTINUOUS);
                g_stateSet = FALSE;
                printf("\n程序已终止，系统恢复默认电源管理设置\n");
            }
            return TRUE;
        default:
            return FALSE;
    }
}

int main() {
    // 注册控制台事件处理
    if (!SetConsoleCtrlHandler(ConsoleHandler, TRUE)) {
        printf("无法设置控制台处理函数 - 错误代码: %lu\n", GetLastError());
        return 1;
    }

    // 设置电源管理状态
    if (SetThreadExecutionState(ES_CONTINUOUS | ES_DISPLAY_REQUIRED | ES_SYSTEM_REQUIRED)) {
        g_stateSet = TRUE;
        printf("程序运行中，Windows不会自动息屏...\n");
        printf("按 Ctrl+C 或关闭窗口终止程序\n");
    } else {
        printf("无法设置电源状态 - 错误代码: %lu\n", GetLastError());
        SetConsoleCtrlHandler(ConsoleHandler, FALSE);
        return 1;
    }

    Sleep(INFINITE);  // 永久等待，减少CPU占用
}