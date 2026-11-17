@Component
export struct ProgressCard {
  title: string = '学习进度';
  current: number = 0;
  total: number = 0;
  build() {
    Column({ space: 12 }) {
      Row() {
        Text(this.title).fontSize(14).fontColor('#E6E5FF').layoutWeight(1);
        Text(this.total === 0 ? '0%' : Math.round(this.current * 100 / this.total) + '%').fontSize(13).fontColor('#FFFFFF');
      }
      Progress({ value: this.total === 0 ? 0 : this.current * 100 / this.total, total: 100, type: ProgressType.Linear })
        .color('#A9F0D1').backgroundColor('#554BAE').height(7);
    }.width('100%').padding(18).backgroundColor('#6255D9').borderRadius(20);
  }
}
