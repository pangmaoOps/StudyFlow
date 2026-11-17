export interface StudyTask {
  id: string;
  title: string;
  subject: string;
  due: string;
  plannedDate: string;
  description: string;
  priority: string;
  minutes: number;
  done: boolean;
}

export interface StudySession { id: string; taskId: string; subject: string; minutes: number; date: string; }
export interface StudySettings { displayName: string; dailyGoalMinutes: number; themeMode: string; }
