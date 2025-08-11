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

#include <time.h>

// ��ӡ��ǰʱ��ĺ���
void print_current_time() {
    printf("��ǰʱ��: ");
    // ��ȡ��ǰʱ�����������1970��1��1��00:00:00��ʼ���㣩
    time_t current_time;
    time(&current_time);
    // ת��Ϊ����ʱ��
    struct tm *local_time = localtime(&current_time);
    if (local_time == NULL) {
        printf("��ȡ����ʱ��ʧ��\n");
        return;
    }
    // ��ʽ������ӡʱ�䣨ע�������Ҫ����1900���·ݴ�0��ʼ��Ҫ��1��
    printf("%d-%02d-%02d %02d:%02d:%02d\n\n",
           local_time->tm_year + 1900,  // ���
           local_time->tm_mon + 1,      // �·ݣ�0-11��
           local_time->tm_mday,         // ����
           local_time->tm_hour,         // Сʱ
           local_time->tm_min,          // ����
           local_time->tm_sec);         // ��
}

int main() {
    print_current_time();
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