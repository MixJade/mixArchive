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

#include <time.h>

// 打印当前时间的函数
void print_current_time() {
    printf("当前时间: ");
    // 获取当前时间的秒数（从1970年1月1日00:00:00开始计算）
    time_t current_time;
    time(&current_time);
    // 转换为本地时间
    struct tm *local_time = localtime(&current_time);
    if (local_time == NULL) {
        printf("获取本地时间失败\n");
        return;
    }
    // 格式化并打印时间（注意年份需要加上1900，月份从0开始需要加1）
    printf("%d-%02d-%02d %02d:%02d:%02d\n\n",
           local_time->tm_year + 1900,  // 年份
           local_time->tm_mon + 1,      // 月份（0-11）
           local_time->tm_mday,         // 日期
           local_time->tm_hour,         // 小时
           local_time->tm_min,          // 分钟
           local_time->tm_sec);         // 秒
}

int main() {
    print_current_time();
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