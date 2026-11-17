import { preferences } from '@kit.ArkData';
import { StudyTask } from '../models/StudyTask';

const KEY: string = 'study_tasks_v1';
const SEED: StudyTask[] = [
  { id: 'a1', title: '复习高等数学第三章', subject: '数学', due: '09:30', minutes: 45, done: false },
  { id: 'a2', title: '完成英语阅读练习', subject: '英语', due: '14:00', minutes: 30, done: false },
  { id: 'a3', title: '整理数据结构课堂笔记', subject: '专业课', due: '16:30', minutes: 40, done: true }
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
}
