#include <windows.h>
#include <stdio.h>

// ȫ�ֱ�־���ڸ���״̬����
static BOOL g_stateSet = FALSE;

BOOL WINAPI ConsoleHandler(DWORD dwCtrlType) {
    switch (dwCtrlType) {
        case CTRL_C_EVENT:
        case CTRL_CLOSE_EVENT:    // ����̨���ڹر�
        case CTRL_LOGOFF_EVENT:   // �û�ע��
        case CTRL_SHUTDOWN_EVENT: // ϵͳ�ػ�
            if (g_stateSet) {
                // ��ȷ�ָ�ϵͳĬ�����ã��������ִ��״̬����
                SetThreadExecutionState(ES_CONTINUOUS);
                g_stateSet = FALSE;
                printf("\n��������ֹ��ϵͳ�ָ�Ĭ�ϵ�Դ��������\n");
            }
            return TRUE;
        default:
            return FALSE;
    }
}

int main() {
    // ע�����̨�¼�����
    if (!SetConsoleCtrlHandler(ConsoleHandler, TRUE)) {
        printf("�޷����ÿ���̨������ - �������: %lu\n", GetLastError());
        return 1;
    }

    // ���õ�Դ����״̬
    if (SetThreadExecutionState(ES_CONTINUOUS | ES_DISPLAY_REQUIRED | ES_SYSTEM_REQUIRED)) {
        g_stateSet = TRUE;
        printf("���������У�Windows�����Զ�Ϣ��...\n");
        printf("�� Ctrl+C ��رմ�����ֹ����\n");
    } else {
        printf("�޷����õ�Դ״̬ - �������: %lu\n", GetLastError());
        SetConsoleCtrlHandler(ConsoleHandler, FALSE);
        return 1;
    }

    Sleep(INFINITE);  // ���õȴ�������CPUռ��
}