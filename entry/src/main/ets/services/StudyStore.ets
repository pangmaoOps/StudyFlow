import { preferences } from '@kit.ArkData';
import { StudyTask, StudySession, StudySettings } from '../models/StudyTask';

const KEY: string = 'study_tasks_v1';
const SESSION_KEY: string = 'study_sessions_v1';
const SETTINGS_KEY: string = 'study_settings_v1';
const DEFAULT_SETTINGS: StudySettings = { displayName: '智炜', dailyGoalMinutes: 120, themeMode: 'light' };
const SEED_SESSIONS: StudySession[] = [];
function todayKey(): string {
  const now = new Date();
  return now.getFullYear() + '-' + (now.getMonth() + 1).toString().padStart(2, '0') + '-' + now.getDate().toString().padStart(2, '0');
}
const SEED: StudyTask[] = [
  { id: 'a1', title: '复习高等数学第三章', description: '整理定积分与微分方程重点', subject: '数学', due: '09:30', plannedDate: todayKey(), priority: '高', minutes: 45, done: false },
  { id: 'a2', title: '完成英语阅读练习', description: '', subject: '英语', due: '14:00', plannedDate: todayKey(), priority: '中', minutes: 30, done: false },
  { id: 'a3', title: '整理数据结构课堂笔记', description: '', subject: '专业课', due: '16:30', plannedDate: todayKey(), priority: '低', minutes: 40, done: true }
];

let pref: preferences.Preferences | undefined;
export class StudyStore {
  static async load(context: Context): Promise<StudyTask[]> {
    try {
      pref = await preferences.getPreferences(context, { name: 'studyflow' });
      const raw = await pref.get(KEY, '') as string;
      if (raw.length > 0) return JSON.parse(raw) as StudyTask[];
      await StudyStore.save(SEED);
    } catch (_) { return SEED; }
    return SEED;
  }
  static async save(tasks: StudyTask[]): Promise<void> {
    if (!pref) return;
    await pref.put(KEY, JSON.stringify(tasks));
    await pref.flush();
  }
  static async loadSessions(): Promise<StudySession[]> {
    try { const raw = await pref?.get(SESSION_KEY, '') as string; return raw.length > 0 ? JSON.parse(raw) as StudySession[] : SEED_SESSIONS; }
    catch (_) { return SEED_SESSIONS; }
  }
  static async saveSessions(items: StudySession[]): Promise<void> {
    try { if (pref) { await pref.put(SESSION_KEY, JSON.stringify(items)); await pref.flush(); } } catch (_) {}
  }
  static async loadSettings(): Promise<StudySettings> {
    try { const raw = await pref?.get(SETTINGS_KEY, '') as string; return raw.length > 0 ? JSON.parse(raw) as StudySettings : DEFAULT_SETTINGS; }
    catch (_) { return DEFAULT_SETTINGS; }
  }
  static async saveSettings(settings: StudySettings): Promise<void> {
    try { if (pref) { await pref.put(SETTINGS_KEY, JSON.stringify(settings)); await pref.flush(); } } catch (_) {}
  }
}
