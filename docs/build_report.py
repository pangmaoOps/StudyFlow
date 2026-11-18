from pathlib import Path
from docx import Document
from docx.shared import Inches, Pt
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_CELL_VERTICAL_ALIGNMENT
from docx.oxml import OxmlElement
from docx.oxml.ns import qn
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
TEMPLATE = Path(__import__('os').environ.get('STUDYFLOW_REPORT_TEMPLATE', str(ROOT / 'docs' / '湖南农业大学课程论文格式模板.docx')))
if not TEMPLATE.exists():
    raise FileNotFoundError('Set STUDYFLOW_REPORT_TEMPLATE to the provided course-paper template DOCX.')
OUT = ROOT / 'docs' / 'StudyFlow_移动应用开发课程报告.docx'

def set_text(p, text):
    p.clear()
    p.add_run(text)

def make_diagram(path):
    img = Image.new('RGB', (1500, 830), '#F6F7FB')
    d = ImageDraw.Draw(img)
    fonts = [r'C:/Windows/Fonts/msyh.ttc', r'C:/Windows/Fonts/simhei.ttf']
    font_path = next((x for x in fonts if Path(x).exists()), None)
    f = ImageFont.truetype(font_path, 27) if font_path else ImageFont.load_default()
    fsmall = ImageFont.truetype(font_path, 21) if font_path else ImageFont.load_default()
    def box(xy, title, lines, fill='#FFFFFF'):
        d.rounded_rectangle(xy, radius=22, fill=fill, outline='#D7D9E7', width=3)
        x1,y1,x2,y2=xy
        d.text((x1+22,y1+18), title, font=f, fill='#302B54')
        for i,line in enumerate(lines): d.text((x1+24,y1+68+i*38),line,font=fsmall,fill='#5D6478')
    box((40,70,440,350),'学习首页',['当日任务摘要','完成进度 / 快捷操作'], '#ECEAFF')
    box((550,70,950,350),'任务管理',['TaskCard 列表与筛选','详情、表单、CRUD','NavPathStack 路由'],'#FFFFFF')
    box((1060,70,1460,350),'学习日历',['月份切换 / 日期选择','按 plannedDate 聚合任务','跨月、闰年日期计算'],'#FFFFFF')
    box((40,455,440,755),'数据分析',['本地学习时长 / 学科统计','最近 7 天原生进度图','远程资源长度图表'],'#FFFFFF')
    box((550,455,950,755),'个人中心',['Preferences 设置','每日目标与用户名称','演示数据清除'],'#FFFFFF')
    box((1060,455,1460,755),'数据与服务',['Preferences 本地 KV','Network Kit + JSONPlaceholder','StudyStore 统一状态'],'#E8F6F0')
    # System-function grouping uses no arrows, per template instruction.
    img.save(path)

def make_home_mockup(path):
    img = Image.new('RGB', (900, 1500), '#F5F6FA')
    d = ImageDraw.Draw(img)
    fp = r'C:/Windows/Fonts/msyh.ttc'
    f = ImageFont.truetype(fp, 30) if Path(fp).exists() else ImageFont.load_default()
    fs = ImageFont.truetype(fp, 22) if Path(fp).exists() else ImageFont.load_default()
    d.text((55,55),'StudyFlow',font=fs,fill='#6255D9')
    d.text((55,100),'早上好，学生',font=f,fill='#202A43')
    d.rounded_rectangle((45,180,855,520),radius=32,fill='#6255D9')
    d.text((85,220),'今日完成任务',font=fs,fill='#E6E5FF')
    d.text((85,290),'1 / 3',font=ImageFont.truetype(fp,56) if Path(fp).exists() else f,fill='#FFFFFF')
    d.text((85,390),'完成率 33%',font=fs,fill='#FFFFFF')
    d.rounded_rectangle((55,585,845,665),radius=20,fill='#EEECFF')
    d.text((85,607),'今天的计划',font=f,fill='#29334D')
    for i,(title,sub) in enumerate([('复习高等数学第三章','数学 · 09:30 · 45分钟'),('完成英语阅读练习','英语 · 14:00 · 30分钟'),('整理数据结构课堂笔记','专业课 · 16:30 · 40分钟')]):
        y=700+i*170
        d.rounded_rectangle((55,y,845,y+140),radius=24,fill='#FFFFFF',outline='#E6E8EF',width=2)
        d.ellipse((85,y+45,125,y+85),outline='#7567E8',width=3)
        d.text((150,y+30),title,font=fs,fill='#24304A')
        d.text((150,y+82),sub,font=ImageFont.truetype(fp,18) if Path(fp).exists() else fs,fill='#8992A5')
    d.rounded_rectangle((55,1240,845,1350),radius=24,fill='#FFFFFF')
    d.text((100,1275),'首页       任务       日历       分析       我的',font=fs,fill='#7162E8')
    img.save(path)

def fill_cell(cell, value, header=False):
    cell.text = value
    cell.vertical_alignment = WD_CELL_VERTICAL_ALIGNMENT.CENTER
    for p in cell.paragraphs:
        for r in p.runs:
            r.font.name = '宋体'
            r._element.get_or_add_rPr().rFonts.set(qn('w:eastAsia'), '宋体')
            r.font.size = Pt(9)
            if header: r.bold = True

doc = Document(TEMPLATE)
# The supplied template contains sample images from unrelated projects.
# Keep the template's text and layout, but remove every inherited picture.
for story in [doc._element, *[part._element for section in doc.sections for part in (
    section.header, section.footer, section.first_page_header, section.first_page_footer,
    section.even_page_header, section.even_page_footer
)]]:
    for picture in list(story.xpath('.//w:drawing')) + list(story.xpath('.//w:pict')):
        picture.getparent().remove(picture)
ps = doc.paragraphs
replacements = {
  1:'湖南农业大学课程论文',
  3:'学  院：【待填写】    班  级：【待填写】',
  4:'姓  名：【待填写】    学  号：【待填写】',
  5:'课程论文题目：StudyFlow智慧校园学习与任务管理系统的设计与实现',
  6:'课程名称：移动应用开发',
  25:'StudyFlow智慧校园学习与任务管理系统的设计与实现',
  26:'——基于HarmonyOS与ArkTS的学习任务管理应用',
  27:'                            学    生：【待填写】',
  28:'（【学院】【班级】，学号【待填写】）',
  31:'摘  要：针对大学生学习任务分散、进度难以跟踪的问题，本文设计并实现StudyFlow智慧校园学习与任务管理系统。系统使用HarmonyOS ArkTS与ArkUI构建，采用Navigation和NavPathStack管理任务详情与编辑页面，通过Preferences保存任务、学习时长和个人设置，并使用Network Kit请求公开JSONPlaceholder测试接口，将返回内容标记为演示学习资源。系统提供首页概览、任务管理、学习日历、数据分析与个人中心五个主页面，支持任务新增、修改、删除、完成切换、筛选、跨月日历查看、手动学习时长记录以及远程资料加载状态呈现。统计图使用原生Progress组件根据本地记录或远程响应动态更新，减少第三方依赖并兼顾Previewer兼容性。工程在DevEco Studio 26.0.0配套HarmonyOS SDK 6.1.1环境下完成ArkTS编译和HAP打包；Previewer图形交互仍需按测试清单复核。',
  32:'关键词：HarmonyOS；ArkTS；学习任务管理；Navigation；Preferences',
  36:'高校学生通常同时面对课程作业、考试复习、专业实践和自主学习等多类任务。若计划分散在纸张、聊天记录或不同应用中，学生容易遗漏截止时间，也难以回顾实际投入。移动应用可以把学习任务、日期安排、完成状态和学习时长整合到统一界面，并以简明统计帮助用户调整计划。StudyFlow以大学生个人学习规划为场景，围绕“创建任务—安排日期—执行学习—记录时长—查看反馈”设计闭环。项目同时作为HarmonyOS移动应用开发课程实践，覆盖ArkUI容器、自定义组件、状态管理、Navigation路由、网络交互和Git分阶段管理。系统界面和业务逻辑依据本项目需求独立实现，开源资料仅用于确认框架API与工程模式。',
  37:'正文按模板设置中文正文风格；技术标识、接口路径和字段名保留英文原文。',
  39:'HarmonyOS应用开发逐步形成以ArkTS声明式UI、ArkUI组件和Stage应用模型为主的开发方式。华为官方文档提供Navigation、NavPathStack、Preferences、Network Kit及Canvas等接口说明，OpenHarmony示例仓库提供按API场景组织的独立样例。wuyukobe24/HMApp_ArkTS公开项目展示了页面组织、网络请求和路由跳转实践。本项目将其作为技术阅读资料，结合本机SDK声明文件核对接口，不沿用其业务页面或学习管理逻辑。随着Previewer和声明式组件工具链完善，采用原生组件实现轻量校园应用具备较低依赖和较易复现的特点。',
  41:'系统面向单个学生用户。用户可查看当天计划、管理不同学科的任务、在日历中定位日期、记录自习分钟数、查看统计并获取公开测试接口返回的演示资料。系统在网络不可用、数据为空和本地首次启动时均需保持可操作并给出状态说明。',
  42:'主要用例包括：浏览今日任务、创建/编辑/删除任务、标记完成、按状态筛选、按日期查看计划、记录学习时长、查看统计、刷新远程资料以及修改个人目标。',
  48:'系统由五个业务页面、三个复用组件、共享状态/持久化服务和远程资源服务构成。任务对象为页面间共享的数据源，完成或编辑后由Preferences保存；资源请求与本地统计相互独立。',
  50:'图1 StudyFlow系统功能结构图',
  53:'开发环境为DevEco Studio 26.0.0，目标SDK 26.0.0，兼容SDK 6.1.1(24)。界面采用ArkTS与ArkUI原生Row、Column、List、Grid、Scroll、Navigation和Progress，不引入第三方图表库。任务、时长和设置以Preferences保存；网络通过@kit.NetworkKit的http模块异步GET公开JSONPlaceholder接口，并设置连接和读取超时。ArkUI状态使用页面@State；自定义TaskCard、EmptyState和ProgressCard负责复用展示。',
  58:'首页以欢迎信息和当日任务进度卡片建立视觉层级，下方显示今日任务列表、完成快捷操作和学习概览。完成率由当天任务完成数计算，零任务时显示0%，首页任务按系统日期筛选。',
  63:'首页从共享任务及学习时长状态读取数据，无单独服务端首页接口。持久化数据的字段结构见表2，日期采用YYYY-MM-DD。',
  64:'请求URL：本地Preferences键 study_tasks_v1 / study_sessions_v1',
  65:'交互方式：Preferences异步读取与写入',
  66:'数据格式：JSON字符串；ArkTS接口访问键值数据',
  67:'输入参数：应用上下文；键名由StudyStore固定',
  68:'表1 首页及本地数据读取参数', 69:'Table 1 Local data access parameters',
  70:'主要响应字段如表2所示。', 71:'表2 任务数据字段说明',72:'Table 2 StudyTask fields',
  73:'任务管理与任务日历详细设计',
  74:'任务列表由TaskCard复用组件展示标题、学科、时间和状态。过滤器提供全部、待完成、已完成三种状态。用户进入任务详情后可通过NavPathStack传入任务ID查看字段，继续进入编辑表单完成保存或经确认后删除。日期页面使用动态月长与首周偏移计算，支持跨年、闰年和月份切换。',
  75:'任务使用本地Preferences键study_tasks_v1保存；路由名detail和edit通过NavPathStack.pushPath传入任务ID。学习日期字段为YYYY-MM-DD。新增编辑字段包括标题、描述、学科、优先级、计划日期和预计分钟数。',
  76:'数据分析与个人中心详细设计',
  77:'分析页汇总任务完成率、学习时长和学科分布；最近7天图表按studyDate聚合StudySession分钟数。个人中心编辑显示名称和每日目标，设置使用Preferences持久化。',
  78:'远程资料接口采用GET https://jsonplaceholder.typicode.com/posts?_limit=8；响应对象映射id、title和body。请求状态分为idle、loading、success、empty和error。网络图表依据本次实际返回的资源标题长度生成，不代表真实学校资料。',
  82:'首页依据系统日期筛选任务，以今日完成数和总数计算比例，并提供任务卡片快捷入口。页面状态由@State维护，状态变化触发界面刷新。',
  83:'以下界面图片由学生在StudyFlow Previewer中采集，展示当前版本的真实运行界面。',
  87:'任务管理、日历和详情实现',
  88:'数据分析、远程资料与个人中心实现',
  90:'本项目完成了一个以学习任务闭环为核心的HarmonyOS应用原型。系统以ArkTS和ArkUI构建五个主业务页面，使用Row、Column、List、Grid和Scroll组织布局，封装任务卡片、空状态及进度卡片。任务支持新增、编辑、删除、完成切换和状态过滤；Navigation配合NavPathStack完成详情与编辑路由及任务ID传递。Preferences持久化任务、学习时长与个人设置，学习统计根据实际记录计算。网络模块通过Network Kit访问无需认证的JSONPlaceholder测试接口，并对加载、错误、空数据和重试提供界面反馈。命令行验证显示ArkTS编译与HAP打包通过。',
  91:'本次已在DevEco Studio Previewer显示首页、任务、日历、分析及个人中心，并将学生提供的实际运行截图纳入报告。Git提交历史以DevEco Studio版本控制日志截图附于报告末尾。远程接口使用JSONPlaceholder通用测试数据，页面明确标注为演示资源；如需接入校内资料，应另行确认数据来源、授权范围与服务稳定性。封面个人信息及教师评阅栏由学生和教师按实际情况填写。',
  93:'参考文献',
  94:'[1] Huawei. Navigation Page Routing and NavPathStack[EB/OL]. https://developer.huawei.com/consumer/en/doc/harmonyos-guides/arkts-navigation-jump/.',
  95:'[2] Huawei. Persisting User Preferences (ArkTS)[EB/OL]. https://developer.huawei.com/consumer/en/doc/harmonyos-guides/data-persistence-by-preferences/.',
  96:'[3] Huawei. Using HTTP for Network Access[EB/OL]. https://developer.huawei.com/consumer/en/doc/HarmonyOS-Guides/http-request/.',
  97:'[4] OpenHarmony. applications_app_samples[EB/OL]. https://github.com/openharmony/applications_app_samples.（按具体样例LICENSE及文件头遵循Apache-2.0要求；本项目未复制样例代码。）',
  98:'[5] wuyukobe24. HMApp_ArkTS[EB/OL]. https://github.com/wuyukobe24/HMApp_ArkTS.（仓库许可未确认，仅作技术阅读来源，未复制代码。）',
  99:'',
}
for idx, text in replacements.items():
    if idx < len(ps): set_text(ps[idx], text)

for p in ps:
    if p.text.startswith('http://www.uml.org.cn'):
        set_text(p, '系统角色为学生本人，业务用例由浏览任务、维护计划、记录学习和查看分析组成。')
    elif p.text.startswith('图 x 首页原型设计图'):
        set_text(p, '图2 StudyFlow首页Previewer运行截图')
    elif p.text.startswith('Fig.x xx'):
        set_text(p, 'Fig.2 StudyFlow homepage in Previewer')
    elif p.text.startswith('图x 首页实现截图'):
        set_text(p, '')
    elif p.text.startswith('Figx Index Page'):
        set_text(p, '')

# Remove template guidance paragraphs while preserving heading hierarchy and page design.
remove_text = ('(简述项目发起', '(阐述Harmony', '(文字描述)', '(收集并整理', '线上绘图工具推荐', '或者 https://app.diagrams', '(对项目引入', '(文字描述，界面', '(提供首页中数据', 'Xx1页面详细设计', 'Xx2页面详细设计', '(简单文字描述)', '通过Previewer或者模拟器')
for p in list(doc.paragraphs):
    if p.text.strip().startswith(remove_text) or p.text.strip().startswith(('备注：','1.3000字左右','2.篇参考文献','3.论文纸张统一','4.教师评阅应有','5.项目源码将','5.特殊课程由')):
        p._element.getparent().remove(p._element)

diagram = ROOT / 'docs' / 'studyflow_system_structure.png'
make_diagram(diagram)
# Insert images in the blank template paragraphs immediately before their captions.
for index, p in enumerate(doc.paragraphs):
    if p.text.startswith(('图 1 系统功能结构图', '图1 StudyFlow系统功能结构图')) and index > 0:
        slot = doc.paragraphs[index - 1]
        slot.alignment = WD_ALIGN_PARAGRAPH.CENTER
        slot.paragraph_format.keep_with_next = True
        p.paragraph_format.keep_with_next = True
        if index + 1 < len(doc.paragraphs):
            doc.paragraphs[index + 1].paragraph_format.keep_together = True
        slot.add_run().add_picture(str(diagram), width=Inches(6.0))
        break
home_screenshot = ROOT / 'docs' / 'screenshots' / '01_home.png'
for index, p in enumerate(doc.paragraphs):
    if p.text.startswith('图2 StudyFlow首页Previewer运行截图') and index > 0:
        slot = doc.paragraphs[index - 1]
        slot.alignment = WD_ALIGN_PARAGRAPH.CENTER
        slot.paragraph_format.keep_with_next = True
        p.paragraph_format.keep_with_next = True
        if index + 1 < len(doc.paragraphs):
            doc.paragraphs[index + 1].paragraph_format.keep_together = True
        slot.add_run().add_picture(str(home_screenshot), width=Inches(2.15))
        break

def add_after(paragraph, text, style='Normal'):
    from docx.text.paragraph import Paragraph
    new_p = OxmlElement('w:p')
    paragraph._p.addnext(new_p)
    result = Paragraph(new_p, paragraph._parent)
    result.style = style
    result.add_run(text)
    return result

for p in list(doc.paragraphs):
    if p.text == '任务管理、日历和详情实现':
        add_after(p, '任务页用状态筛选和复用卡片呈现列表。新建与编辑共用表单，校验标题、日期格式和分钟数后写回任务集合；删除操作先确认，完成状态可切换。日历以Date计算月份首日偏移和当月天数，使用plannedDate关联任务，因此可以正确显示跨月与闰年日期。')
    elif p.text == '数据分析、远程资料与个人中心实现':
        add_after(p, '数据分析页面汇总Preferences中的学习记录，按最近七个自然日聚合分钟数，并按学科统计任务。资源服务创建独立HttpRequest，设置连接和读取超时，检查HTTP响应码后解析JSON；UI通过idle、loading、success、empty、error状态决定提示、列表和资源标题长度条形图。个人中心保存用户名称和每日目标；清除任务前弹出确认。')

# Add only screenshots supplied from the user's running StudyFlow Previewer.
references_heading = next(p for p in doc.paragraphs if p.text.strip() == '参考文献')
gallery_heading_element = OxmlElement('w:p')
references_heading._p.addprevious(gallery_heading_element)
from docx.text.paragraph import Paragraph
gallery_heading = Paragraph(gallery_heading_element, references_heading._parent)
gallery_heading.style = 'Heading 2'
gallery_heading.paragraph_format.page_break_before = True
gallery_heading.add_run('StudyFlow Previewer运行界面')
gallery_items = [
    ('02_tasks.png', '图3 学习任务页面'),
    ('03_calendar.png', '图4 学习日历页面'),
    ('04_analysis_top.png', '图5 学习分析页面'),
    ('05_analysis_resources.png', '图6 远程学习资源与接口数据'),
    ('06_profile_jason.png', '图7 个人中心与昵称设置'),
]
for index, (filename, caption) in enumerate(gallery_items):
    image_element = OxmlElement('w:p')
    references_heading._p.addprevious(image_element)
    image_paragraph = Paragraph(image_element, references_heading._parent)
    image_paragraph.alignment = WD_ALIGN_PARAGRAPH.CENTER
    image_paragraph.paragraph_format.keep_with_next = True
    if index in (2, 4, 5):
        image_paragraph.paragraph_format.page_break_before = True
    image_width = Inches(6.0) if filename == '07_git_log.png' else Inches(1.75)
    image_paragraph.add_run().add_picture(str(ROOT / 'docs' / 'screenshots' / filename), width=image_width)
    caption_element = OxmlElement('w:p')
    references_heading._p.addprevious(caption_element)
    caption_paragraph = Paragraph(caption_element, references_heading._parent)
    caption_paragraph.alignment = WD_ALIGN_PARAGRAPH.CENTER
    caption_paragraph.paragraph_format.keep_together = True
    caption_run = caption_paragraph.add_run(caption)
    caption_run.font.size = Pt(10)

# Keep the Git history attachment after the references so it cannot split or
# force reference paragraphs onto an unexpected page.
git_heading_element = OxmlElement('w:p')
references_heading._p.addnext(git_heading_element)
git_heading = Paragraph(git_heading_element, references_heading._parent)
git_heading.style = 'Normal'
git_heading.paragraph_format.page_break_before = True
git_heading.alignment = WD_ALIGN_PARAGRAPH.CENTER
git_heading.add_run('附件：StudyFlow Git阶段提交记录')
git_image_element = OxmlElement('w:p')
git_heading._p.addnext(git_image_element)
git_image = Paragraph(git_image_element, references_heading._parent)
git_image.alignment = WD_ALIGN_PARAGRAPH.CENTER
git_image.paragraph_format.keep_with_next = True
git_image.add_run().add_picture(str(ROOT / 'docs' / 'screenshots' / '07_git_log.png'), width=Inches(6.0))
git_caption_element = OxmlElement('w:p')
git_image._p.addnext(git_caption_element)
git_caption = Paragraph(git_caption_element, references_heading._parent)
git_caption.alignment = WD_ALIGN_PARAGRAPH.CENTER
git_caption.add_run('图8 DevEco Studio Git提交历史截图').font.size = Pt(10)

# Explicit network interface schema. The request is a public test endpoint, not a campus backend.
doc.add_paragraph('表3 远程学习资源接口字段', style='Normal')
network_table = doc.add_table(rows=1, cols=3)
network_table.alignment = WD_TABLE_ALIGNMENT.CENTER
for i,v in enumerate(['名称','类型','说明']): fill_cell(network_table.rows[0].cells[i],v,True)
for row in [
    ['URL','HTTPS GET','https://jsonplaceholder.typicode.com/posts?_limit=8'],
    ['响应码','number','2xx视为成功；非2xx进入错误状态'],
    ['id','number','测试帖标识'],
    ['title','string','测试帖标题；用于长度统计图表'],
    ['body','string','测试帖内容摘要'],
    ['状态','枚举','idle / loading / success / empty / error']
]:
    cells=network_table.add_row().cells
    for i,v in enumerate(row): fill_cell(cells[i],v)

# Keep the remote-interface table with the report body, before screenshots and references.
api_heading = next(p for p in doc.paragraphs if p.text.strip() == '表3 远程学习资源接口字段')
api_heading._p.getparent().remove(api_heading._p)
network_table._tbl.getparent().remove(network_table._tbl)
gallery_heading._p.addprevious(network_table._tbl)
gallery_heading._p.addprevious(api_heading._p)

# Replace the template's sample API tables with actual project schemas.
tables = doc.tables
if len(tables) >= 2:
    t = tables[0]
    data = [['参数字段','必选','类型/范围','说明'], ['study_tasks_v1','是','JSON字符串','任务列表键'], ['study_sessions_v1','是','JSON字符串','学习时长记录键'], ['study_settings_v1','是','JSON字符串','用户设置键']]
    while len(t.rows) < len(data): t.add_row()
    while len(t.rows) > len(data): t._tbl.remove(t.rows[-1]._tr)
    for ri,row in enumerate(data):
        for ci,value in enumerate(row): fill_cell(t.cell(ri,ci), value, ri == 0)
    t2=tables[1]
    data2=[['字段名称','字段类型','字段说明'], ['id','string','任务唯一标识'], ['title','string','任务标题'], ['description','string','可选描述'], ['subject','string','数学/英语/专业课/编程/其他'], ['priority','string','高/中/低'], ['plannedDate','string','计划日期YYYY-MM-DD'], ['due','string','任务时间'], ['minutes','number','预计学习分钟数'], ['done','boolean','完成状态']]
    while len(t2.rows)<len(data2): t2.add_row()
    while len(t2.rows)>len(data2): t2._tbl.remove(t2.rows[-1]._tr)
    for ri,row in enumerate(data2):
        for ci,value in enumerate(row): fill_cell(t2.cell(ri,ci),value,ri==0)

doc.core_properties.title = 'StudyFlow智慧校园学习与任务管理系统的设计与实现'
doc.core_properties.subject = '移动应用开发课程论文'
doc.core_properties.author = '【学生姓名待填写】'
doc.save(OUT)
print(OUT)
