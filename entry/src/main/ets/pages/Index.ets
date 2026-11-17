import { StudyTask } from '../models/StudyTask';
import { StudyStore } from '../services/StudyStore';
import { getResources, StudyResource } from '../services/ResourceService';
import { TaskCard } from '../components/TaskCard';
import { EmptyState } from '../components/EmptyState';

@Entry
@Component
struct Index {
  @State private tab: number = 0;
  @State private tasks: StudyTask[] = [];
  @State private filter: number = 0;
  @State private resourceState: string = 'idle';
  @State private resources: StudyResource[] = [];
  @State private detailId: string = '';
  private stack: NavPathStack = new NavPathStack();
  aboutToAppear() { StudyStore.load(getContext(this)).then((v: StudyTask[]) => this.tasks = v); }
  private visibleTasks(): StudyTask[] {
    if (this.filter === 1) return this.tasks.filter((t: StudyTask) => !t.done);
    if (this.filter === 2) return this.tasks.filter((t: StudyTask) => t.done);
    return this.tasks;
  }
  private persist(): void { StudyStore.save(this.tasks); }
  private toggle(id: string): void {
    this.tasks = this.tasks.map((t: StudyTask) => { const updated: StudyTask = { id: t.id, title: t.title, subject: t.subject, due: t.due, minutes: t.minutes, done: !t.done }; return t.id === id ? updated : t; });
    this.persist();
  }
  private openTask(id: string): void { this.detailId = id; this.stack.pushPath({ name: 'detail', param: id }); }
  private addTask(): void {
    AlertDialog.show({ title: '新建学习任务', message: '将在任务列表加入一项学习计划。', primaryButton: { value: '创建', action: () => {
      const task: StudyTask = { id: Date.now().toString(), title: '新的学习任务', subject: '专业课', due: '18:00', minutes: 30, done: false };
      this.tasks = [task, ...this.tasks]; this.persist();
      } }, secondaryButton: { value: '取消', action: () => {} } });
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
            Text('TUESDAY · 17 NOV').fontSize(11).fontColor('#858DA1').letterSpacing(1);
            Text('早上好，智炜').fontSize(24).fontWeight(FontWeight.Bold).fontColor('#202A43');
          }.alignItems(HorizontalAlign.Start).layoutWeight(1);
          Text('SF').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#FFFFFF').width(42).height(42)
            .textAlign(TextAlign.Center).backgroundColor('#7567E8').borderRadius(15);
        }.width('100%');
        Column({ space: 12 }) {
          Row() { Text('今日学习进度').fontSize(14).fontColor('#E6E5FF').layoutWeight(1); Text('专注每一步').fontSize(12).fontColor('#D4D0FF'); }
          Row({ space: 14 }) {
            Column({ space: 4 }) {
              Text(this.tasks.filter((t: StudyTask) => t.done).length + ' / ' + this.tasks.length)
                .fontSize(29).fontWeight(FontWeight.Bold).fontColor('#FFFFFF');
              Text('项任务已完成').fontSize(12).fontColor('#D7D4FF');
            }.alignItems(HorizontalAlign.Start).layoutWeight(1);
            Column({ space: 5 }) {
              Text(this.tasks.length === 0 ? '0%' : Math.round(this.tasks.filter((t: StudyTask) => t.done).length * 100 / this.tasks.length) + '%')
                .fontSize(25).fontWeight(FontWeight.Bold).fontColor('#FFFFFF');
              Text('完成率').fontSize(12).fontColor('#D7D4FF');
            }.alignItems(HorizontalAlign.End);
          }.width('100%');
          Progress({ value: this.tasks.length === 0 ? 0 : this.tasks.filter((t: StudyTask) => t.done).length * 100 / this.tasks.length, total: 100, type: ProgressType.Linear })
            .color('#A9F0D1').backgroundColor('#554BAE').height(7);
        }.width('100%').padding(20).backgroundColor('#6255D9').borderRadius(22);
        Row() { Text('今天的计划').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#252F49').layoutWeight(1); Button('+ 新任务').fontSize(12).fontColor('#6758D8').backgroundColor('#EEECFF').borderRadius(12).onClick(() => this.addTask()); }
        if (this.visibleTasks().length === 0) { EmptyState({ title: '今天还没有学习任务', detail: '创建一个任务，开始高效的一天' }) }
        else { this.taskList(); }
        Row({ space: 10 }) {
          this.statCard('本周完成', this.tasks.filter((t: StudyTask) => t.done).length.toString(), '项任务');
          this.statCard('计划学习', this.tasks.reduce((n: number, t: StudyTask) => n + t.minutes, 0).toString(), '分钟');
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
      Row() { Text('‹').fontSize(26).onClick(() => {}); Text('2026年 11月').fontSize(16).fontWeight(FontWeight.Medium).layoutWeight(1).textAlign(TextAlign.Center); Text('›').fontSize(26).onClick(() => {}); }.padding(14).backgroundColor('#FFFFFF').borderRadius(16);
      Grid() {
        ForEach(['一','二','三','四','五','六','日'], (d: string) => GridItem() { Text(d).fontSize(12).fontColor('#9299AA').width('100%').textAlign(TextAlign.Center); });
        ForEach(Array.from({ length: 30 }, (_: number, i: number) => i + 1), (d: number) => GridItem() {
          Column({ space: 3 }) { Text(d.toString()).fontSize(14).fontColor(d === 17 ? '#FFFFFF' : '#303A52'); Text(this.tasks.some((t: StudyTask) => Number(t.due.split(':')[0]) >= 0 && d === 17) ? '•' : ' ').fontSize(12).fontColor(d === 17 ? '#D5D0FF' : '#7567E8'); }
            .width(38).height(42).justifyContent(FlexAlign.Center).backgroundColor(d === 17 ? '#7162E8' : '#FFFFFF').borderRadius(13);
        });
      }.columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr').rowsGap(8).columnsGap(4).width('100%').padding(12).backgroundColor('#FFFFFF').borderRadius(18);
      Text('11月17日 · 今日计划').fontSize(17).fontWeight(FontWeight.Bold).fontColor('#29334D').alignSelf(ItemAlign.Start);
      this.taskList();
    }.padding({ left: 20, right: 20, top: 24 }).width('100%').height('100%');
  }
  @Builder
  private analysisPage() {
    Scroll() {
      Column({ space: 16 }) {
        Text('学习分析').fontSize(24).fontWeight(FontWeight.Bold).fontColor('#202A43').alignSelf(ItemAlign.Start);
        Row({ space: 12 }) { this.statCard('任务完成率', this.tasks.length === 0 ? '0%' : Math.round(this.tasks.filter((t: StudyTask) => t.done).length * 100 / this.tasks.length) + '%', ''); this.statCard('学习计划', this.tasks.length.toString(), '项'); }
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
      Row({ space: 14 }) { Text('知').fontSize(22).fontColor('#FFFFFF').width(52).height(52).textAlign(TextAlign.Center).backgroundColor('#7162E8').borderRadius(18); Column({ space: 5 }) { Text('智炜同学').fontSize(17).fontWeight(FontWeight.Bold).fontColor('#29334D'); Text('把每个目标变成今天的行动').fontSize(12).fontColor('#9299A9'); }.alignItems(HorizontalAlign.Start); }.width('100%').padding(18).backgroundColor('#FFFFFF').borderRadius(18);
      this.statCard('每日学习目标', '120', '分钟');
      Button('清除所有任务').width('100%').backgroundColor('#FFF0F0').fontColor('#CC5D63').onClick(() => AlertDialog.show({ title: '清除任务？', message: '此操作将删除本地任务列表。', primaryButton: { value: '清除', action: () => { this.tasks = []; this.persist(); } }, secondaryButton: { value: '取消', action: () => {} } }));
      Text('StudyFlow · 智慧校园学习与任务管理系统').fontSize(11).fontColor('#A0A6B4').margin({ top: 20 });
    }.padding({ left: 20, right: 20, top: 24 }).width('100%').height('100%');
  }
  @Builder
  private pageForRoute(name: string, param: Object) {
    if (name === 'detail') {
      Column({ space: 16 }) {
        Row() { Text('‹ 返回').fontSize(15).fontColor('#7162E8').onClick(() => this.stack.pop()); }.width('100%');
        Text(this.tasks.find((t: StudyTask) => t.id === this.detailId)?.title ?? '任务详情').fontSize(24).fontWeight(FontWeight.Bold).fontColor('#202A43');
        Text('传入任务编号：' + this.detailId).fontSize(13).fontColor('#9299A9');
        Text(this.tasks.find((t: StudyTask) => t.id === this.detailId)?.subject ?? '').fontSize(15).fontColor('#556079');
        Button('标记完成').onClick(() => { this.toggle(this.detailId); this.stack.pop(); });
      }.padding(24).width('100%').height('100%').backgroundColor('#F5F6FA');
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
            .layoutWeight(1).padding({ top: 9, bottom: 7 }).onClick(() => this.tab = i));
        }.width('100%').backgroundColor('#FFFFFF').padding({ bottom: 4 }).border({ color: '#ECEEF3', width: { top: 1 } });
      }.width('100%').height('100%').backgroundColor('#F5F6FA');
    }.mode(NavigationMode.Stack).hideTitleBar(true)
      .navDestination(this.pageForRoute);
  }
}
