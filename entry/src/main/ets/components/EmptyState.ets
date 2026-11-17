@Component
export struct EmptyState {
  title: string = '这里还空着';
  detail: string = '添加一项计划，开始今天的学习';
  build() {
    Column({ space: 10 }) {
      Text('✦').fontSize(30).fontColor('#7C6CF2');
      Text(this.title).fontSize(16).fontWeight(FontWeight.Medium).fontColor('#35405A');
      Text(this.detail).fontSize(13).fontColor('#9299A9');
    }.width('100%').padding(28).alignItems(HorizontalAlign.Center)
      .backgroundColor('#FFFFFF').borderRadius(18);
  }
}
