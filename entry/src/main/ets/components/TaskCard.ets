import { StudyTask } from '../models/StudyTask';

@Component
export struct TaskCard {
  @Prop task: StudyTask;
  onToggle: (id: string) => void = () => {};
  onOpen: (id: string) => void = () => {};
  build() {
    Row({ space: 12 }) {
      Button(this.task.done ? '✓' : '').width(30).height(30).borderRadius(15)
        .backgroundColor(this.task.done ? '#52B788' : '#FFFFFF')
        .onClick(() => this.onToggle(this.task.id));
      Column({ space: 5 }) {
        Text(this.task.title).fontSize(15).fontWeight(FontWeight.Medium)
          .fontColor(this.task.done ? '#9AA1B1' : '#24304A')
          .decoration({ type: this.task.done ? TextDecorationType.LineThrough : TextDecorationType.None });
        Text(this.task.subject + '  ·  ' + this.task.due + '  ·  ' + this.task.minutes + ' 分钟')
          .fontSize(12).fontColor('#8992A5');
      }.alignItems(HorizontalAlign.Start).layoutWeight(1).onClick(() => this.onOpen(this.task.id));
      Text('›').fontSize(24).fontColor('#A2A9B8');
    }.width('100%').padding(14).backgroundColor('#FFFFFF').borderRadius(16);
  }
}
