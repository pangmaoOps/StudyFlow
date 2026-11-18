import { StudyTask, StudySession, StudySettings } from '../models/StudyTask';
import { StudyStore } from '../services/StudyStore';
import { getResources, StudyResource } from '../services/ResourceService';
import { TaskCard } from '../components/TaskCard';
import { EmptyState } from '../components/EmptyState';
import { ProgressCard } from '../components/ProgressCard';

@Entry
@Component
struct Index {
  @State private tab: number = 0;
  @State private tasks: StudyTask[] = [];
  @State private filter: number = 0;
  @State private resourceState: string = 'idle';
  @State private resources: StudyResource[] = [];
  @State private detailId: string = '';
  @State private sessions: StudySession[] = [];
  @State private settings: StudySettings = { displayName: '智炜', dailyGoalMinutes: 120, themeMode: 'light' };
  @State private calendarDate: Date = new Date();
  @State private selectedDay: number = new Date().getDate();
  @State private recordMinutes: string = '25';
  @State private formTitle: string = '';
  @State private formDescription: string = '';
  @State private formSubject: string = '专业课';
  @State private formPriority: string = '中';
  @State private formDate: string = new Date().toISOString().slice(0, 10);
  @State private formMinutes: string = '30';
  @State private editingId: string = '';
  @State private displayNameInput: string = '智炜';
  @State private goalInput: string = '120';
  @State private sessionInput: string = '25';
  private stack: NavPathStack = new NavPathStack();
  aboutToAppear() {
    this.loadLocalData();
  }
  private async loadLocalData(): Promise<void> {
    this.tasks = await StudyStore.load(getContext(this));
    this.sessions = await StudyStore.loadSessions();
    this.settings = await StudyStore.loadSettings();
  }
  private dateKey(day: number): string { return this.calendarDate.getFullYear() + '-' + (this.calendarDate.getMonth() + 1).toString().padStart(2, '0') + '-' + day.toString().padStart(2, '0'); }
  private firstWeekdayOffset(): number { return (new Date(this.calendarDate.getFullYear(), this.calendarDate.getMonth(), 1).getDay() + 6) % 7; }
  private monthLength(): number { return new Date(this.calendarDate.getFullYear(), this.calendarDate.getMonth() + 1, 0).getDate(); }
  private shiftMonth(delta: number): void {
    this.calendarDate = new Date(this.calendarDate.getFullYear(), this.calendarDate.getMonth() + delta, 1);
    this.selectedDay = Math.min(this.selectedDay, this.monthLength());
  }
  private todayTasks(): StudyTask[] { const now = new Date(); const key = now.getFullYear() + '-' + (now.getMonth() + 1).toString().padStart(2, '0') + '-' + now.getDate().toString().padStart(2, '0'); return this.tasks.filter((t: StudyTask) => t.plannedDate === key); }
  private minutesOn(date: string): number { return this.sessions.filter((s: StudySession) => s.date === date).reduce((sum: number, s: StudySession) => sum + s.minutes, 0); }
  private recentDay(offset: number): Date { const d = new Date(); d.setDate(d.getDate() - (6 - offset)); return d; }
  private recentKey(offset: number): string { const d = this.recentDay(offset); return d.getFullYear() + '-' + (d.getMonth() + 1).toString().padStart(2, '0') + '-' + d.getDate().toString().padStart(2, '0'); }
  private visibleTasks(): StudyTask[] {
    if (this.filter === 1) return this.tasks.filter((t: StudyTask) => !t.done);
    if (this.filter === 2) return this.tasks.filter((t: StudyTask) => t.done);
    return this.tasks;
  }
  private persist(): void { StudyStore.save(this.tasks); }
  private toggle(id: string): void {
    this.tasks = this.tasks.map((t: StudyTask) => { const updated: StudyTask = { id: t.id, title: t.title, description: t.description, subject: t.subject, priority: t.priority, plannedDate: t.plannedDate, due: t.due, minutes: t.minutes, done: !t.done }; return t.id === id ? updated : t; });
    this.persist();
  }
  private openTask(id: string): void { this.detailId = id; this.stack.pushPath({ name: 'detail', param: id }); }
  private editTask(id: string): void {
    this.editingId = id;
    const task = this.tasks.find((item: StudyTask) => item.id === id);
    this.formTitle = task?.title ?? ''; this.formDescription = task?.description ?? '';
    this.formSubject = task?.subject ?? '专业课'; this.formPriority = task?.priority ?? '中';
    this.formDate = task?.plannedDate ?? new Date().toISOString().slice(0, 10); this.formMinutes = (task?.minutes ?? 30).toString();
    this.stack.pushPath({ name: 'edit', param: id });
  }
  private deleteTask(id: string): void {
    AlertDialog.show({ title: '删除任务？', message: '删除后无法恢复此任务。', primaryButton: { value: '删除', action: () => { this.tasks = this.tasks.filter((t: StudyTask) => t.id !== id); this.persist(); this.stack.pop(); if (this.stack.size() > 0) this.stack.pop(); } }, secondaryButton: { value: '取消', action: () => {} } });
  }
  private addTask(): void { this.editTask(''); }
  private saveTask(id: string, title: string, description: string, subject: string, priority: string, date: string, minutes: number): void {
    if (title.trim().length === 0) { this.getUIContext().getPromptAction().showToast({ message: '请填写任务标题' }); return; }
    if (!/^\d{4}-\d{2}-\d{2}$/.test(date) || !Number.isFinite(minutes) || minutes < 1 || minutes > 1440) { this.getUIContext().getPromptAction().showToast({ message: '请检查日期和预计分钟数' }); return; }
    if (id.length > 0) { this.tasks = this.tasks.map((t: StudyTask) => t.id === id ? { id: t.id, title: title.trim(), description, subject, priority, plannedDate: date, due: t.due, minutes, done: t.done } : t); }
    else { this.tasks = [{ id: Date.now().toString(), title: title.trim(), description, subject, priority, plannedDate: date, due: '18:00', minutes, done: false }, ...this.tasks]; }
    this.persist(); this.getUIContext().getPromptAction().showToast({ message: id.length > 0 ? '任务已更新' : '任务创建成功' }); this.stack.pop();
  }
  private recordStudy(): void {
    const mins = Number(this.sessionInput);
    if (!Number.isFinite(mins) || mins < 1 || mins > 1440) { this.getUIContext().getPromptAction().showToast({ message: '请输入 1 至 1440 的分钟数' }); return; }
    const now = new Date();
    const session: StudySession = { id: Date.now().toString(), taskId: '', subject: '自习', minutes: mins, date: now.getFullYear() + '-' + (now.getMonth() + 1).toString().padStart(2, '0') + '-' + now.getDate().toString().padStart(2, '0') };
    this.sessions = [session, ...this.sessions]; StudyStore.saveSessions(this.sessions); this.getUIContext().getPromptAction().showToast({ message: '学习时长已记录' });
  }
  private saveSettings(): void {
    const goal = Number(this.goalInput);
    if (this.displayNameInput.trim().length === 0 || !Number.isFinite(goal) || goal < 1 || goal > 1440) { this.getUIContext().getPromptAction().showToast({ message: '请检查名称和每日目标' }); return; }
    this.settings = { displayName: this.displayNameInput.trim(), dailyGoalMinutes: goal, themeMode: 'light' };
    StudyStore.saveSettings(this.settings); this.getUIContext().getPromptAction().showToast({ message: '设置已保存' });
  }
  private async refreshResources(): Promise<void> {
    this.resourceState = 'loading';
    try { this.resources = await getResources(); this.resourceState = this.resources.length > 0 ? 'success' : 'empty'; }
    catch (_) { this.resourceState = 'error'; }
  }
  @Builder
  private taskList() {
    List({ space: 10 }) {
      ForEach(this.visibleTasks(), (task: StudyTask) => {
        ListItem() { TaskCard({ task: task, onToggle: (id: string) => this.toggle(id), onOpen: (id: string) => this.openTask(id) }) }
      }, (task: StudyTask) => task.id);
    }.width('100%').layoutWeight(1);
  }
  @Builder
  private homePage() {
    Scroll() {
      Column({ space: 18 }) {
        Row() {
          Column({ space: 4 }) {
            Text(new Date().toLocaleDateString()).fontSize(11).fontColor('#858DA1').letterSpacing(1);
            Text('早上好，' + this.settings.displayName).fontSize(24).fontWeight(FontWeight.Bold).fontColor('#202A43');
          }.alignItems(HorizontalAlign.Start).layoutWeight(1);
          Text('SF').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#FFFFFF').width(42).height(42)
            .textAlign(TextAlign.Center).backgroundColor('#7567E8').borderRadius(15);
        }.width('100%');
        ProgressCard({ title: '今日完成任务', current: this.todayTasks().filter((t: StudyTask) => t.done).length, total: this.todayTasks().length });
        Row() { Text('今天的计划').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#252F49').layoutWeight(1); Button('+ 新任务').fontSize(12).fontColor('#6758D8').backgroundColor('#EEECFF').borderRadius(12).onClick(() => this.addTask()); }
        if (this.todayTasks().length === 0) { EmptyState({ title: '今天还没有学习任务', detail: '创建一个任务，开始高效的一天' }) }
        else { List({ space: 10 }) { ForEach(this.todayTasks(), (task: StudyTask) => ListItem() { TaskCard({ task: task, onToggle: (id: string) => this.toggle(id), onOpen: (id: string) => this.openTask(id) }); }); }.width('100%').layoutWeight(1); }
        Row({ space: 10 }) {
          this.statCard('本周完成', this.tasks.filter((t: StudyTask) => t.done).length.toString(), '项任务');
          this.statCard('已记录学习', this.sessions.reduce((n: number, s: StudySession) => n + s.minutes, 0).toString(), '分钟');
        }.width('100%');
        Row({ space: 8 }) {
          TextInput({ placeholder: '学习分钟', text: this.sessionInput }).type(InputType.Number).height(48).layoutWeight(1).backgroundColor('#FFFFFF').borderRadius(24).onChange((v: string) => this.sessionInput = v);
          Button('记录自习').fontSize(12).backgroundColor('#7162E8').onClick(() => this.recordStudy());
        }.width('100%');
      }.padding({ left: 20, right: 20, top: 22, bottom: 24 }).width('100%');
    }.scrollBar(BarState.Off);
  }
  @Builder
  private statCard(label: string, value: string, unit: string) {
    Column({ space: 7 }) { Text(label).fontSize(12).fontColor('#8991A3'); Row({ space: 4 }) { Text(value).fontSize(22).fontWeight(FontWeight.Bold).fontColor('#29334D'); Text(unit).fontSize(11).fontColor('#8991A3').margin({ top: 8 }); } }
      .alignItems(HorizontalAlign.Start).layoutWeight(1).padding(16).backgroundColor('#FFFFFF').borderRadius(16);
  }
  @Builder
  private tasksPage() {
    Column({ space: 14 }) {
      Row() { Text('学习任务').fontSize(24).fontWeight(FontWeight.Bold).fontColor('#202A43').layoutWeight(1); Button('+ 新建').backgroundColor('#7162E8').borderRadius(12).onClick(() => this.addTask()); }
      Row({ space: 8 }) {
        ForEach(['全部', '待完成', '已完成'], (name: string, i: number) => Button(name).fontSize(12).fontColor(this.filter === i ? '#FFFFFF' : '#687188')
          .backgroundColor(this.filter === i ? '#7162E8' : '#FFFFFF').borderRadius(12).onClick(() => this.filter = i));
      }.width('100%');
      if (this.visibleTasks().length === 0) { EmptyState() } else { this.taskList(); }
    }.padding({ left: 20, right: 20, top: 24, bottom: 12 }).width('100%').height('100%');
  }
  @Builder
  private calendarPage() {
    Column({ space: 18 }) {
      Text('学习日历').fontSize(24).fontWeight(FontWeight.Bold).fontColor('#202A43').alignSelf(ItemAlign.Start);
      Row() { Text('‹').fontSize(26).onClick(() => this.shiftMonth(-1)); Text(this.calendarDate.getFullYear() + '年 ' + (this.calendarDate.getMonth() + 1) + '月').fontSize(16).fontWeight(FontWeight.Medium).layoutWeight(1).textAlign(TextAlign.Center); Text('›').fontSize(26).onClick(() => this.shiftMonth(1)); }.padding(14).backgroundColor('#FFFFFF').borderRadius(16);
      Grid() {
        ForEach(['一','二','三','四','五','六','日'], (d: string) => GridItem() { Text(d).fontSize(12).fontColor('#9299AA').width('100%').textAlign(TextAlign.Center); });
        ForEach(Array.from({ length: this.firstWeekdayOffset() }, (_: number, i: number) => i), (_: number) => GridItem() { Text('').width(38).height(42); });
        ForEach(Array.from({ length: this.monthLength() }, (_: number, i: number) => i + 1), (d: number) => GridItem() {
          Column({ space: 3 }) { Text(d.toString()).fontSize(14).fontColor(d === this.selectedDay ? '#FFFFFF' : '#303A52'); Text(this.tasks.some((t: StudyTask) => t.plannedDate === this.dateKey(d)) ? '•' : ' ').fontSize(12).fontColor(d === this.selectedDay ? '#D5D0FF' : '#7567E8'); }
            .width(38).height(42).justifyContent(FlexAlign.Center).backgroundColor(d === this.selectedDay ? '#7162E8' : '#FFFFFF').borderRadius(13).onClick(() => this.selectedDay = d);
        });
      }.columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr').rowsGap(8).columnsGap(4).width('100%').padding(12).backgroundColor('#FFFFFF').borderRadius(18);
      Text((this.calendarDate.getMonth() + 1) + '月' + this.selectedDay + '日 · 学习计划').fontSize(17).fontWeight(FontWeight.Bold).fontColor('#29334D').alignSelf(ItemAlign.Start);
      List({ space: 10 }) { ForEach(this.tasks.filter((t: StudyTask) => t.plannedDate === this.dateKey(this.selectedDay)), (task: StudyTask) => ListItem() { TaskCard({ task: task, onToggle: (id: string) => this.toggle(id), onOpen: (id: string) => this.openTask(id) }); }); }.layoutWeight(1);
    }.padding({ left: 20, right: 20, top: 24 }).width('100%').height('100%');
  }
  @Builder
  private analysisPage() {
    Scroll() {
      Column({ space: 16 }) {
        Text('学习分析').fontSize(24).fontWeight(FontWeight.Bold).fontColor('#202A43').alignSelf(ItemAlign.Start);
        Row({ space: 12 }) { this.statCard('任务完成率', this.tasks.length === 0 ? '0%' : Math.round(this.tasks.filter((t: StudyTask) => t.done).length * 100 / this.tasks.length) + '%', ''); this.statCard('累计学习', this.sessions.reduce((sum: number, s: StudySession) => sum + s.minutes, 0).toString(), '分钟'); }
        Column({ space: 12 }) {
          Text('最近7天学习时长').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#29334D');
          ForEach(Array.from({ length: 7 }, (_: number, i: number) => i), (offset: number) => Row({ space: 8 }) {
            Text((this.recentDay(offset).getMonth() + 1) + '/' + this.recentDay(offset).getDate()).fontSize(10).fontColor('#687188').width(38);
            Progress({ value: this.minutesOn(this.recentKey(offset)), total: Math.max(this.settings.dailyGoalMinutes, this.minutesOn(this.recentKey(offset)), 1), type: ProgressType.Linear }).color('#786AEC').layoutWeight(1);
            Text(this.minutesOn(this.recentKey(offset)) + '分').fontSize(10).fontColor('#687188').width(38);
          }.width('100%').height(22));
        }.width('100%').padding(18).backgroundColor('#FFFFFF').borderRadius(18);
        Column({ space: 14 }) {
          Row() { Text('远程学习资源').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#29334D').layoutWeight(1); Button('刷新').fontSize(12).backgroundColor('#EEECFF').fontColor('#6758D8').onClick(() => this.refreshResources()); }
          Text('公开 Mock 接口 · JSONPlaceholder').fontSize(11).fontColor('#9299A9');
          if (this.resourceState === 'idle' || this.resourceState === 'loading') { Text(this.resourceState === 'idle' ? '点击刷新，获取远端资源' : '正在加载远端数据…').fontSize(13).fontColor('#747D91'); }
          else if (this.resourceState === 'error') { Text('加载失败，请检查网络后重试').fontSize(13).fontColor('#D65D62').onClick(() => this.refreshResources()); }
          else if (this.resourceState === 'empty') { EmptyState({ title: '暂无远程资源', detail: '稍后刷新试试' }); }
          else {
            Text('本次获取 ' + this.resources.length + ' 项 · 资源标题长度分布').fontSize(12).fontColor('#747D91');
            ForEach(this.resources.slice(0, 5), (item: StudyResource) => Row({ space: 8 }) {
              Text(item.title.slice(0, 23)).fontSize(10).fontColor('#687188').width(96).maxLines(1);
              Progress({ value: Math.min(item.title.length, 100), total: 100, type: ProgressType.Linear }).color('#786AEC').layoutWeight(1);
              Text(item.title.length.toString()).fontSize(10).fontColor('#687188');
            }.width('100%').height(22));
            List({ space: 8 }) { ForEach(this.resources.slice(0, 4), (r: StudyResource) => ListItem() { Column({ space: 4 }) { Text(r.title).fontSize(13).fontColor('#29334D').maxLines(2); Text(r.body).fontSize(11).fontColor('#9299A9').maxLines(2); }.alignItems(HorizontalAlign.Start).width('100%').padding(12).backgroundColor('#F7F7FB').borderRadius(12); }); }.height(230);
          }
        }.width('100%').padding(18).backgroundColor('#FFFFFF').borderRadius(18);
        Column({ space: 12 }) {
          Text('学科任务分布').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#29334D');
          ForEach(['数学','英语','专业课','其他'], (s: string) => Row({ space: 10 }) {
            Text(s).fontSize(12).fontColor('#687188').width(56);
            Progress({ value: this.tasks.filter((t: StudyTask) => t.subject === s).length, total: Math.max(this.tasks.length, 1), type: ProgressType.Linear }).color('#786AEC').layoutWeight(1);
            Text(this.tasks.filter((t: StudyTask) => t.subject === s).length.toString()).fontSize(12).fontColor('#687188');
          }.width('100%').height(20));
        }.width('100%').padding(18).backgroundColor('#FFFFFF').borderRadius(18);
      }.padding({ left: 20, right: 20, top: 24, bottom: 24 }).width('100%');
    }.scrollBar(BarState.Off);
  }
  @Builder
  private profilePage() {
    Column({ space: 16 }) {
      Text('我的').fontSize(24).fontWeight(FontWeight.Bold).fontColor('#202A43').alignSelf(ItemAlign.Start);
      Row({ space: 14 }) {
        Text(this.settings.displayName.trim().length > 0 ? this.settings.displayName.trim().slice(0, 1) : '我')
          .fontSize(22).fontColor('#FFFFFF').width(52).height(52).textAlign(TextAlign.Center).backgroundColor('#7162E8').borderRadius(18);
        Column({ space: 5 }) {
          Text(this.settings.displayName.trim().length > 0 ? this.settings.displayName.trim() + '同学' : '同学')
            .fontSize(17).fontWeight(FontWeight.Bold).fontColor('#29334D');
          Text('把每个目标变成今天的行动').fontSize(12).fontColor('#9299A9');
        }.alignItems(HorizontalAlign.Start);
      }.width('100%').padding(18).backgroundColor('#FFFFFF').borderRadius(18);
      Column({ space: 8 }) {
        Text('昵称（支持中文）').fontSize(12).fontColor('#687188').alignSelf(ItemAlign.Start);
        TextInput({ placeholder: '请输入昵称', text: this.displayNameInput }).type(InputType.Normal).placeholderColor('#A0A6B4').height(50).padding({ left: 16, right: 16 }).borderRadius(25).backgroundColor('#FFFFFF').onChange((v: string) => this.displayNameInput = v);
      }.width('100%');
      Column({ space: 8 }) {
        Text('每日学习目标（分钟）').fontSize(12).fontColor('#687188').alignSelf(ItemAlign.Start);
        TextInput({ placeholder: '例如 120', text: this.goalInput }).type(InputType.Number).height(50).padding({ left: 16, right: 16 }).borderRadius(25).backgroundColor('#FFFFFF').onChange((v: string) => this.goalInput = v);
      }.width('100%');
      Button('保存个人设置').width('100%').height(48).backgroundColor('#7162E8').onClick(() => this.saveSettings());
      Row() { this.statCard('每日学习目标', this.settings.dailyGoalMinutes.toString(), '分钟'); }
        .width('100%').padding(16).backgroundColor('#FFFFFF').borderRadius(18);
      Button('清除所有任务').width('100%').backgroundColor('#FFF0F0').fontColor('#CC5D63').onClick(() => AlertDialog.show({ title: '清除任务？', message: '此操作将删除本地任务列表。', primaryButton: { value: '清除', action: () => { this.tasks = []; this.persist(); } }, secondaryButton: { value: '取消', action: () => {} } }));
      Text('StudyFlow · 智慧校园学习与任务管理系统').fontSize(11).fontColor('#A0A6B4').margin({ top: 20 });
    }.padding({ left: 20, right: 20, top: 24 }).width('100%').height('100%');
  }
  @Builder
  private pageForRoute(name: string, param: Object) {
    if (name === 'edit') {
      NavDestination() {
      Column({ space: 12 }) {
        Row() { Text('‹ 返回').fontSize(15).fontColor('#7162E8').onClick(() => this.stack.pop()); }.width('100%');
        Text(this.editingId.length > 0 ? '编辑任务' : '创建任务').fontSize(24).fontWeight(FontWeight.Bold).fontColor('#202A43');
        Text('任务标题 *').fontSize(12).fontColor('#687188');
        TextInput({ placeholder: '例如：完成课程阅读', text: this.formTitle }).type(InputType.Normal).placeholderColor('#A0A6B4').onChange((v: string) => this.formTitle = v).backgroundColor('#FFFFFF');
        Text('任务描述').fontSize(12).fontColor('#687188');
        TextInput({ placeholder: '补充学习目标或备注', text: this.formDescription }).type(InputType.Normal).placeholderColor('#A0A6B4').onChange((v: string) => this.formDescription = v).backgroundColor('#FFFFFF');
        Text('学科分类').fontSize(12).fontColor('#687188');
        Row({ space: 6 }) { ForEach(['数学','英语','专业课','编程','其他'], (s: string) => Button(s).fontSize(11).fontColor(this.formSubject === s ? '#FFFFFF' : '#687188').backgroundColor(this.formSubject === s ? '#7162E8' : '#FFFFFF').onClick(() => this.formSubject = s)); }
        Text('优先级').fontSize(12).fontColor('#687188');
        Row({ space: 6 }) { ForEach(['高','中','低'], (s: string) => Button(s).fontSize(11).fontColor(this.formPriority === s ? '#FFFFFF' : '#687188').backgroundColor(this.formPriority === s ? '#7162E8' : '#FFFFFF').onClick(() => this.formPriority = s)); }
        Text('计划日期（YYYY-MM-DD）').fontSize(12).fontColor('#687188');
        TextInput({ placeholder: '2026-11-17', text: this.formDate }).type(InputType.Normal).placeholderColor('#A0A6B4').onChange((v: string) => this.formDate = v).backgroundColor('#FFFFFF');
        TextInput({ placeholder: '预计分钟数', text: this.formMinutes }).type(InputType.Number).onChange((v: string) => this.formMinutes = v).backgroundColor('#FFFFFF');
        Button('保存任务').width('100%').backgroundColor('#7162E8').onClick(() => this.saveTask(this.editingId, this.formTitle, this.formDescription, this.formSubject, this.formPriority, this.formDate, Number(this.formMinutes)));
        if (this.editingId.length > 0) { Button('删除任务').width('100%').backgroundColor('#FFF0F0').fontColor('#CC5D63').onClick(() => this.deleteTask(this.editingId)); }
      }.padding(20).width('100%').height('100%').backgroundColor('#F5F6FA').justifyContent(FlexAlign.Start);
      }.hideTitleBar(true).onReady(() => { this.editingId = param as string; });
    } else if (name === 'detail') {
      NavDestination() {
      Column({ space: 16 }) {
        Row() { Text('‹ 返回').fontSize(15).fontColor('#7162E8').onClick(() => this.stack.pop()); }.width('100%');
        Text(this.tasks.find((t: StudyTask) => t.id === this.detailId)?.title ?? '任务详情').fontSize(24).fontWeight(FontWeight.Bold).fontColor('#202A43');
        Text('传入任务编号：' + this.detailId).fontSize(13).fontColor('#9299A9');
        Text((this.tasks.find((t: StudyTask) => t.id === this.detailId)?.subject ?? '') + ' · 优先级 ' + (this.tasks.find((t: StudyTask) => t.id === this.detailId)?.priority ?? '') + ' · ' + (this.tasks.find((t: StudyTask) => t.id === this.detailId)?.plannedDate ?? '')).fontSize(15).fontColor('#556079');
        Text(this.tasks.find((t: StudyTask) => t.id === this.detailId)?.description ?? '暂无描述').fontSize(14).fontColor('#687188');
        Text('预计学习时长：' + (this.tasks.find((t: StudyTask) => t.id === this.detailId)?.minutes ?? 0) + ' 分钟').fontSize(14).fontColor('#687188');
        Button('标记完成').onClick(() => { this.toggle(this.detailId); this.stack.pop(); });
        Button('编辑任务').onClick(() => this.editTask(this.detailId));
        Button('删除任务').backgroundColor('#FFF0F0').fontColor('#CC5D63').onClick(() => this.deleteTask(this.detailId));
      }.padding(24).width('100%').height('100%').backgroundColor('#F5F6FA');
      }.hideTitleBar(true).onReady(() => { this.detailId = param as string; });
    }
  }
  build() {
    Navigation(this.stack) {
      Column() {
    if (this.tab === 0) { this.homePage(); }
        else if (this.tab === 1) { this.tasksPage(); }
        else if (this.tab === 2) { this.calendarPage(); }
        else if (this.tab === 3) { this.analysisPage(); }
        else { this.profilePage(); }
        Row() {
          ForEach(['首页','任务','日历','分析','我的'], (label: string, i: number) => Column({ space: 3 }) { Text(['⌂','✓','▦','◌','○'][i]).fontSize(19).fontColor(this.tab === i ? '#7162E8' : '#9BA2B1'); Text(label).fontSize(10).fontColor(this.tab === i ? '#7162E8' : '#9BA2B1'); }
            .layoutWeight(1).padding({ top: 9, bottom: 7 }).onClick(() => { this.tab = i; if (i === 3 && this.resourceState === 'idle') this.refreshResources(); }));
        }.width('100%').height(72).backgroundColor('#FFFFFF').padding({ left: 8, right: 8, bottom: 14, top: 6 }).border({ color: '#ECEEF3', width: { top: 1 } });
      }.width('100%').height('100%').backgroundColor('#F5F6FA').padding({ bottom: 40 });
    }.mode(NavigationMode.Stack).hideTitleBar(true)
      .navDestination(this.pageForRoute).onAppear(() => { this.displayNameInput = this.settings.displayName; this.goalInput = this.settings.dailyGoalMinutes.toString(); });
  }
}
