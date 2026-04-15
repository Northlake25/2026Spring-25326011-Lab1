import { MatchDataManager } from '../model/MatchDataManager';
import { FootballMatch, MatchEvent, MatchEventType, Player, Team, generateId, getEventIcon, parseMatchTime, GoalEvent, SubstitutionEvent, CardEvent, StartingLineupEvent, MatchConfig } from '../model/FootballMatchModel';
import { MatchReportGenerator } from '../model/MatchReportGenerator';
import common from '@ohos.app.ability.common';
import fs from '@ohos.file.fs';
import util from '@ohos.util';

// 时间轴项接口
interface TimelineItem {
  isSeparator: boolean;
  separatorText?: string;
  matchTime?: string;
  homeEvent?: MatchEvent;
  awayEvent?: MatchEvent;
}

// 时间分组接口
interface TimeGroup {
  home?: MatchEvent;
  away?: MatchEvent;
}

@Entry
@Component
struct Index {
  @State message: ResourceStr = $r('app.string.home_title');
  @State currentPage: string = 'home';
  @State selectedMatchId: string = '';

  // 数据管理器
  private dataManager: MatchDataManager = MatchDataManager.getInstance();

  // 新建比赛表单数据
  @State homeTeamName: string = '';
  @State awayTeamName: string = '';
  @State venue: string = '';
  @State date: string = '';
  @State time: string = '';
  @State competition: string = '';
  @State referee: string = '';
  @State firstHalfDuration: number = 45;
  @State secondHalfDuration: number = 45;
  @State hasExtraTime: boolean = false;
  @State extraTimeDuration: number = 30;
  @State hasPenaltyShootout: boolean = false;

  // 当前比赛
  @State currentMatch: FootballMatch | null = null;
  @State matches: FootballMatch[] = [];
  @State selectedEventId: string = ''; // 选中的事件ID

  // 事件记录对话框
  @State showEventDialog: boolean = false;
  @State eventType: MatchEventType = MatchEventType.GOAL;
  @State eventMatchTime: string = "45'";

  // 进球事件数据
  @State goalTeamId: string = '';
  @State goalScorerName: string = '';
  @State goalScorerNumber: string = '';
  @State goalAssisterName: string = '';
  @State goalAssisterNumber: string = '';
  @State isPenaltyGoal: boolean = false; // 是否点球进球

  // 换人事件数据
  @State subTeamId: string = '';
  @State subPlayerOutName: string = '';
  @State subPlayerOutNumber: string = '';
  @State subPlayerInName: string = '';
  @State subPlayerInNumber: string = '';

  // 红黄牌事件数据
  @State cardTeamId: string = '';
  @State cardPlayerName: string = '';
  @State cardPlayerNumber: string = '';
  @State isSecondYellow: boolean = false;

  aboutToAppear() {
    this.refreshMatches();
  }

  refreshMatches() {
    this.matches = this.dataManager.getMatches();
  }

  refreshCurrentMatch() {
    if (this.selectedMatchId) {
      const match = this.dataManager.getMatchById(this.selectedMatchId);
      this.currentMatch = match !== undefined ? match : null;
      
      if (this.currentMatch) {
        console.log('刷新当前比赛 - 主队:', this.currentMatch.homeTeam.name, 'ID:', this.currentMatch.homeTeam.id);
        console.log('刷新当前比赛 - 客队:', this.currentMatch.awayTeam.name, 'ID:', this.currentMatch.awayTeam.id);
      }
    }
  }

  // 获取比赛比分显示文本
  getMatchScoreText(match: FootballMatch): string {
    // 检查是否有点球大战
    const hasPenalty = match.homePenaltyScore !== undefined && match.awayPenaltyScore !== undefined;
    
    if (hasPenalty) {
      // 有点球大战: "3班(1) 0-0 (2)7班"
      return `${match.homeTeam.name}(${match.homePenaltyScore}) ${match.homeScore}-${match.awayScore} (${match.awayPenaltyScore})${match.awayTeam.name}`;
    } else {
      // 无点球大战: "3班 0-0 7班"
      return `${match.homeTeam.name} ${match.homeScore}-${match.awayScore} ${match.awayTeam.name}`;
    }
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Text(this.message)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.white'))
      }
      .width('100%')
      .height(60)
      .justifyContent(FlexAlign.Center)
      .backgroundColor($r('app.color.primary_color'))

      // 主内容区域
      Column() {
        if (this.currentPage === 'home') {
          this.HomePage()
        } else if (this.currentPage === 'matches') {
          this.MatchesPage()
        } else if (this.currentPage === 'newMatch') {
          this.NewMatchPage()
        } else if (this.currentPage === 'matchDetail') {
          this.MatchDetailPage()
        }
      }
      .width('100%')
      .height('100%')
      .padding(16)
      .backgroundColor($r('app.color.background_color'))

      // 底部导航栏
      Row() {
        Button($r('app.string.nav_home'))
          .width('25%')
          .height(50)
          .backgroundColor(this.currentPage === 'home' ? $r('app.color.primary_dark') : $r('app.color.primary_color'))
          .fontColor(Color.White)
          .onClick(() => {
            this.currentPage = 'home';
          })

        Button($r('app.string.nav_matches'))
          .width('25%')
          .height(50)
          .backgroundColor(this.currentPage === 'matches' ? $r('app.color.primary_dark') : $r('app.color.primary_color'))
          .fontColor(Color.White)
          .onClick(() => {
            this.currentPage = 'matches';
            this.refreshMatches();
          })

        Button($r('app.string.nav_new'))
          .width('25%')
          .height(50)
          .backgroundColor(this.currentPage === 'newMatch' ? $r('app.color.primary_dark') : $r('app.color.primary_color'))
          .fontColor(Color.White)
          .onClick(() => {
            this.currentPage = 'newMatch';
          })

        Button($r('app.string.nav_settings'))
          .width('25%')
          .height(50)
          .backgroundColor($r('app.color.primary_color'))
          .fontColor(Color.White)
          .onClick(() => {
            this.currentPage = 'home';
          })
      }
      .width('100%')
      .height(60)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .height('100%')
  }

  // 主页
  @Builder
  HomePage() {
    Column() {
      Text('欢迎使用足球比赛记录器')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 20 })

      Text('这是一个赛后记录工具,用于记录已结束的比赛进程')
        .fontSize(16)
        .margin({ bottom: 20 })

      Button('开始记录比赛')
        .width('80%')
        .height(50)
        .backgroundColor($r('app.color.success_color'))
        .fontColor(Color.White)
        .fontSize(18)
        .margin({ bottom: 20 })
        .onClick(() => {
          this.currentPage = 'newMatch';
        })

      // 显示最近的比赛
      if (this.matches.length > 0) {
        Text('最近比赛')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 10 })
          .alignSelf(ItemAlign.Start)

        List() {
          ForEach(this.matches.slice(0, 3), (match: FootballMatch) => {
            ListItem() {
              this.MatchCard(match)
            }
          })
        }
        .width('100%')
        .layoutWeight(1)
      }
    }
    .width('100%')
    .onAppear(() => {
      this.refreshMatches();
    })
  }

  // 比赛列表页
  @Builder
  MatchesPage() {
    Column() {
      Text('比赛列表')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 20 })

      if (this.matches.length === 0) {
        Text('暂无比赛记录')
          .fontSize(16)
          .fontColor($r('app.color.text_secondary'))
      } else {
        List() {
          ForEach(this.matches, (match: FootballMatch) => {
            ListItem() {
              this.MatchCard(match)
            }
          })
        }
        .width('100%')
        .layoutWeight(1)
      }
    }
    .width('100%')
    .onAppear(() => {
      this.refreshMatches();
    })
  }

  // 比赛卡片
  @Builder
  MatchCard(match: FootballMatch) {
    Column() {
      Row() {
        Text(match.competition)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.primary_color'))
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .margin({ bottom: 8 })

      Row() {
        // 构建比分显示文本
        Text(this.getMatchScoreText(match))
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .margin({ bottom: 8 })

      Row() {
        Text(`${match.date} ${match.time}`)
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
        Text(' | ')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
        Text(match.venue)
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)

      Row() {
        Button('查看详情')
          .width(80)
          .height(30)
          .backgroundColor($r('app.color.primary_color'))
          .fontColor(Color.White)
          .fontSize(12)
          .onClick(() => {
            this.selectedMatchId = match.id;
            this.refreshCurrentMatch();
            this.currentPage = 'matchDetail';
          })

        Button('删除')
          .width(80)
          .height(30)
          .backgroundColor($r('app.color.danger_color'))
          .fontColor(Color.White)
          .fontSize(12)
          .margin({ left: 10 })
          .onClick(() => {
            AlertDialog.show({
              title: '确认删除',
              message: '确定要删除这场比赛吗?',
              primaryButton: {
                value: '取消',
                action: () => {}
              },
              secondaryButton: {
                value: '确定',
                action: () => {
                  this.dataManager.deleteMatch(match.id);
                  this.refreshMatches();
                }
              }
            });
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.End)
      .margin({ top: 10 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(8)
    .shadow({ radius: 4, color: Color.Black, offsetX: 0, offsetY: 2 })
    .margin({ bottom: 16 })
  }

  // 新建比赛页
  @Builder
  NewMatchPage() {
    Scroll() {
      Column() {
        Text('新建比赛')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 20 })

        // 表单输入
        this.FormInput('主队名称', '请输入主队名称', (value) => this.homeTeamName = value)
        this.FormInput('客队名称', '请输入客队名称', (value) => this.awayTeamName = value)
        this.FormInput('比赛场地', '请输入比赛场地', (value) => this.venue = value)
        this.FormInput('比赛日期', 'YYYY-MM-DD', (value) => this.date = value)
        this.FormInput('比赛时间', 'HH:MM', (value) => this.time = value)
        this.FormInput('赛事名称', '请输入赛事名称', (value) => this.competition = value)
        this.FormInput('裁判', '请输入裁判姓名', (value) => this.referee = value)
        
        // 上下半场时间设置
        Text('比赛时长设置')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 16, bottom: 8 })
          .alignSelf(ItemAlign.Start)
        
        Row() {
          Column() {
            Text('上半场时长(分钟)')
              .fontSize(12)
              .margin({ bottom: 4 })
            TextInput({ placeholder: '45' })
              .width('100%')
              .height(40)
              .type(InputType.Number)
              .onChange((value) => this.firstHalfDuration = parseInt(value) || 45)
          }
          .width('45%')
          
          Column() {
            Text('下半场时长(分钟)')
              .fontSize(12)
              .margin({ bottom: 4 })
            TextInput({ placeholder: '45' })
              .width('100%')
              .height(40)
              .type(InputType.Number)
              .onChange((value) => this.secondHalfDuration = parseInt(value) || 45)
          }
          .width('45%')
          .margin({ left: 10 })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        
        // 加时赛和点球大战配置
        Text('比赛选项')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 16, bottom: 8 })
          .alignSelf(ItemAlign.Start)
        
        Row() {
          Row() {
            Checkbox({ name: 'hasExtraTime', group: 'matchOptions' })
              .select(this.hasExtraTime)
              .onChange((value) => this.hasExtraTime = value)
            Text('加时赛')
              .fontSize(14)
              .margin({ left: 8 })
          }
          
          Row() {
            Checkbox({ name: 'hasPenalty', group: 'matchOptions' })
              .select(this.hasPenaltyShootout)
              .onChange((value) => this.hasPenaltyShootout = value)
            Text('点球大战')
              .fontSize(14)
              .margin({ left: 8 })
          }
          .margin({ left: 20 })
        }
        .width('100%')
        .margin({ bottom: 8 })
        
        // 加时赛时间输入
        if (this.hasExtraTime) {
          Row() {
            Text('加时赛时长(分钟):')
              .fontSize(14)
            TextInput({ placeholder: '30' })
              .width(80)
              .height(35)
              .type(InputType.Number)
              .onChange((value) => this.extraTimeDuration = parseInt(value) || 30)
          }
          .width('100%')
          .margin({ bottom: 16 })
        }

        Row() {
          Button('取消')
            .width('45%')
            .height(45)
            .backgroundColor($r('app.color.text_disabled'))
            .fontColor(Color.White)
            .onClick(() => {
              this.currentPage = 'home';
              this.clearForm();
            })

          Button('创建比赛')
            .width('45%')
            .height(45)
            .backgroundColor($r('app.color.success_color'))
            .fontColor(Color.White)
            .margin({ left: 10 })
            .onClick(() => {
              this.createMatch();
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ top: 20 })
      }
      .width('100%')
      .padding(20)
    }
    .width('100%')
    .height('100%')
    .scrollBar(BarState.Auto)
  }

  // 表单输入组件
  @Builder
  FormInput(label: string, placeholder: string, onChange: (value: string) => void) {
    Column() {
      Text(label)
        .fontSize(14)
        .fontColor($r('app.color.text_primary'))
        .margin({ bottom: 4 })
        .alignSelf(ItemAlign.Start)

      TextInput({ placeholder: placeholder })
        .width('100%')
        .height(40)
        .backgroundColor($r('app.color.card_background'))
        .border({ width: 1, color: $r('app.color.border_color'), radius: 4 })
        .padding({ left: 8, right: 8 })
        .margin({ bottom: 16 })
        .onChange((value) => onChange(value))
    }
    .width('100%')
  }

  // 创建比赛
  createMatch() {
    if (!this.homeTeamName || !this.awayTeamName) {
      AlertDialog.show({ message: '请填写主队和客队名称' });
      return;
    }

    const homeTeamId = generateId();
    const awayTeamId = generateId();

    const homeTeam: Team = {
      id: homeTeamId,
      name: this.homeTeamName,
      color: '#FF0000'
    };

    const awayTeam: Team = {
      id: awayTeamId,
      name: this.awayTeamName,
      color: '#0000FF'
    };

    const matchConfig: MatchConfig = {
      firstHalfDuration: this.firstHalfDuration,
      secondHalfDuration: this.secondHalfDuration,
      hasExtraTime: this.hasExtraTime,
      extraTimeDuration: this.extraTimeDuration,
      hasPenaltyShootout: this.hasPenaltyShootout
    };

    console.log('创建比赛 - 主队ID:', homeTeamId, '主队名称:', this.homeTeamName);
    console.log('创建比赛 - 客队ID:', awayTeamId, '客队名称:', this.awayTeamName);
    console.log('比赛配置 - 上半场:', this.firstHalfDuration, '分钟, 下半场:', this.secondHalfDuration, '分钟');

    const match = this.dataManager.createMatch({
      id: '',
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      venue: this.venue || '未知',
      date: this.date || '2024-01-01',
      time: this.time || '00:00',
      competition: this.competition || '友谊赛',
      referee: this.referee || '未知',
      homeScore: 0,
      awayScore: 0,
      status: 'finished',
      events: [],
      config: matchConfig
    });

    console.log('比赛创建成功 - ID:', match.id);
    console.log('比赛主队ID:', match.homeTeam.id, '比赛客队ID:', match.awayTeam.id);

    this.selectedMatchId = match.id;
    this.refreshCurrentMatch();
    this.currentPage = 'matchDetail';
    this.clearForm();
  }

  // 清空表单
  clearForm() {
    this.homeTeamName = '';
    this.awayTeamName = '';
    this.venue = '';
    this.date = '';
    this.time = '';
    this.competition = '';
    this.referee = '';
  }

  // 比赛详情页
  @Builder
  MatchDetailPage() {
    Stack() {
      if (this.currentMatch) {
        Column() {
          // 比赛标题和比分
          Row() {
            Text(`${this.currentMatch.competition} - ${this.currentMatch.homeTeam.name} vs ${this.currentMatch.awayTeam.name}`)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor($r('app.color.primary_color'))
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .margin({ bottom: 20 })

          // 比分显示
          Column() {
            Row() {
              Column() {
                Text(this.currentMatch.homeTeam.name)
                  .fontSize(16)
                Text(this.currentMatch.homeScore.toString())
                  .fontSize(32)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.primary_color'))
              }
              .width('30%')

              Text('VS')
                .fontSize(24)
                .fontWeight(FontWeight.Bold)

              Column() {
                Text(this.currentMatch.awayTeam.name)
                  .fontSize(16)
                Text(this.currentMatch.awayScore.toString())
                  .fontSize(32)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.primary_color'))
              }
              .width('30%')
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)
            .margin({ bottom: 10 })

            // 点球大战比分显示
            if (this.currentMatch.homePenaltyScore !== undefined && this.currentMatch.awayPenaltyScore !== undefined) {
              Row() {
                Text(`点球 ${this.currentMatch.homePenaltyScore} : ${this.currentMatch.awayPenaltyScore}`)
                  .fontSize(16)
                  .fontColor($r('app.color.text_secondary'))
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)
              .margin({ bottom: 10 })
            }
          }
          .width('100%')
          .padding(20)
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(8)
          .margin({ bottom: 20 })

          // 操作按钮
          Row() {
            Button('返回')
              .width('18%')
              .height(40)
              .backgroundColor($r('app.color.text_disabled'))
              .fontColor(Color.White)
              .onClick(() => {
                this.currentPage = 'home';
              })

            Button('记录事件')
              .width('18%')
              .height(40)
              .backgroundColor($r('app.color.success_color'))
              .fontColor(Color.White)
              .margin({ left: 8 })
              .onClick(() => {
                this.showEventDialog = true;
              })

            Button('导出报告')
              .width('18%')
              .height(40)
              .backgroundColor($r('app.color.primary_color'))
              .fontColor(Color.White)
              .margin({ left: 8 })
              .onClick(() => {
                this.exportMatchReport();
              })

            Button('保存')
              .width('18%')
              .height(40)
              .backgroundColor($r('app.color.secondary_color'))
              .fontColor(Color.White)
              .margin({ left: 8 })
              .onClick(() => {
                this.saveMatchToFile();
              })

            // 删除选中事件按钮
            if (this.selectedEventId) {
              Button('删除事件')
                .width('18%')
                .height(40)
                .backgroundColor($r('app.color.danger_color'))
                .fontColor(Color.White)
                .margin({ left: 8 })
                .onClick(() => {
                  this.deleteEvent(this.selectedEventId);
                  this.selectedEventId = '';
                })
            }
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .margin({ bottom: 20 })

          // 事件时间线 - 时间轴布局
          Text('比赛事件时间线')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 10 })
            .alignSelf(ItemAlign.Start)

          List() {
            ForEach(this.getTimelineItems(), (item: TimelineItem) => {
              ListItem() {
                if (item.isSeparator) {
                  // 时间分隔线
                  this.TimeSeparator(item.separatorText || '')
                } else {
                  // 时间轴事件行
                  this.TimelineEventRow(item)
                }
              }
            })
          }
          .width('100%')
          .layoutWeight(1)
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(8)
          .padding(16)
        }
        .width('100%')
        .height('100%')
      }

      // 事件记录对话框
      if (this.showEventDialog) {
        this.EventDialog()
      }
    }
    .width('100%')
    .height('100%')
  }

  // 获取排序后的事件列表
  getSortedEvents(): MatchEvent[] {
    if (!this.currentMatch) return [];
    return this.currentMatch.events.sort((a, b) => {
      return parseMatchTime(a.matchTime) - parseMatchTime(b.matchTime);
    });
  }

  // 获取时间轴项列表
  getTimelineItems(): TimelineItem[] {
    if (!this.currentMatch) return [];
    
    const homeTeamId = this.currentMatch.homeTeam.id;
    const firstHalfDuration = this.currentMatch.config?.firstHalfDuration || 45;
    const secondHalfDuration = this.currentMatch.config?.secondHalfDuration || 45;
    const hasExtraTime = this.currentMatch.config?.hasExtraTime || false;
    const extraTimeDuration = this.currentMatch.config?.extraTimeDuration || 30;
    
    // 计算常规时间总时长
    const regularTime = firstHalfDuration + secondHalfDuration + (hasExtraTime ? extraTimeDuration : 0);
    
    // 按时间排序所有事件
    const sortedEvents = this.currentMatch.events.slice().sort((a, b) => {
      return parseMatchTime(a.matchTime) - parseMatchTime(b.matchTime);
    });
    
    // 按时间分组事件
    const timeGroups: Map<string, TimeGroup> = new Map();
    
    sortedEvents.forEach(event => {
      const time = event.matchTime;
      let teamType: 'home' | 'away' = 'home';
      
      if (event.type === MatchEventType.GOAL || event.type === MatchEventType.OWN_GOAL || event.type === MatchEventType.PENALTY_MISSED) {
        const goalEvent = event as GoalEvent;
        teamType = goalEvent.teamId === homeTeamId ? 'home' : 'away';
      } else if (event.type === MatchEventType.SUBSTITUTION) {
        const subEvent = event as SubstitutionEvent;
        teamType = subEvent.teamId === homeTeamId ? 'home' : 'away';
      } else if (event.type === MatchEventType.YELLOW_CARD || event.type === MatchEventType.RED_CARD) {
        const cardEvent = event as CardEvent;
        teamType = cardEvent.teamId === homeTeamId ? 'home' : 'away';
      }
      
      if (!timeGroups.has(time)) {
        const group: TimeGroup = {
          home: undefined,
          away: undefined
        };
        timeGroups.set(time, group);
      }
      
      const group = timeGroups.get(time);
      if (group) {
        if (teamType === 'home') {
          group.home = event;
        } else {
          group.away = event;
        }
      }
    });
    
    // 构建时间轴项
    const result: TimelineItem[] = [];
    let hasFirstHalf = false;
    let hasSecondHalf = false;
    let hasExtraTimeHalf = false;
    let hasPenaltyShootout = false;
    
    // 先处理常规时间事件(非P开头)
    const regularTimes = Array.from(timeGroups.keys()).filter(time => !time.toUpperCase().startsWith('P'));
    regularTimes.sort((a, b) => parseMatchTime(a) - parseMatchTime(b));
    
    regularTimes.forEach(time => {
      const group = timeGroups.get(time);
      if (!group) return;
      
      const timeNum = parseMatchTime(time);
      
      // 上半场分隔
      if (timeNum <= firstHalfDuration && !hasFirstHalf) {
        result.push({ isSeparator: true, separatorText: '上半场' });
        hasFirstHalf = true;
      }
      
      // 下半场分隔
      if (timeNum > firstHalfDuration && timeNum <= (firstHalfDuration + secondHalfDuration) && !hasSecondHalf) {
        result.push({ isSeparator: true, separatorText: '下半场' });
        hasSecondHalf = true;
      }
      
      // 加时赛分隔
      if (hasExtraTime && timeNum > (firstHalfDuration + secondHalfDuration) && !hasExtraTimeHalf) {
        result.push({ isSeparator: true, separatorText: '加时赛' });
        hasExtraTimeHalf = true;
      }
      
      // 添加事件行
      result.push({
        isSeparator: false,
        matchTime: time,
        homeEvent: group.home,
        awayEvent: group.away
      });
    });
    
    // 再处理点球大战事件(P开头)
    const penaltyTimes = Array.from(timeGroups.keys()).filter(time => time.toUpperCase().startsWith('P'));
    penaltyTimes.sort((a, b) => parseMatchTime(a) - parseMatchTime(b));
    
    if (penaltyTimes.length > 0) {
      // 添加点球大战分隔
      result.push({ isSeparator: true, separatorText: '点球大战' });
      hasPenaltyShootout = true;
      
      penaltyTimes.forEach(time => {
        const group = timeGroups.get(time);
        if (!group) return;
        
        // 添加事件行
        result.push({
          isSeparator: false,
          matchTime: time,
          homeEvent: group.home,
          awayEvent: group.away
        });
      });
    }
    
    return result;
  }

  // 时间轴事件行组件
  @Builder
  TimelineEventRow(item: TimelineItem) {
    Row() {
      // 左侧 - 主队事件
      Column() {
        if (item.homeEvent) {
          this.EventText(item.homeEvent, true)
        }
      }
      .width('38%')
      .alignItems(HorizontalAlign.End)
      
      // 中间 - 时间轴
      Column() {
        Text(item.matchTime || '')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.primary_color'))
      }
      .width('24%')
      .alignItems(HorizontalAlign.Center)
      
      // 右侧 - 客队事件
      Column() {
        if (item.awayEvent) {
          this.EventText(item.awayEvent, false)
        }
      }
      .width('38%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .height(item.homeEvent?.type === MatchEventType.SUBSTITUTION || item.awayEvent?.type === MatchEventType.SUBSTITUTION ? 60 : 40)
    .border({ width: { bottom: 1 }, color: '#E0E0E0' })
    .backgroundColor(this.selectedEventId === item.homeEvent?.id || this.selectedEventId === item.awayEvent?.id ? '#E3F2FD' : Color.Transparent)
    .onClick(() => {
      // 选中事件
      if (item.homeEvent) {
        this.selectedEventId = this.selectedEventId === item.homeEvent.id ? '' : item.homeEvent.id;
      } else if (item.awayEvent) {
        this.selectedEventId = this.selectedEventId === item.awayEvent.id ? '' : item.awayEvent.id;
      }
    })
  }

  // 事件文本组件(支持颜色标记)
  @Builder
  EventText(event: MatchEvent, isRight: boolean) {
    Column() {
      // 解析带颜色标记的文本
      if (event.description.includes('[GREEN]') || event.description.includes('[RED]')) {
        // 换人事件,分行显示
        if (event.description.split('\n').length > 1) {
          // 第一行 - 上场球员
          Row() {
            Text(getEventIcon(event.type))
              .fontSize(14)
              .margin({ right: 4 })
            Text(event.description.split('\n')[0].replace('[GREEN]↑[COLOR]', ''))
              .fontSize(11)
            Text('↑')
              .fontSize(11)
              .fontColor('#4CAF50')
          }
          .width('100%')
          .justifyContent(isRight ? FlexAlign.End : FlexAlign.Start)
          .padding(isRight ? { right: 4 } : { left: 4 })
          
          // 第二行 - 下场球员
          Row() {
            Text('  ')
              .fontSize(14)
              .margin({ right: 4 })
            Text(event.description.split('\n')[1].replace('[RED]↓[COLOR]', ''))
              .fontSize(11)
            Text('↓')
              .fontSize(11)
              .fontColor('#F44336')
          }
          .width('100%')
          .justifyContent(isRight ? FlexAlign.End : FlexAlign.Start)
          .padding(isRight ? { right: 4 } : { left: 4 })
        }
      } else {
        // 普通事件
        Row() {
          Text(getEventIcon(event.type))
            .fontSize(14)
            .margin({ right: 4 })
          Text(event.description)
            .fontSize(11)
        }
        .width('100%')
        .justifyContent(isRight ? FlexAlign.End : FlexAlign.Start)
        .padding(isRight ? { right: 4 } : { left: 4 })
      }
    }
    .width('100%')
  }

  // 时间分隔线组件
  @Builder
  TimeSeparator(text: string) {
    Row() {
      Text(text)
        .fontSize(12)
        .fontColor($r('app.color.text_secondary'))
        .fontWeight(FontWeight.Bold)
    }
    .width('100%')
    .height(30)
    .justifyContent(FlexAlign.Center)
    .backgroundColor('#F5F5F5')
    .borderRadius(4)
    .margin({ top: 4, bottom: 4 })
  }

  // 紧凑型事件项组件
  @Builder
  EventItemCompact(event: MatchEvent) {
    Row() {
      Text(event.matchTime)
        .fontSize(12)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.primary_color'))
        .width(35)

      Text(getEventIcon(event.type))
        .fontSize(16)
        .width(25)

      Column() {
        Text(event.description)
          .fontSize(11)
          .fontColor($r('app.color.text_primary'))
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding({ top: 6, bottom: 6, left: 4, right: 4 })
    .border({ width: { bottom: 1 }, color: $r('app.color.border_color') })
  }

  // 事件项组件
  @Builder
  EventItem(event: MatchEvent) {
    Row() {
      Text(event.matchTime)
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.primary_color'))
        .width(50)

      Text(getEventIcon(event.type))
        .fontSize(20)
        .width(40)

      Column() {
        Text(this.getEventTypeName(event.type))
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 2 })

        Text(event.description)
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
      }
      .width('60%')
      .alignItems(HorizontalAlign.Start)

      // 删除按钮
      Button('删除')
        .width(50)
        .height(30)
        .fontSize(12)
        .backgroundColor($r('app.color.danger_color'))
        .fontColor(Color.White)
        .onClick(() => {
          this.deleteEvent(event.id);
        })
    }
    .width('100%')
    .padding({ top: 8, bottom: 8 })
    .border({ width: { bottom: 1 }, color: $r('app.color.border_color') })
  }

  // 获取事件类型名称
  getEventTypeName(type: MatchEventType): string {
    switch (type) {
      case MatchEventType.GOAL: return '进球';
      case MatchEventType.SUBSTITUTION: return '换人';
      case MatchEventType.YELLOW_CARD: return '黄牌';
      case MatchEventType.RED_CARD: return '红牌';
      case MatchEventType.STARTING_LINEUP: return '首发阵容';
      default: return '其他';
    }
  }

  // 事件记录对话框
  @Builder
  EventDialog() {
    Column() {
      Column() {
        Text('记录事件')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 20 })

        // 事件类型选择
        Row() {
          Button('进球')
            .width('16%')
            .height(35)
            .backgroundColor(this.eventType === MatchEventType.GOAL ? $r('app.color.primary_color') : $r('app.color.text_disabled'))
            .fontColor(Color.White)
            .onClick(() => this.eventType = MatchEventType.GOAL)

          Button('换人')
            .width('16%')
            .height(35)
            .backgroundColor(this.eventType === MatchEventType.SUBSTITUTION ? $r('app.color.primary_color') : $r('app.color.text_disabled'))
            .fontColor(Color.White)
            .onClick(() => this.eventType = MatchEventType.SUBSTITUTION)

          Button('黄牌')
            .width('16%')
            .height(35)
            .backgroundColor(this.eventType === MatchEventType.YELLOW_CARD ? $r('app.color.primary_color') : $r('app.color.text_disabled'))
            .fontColor(Color.White)
            .onClick(() => this.eventType = MatchEventType.YELLOW_CARD)

          Button('红牌')
            .width('16%')
            .height(35)
            .backgroundColor(this.eventType === MatchEventType.RED_CARD ? $r('app.color.primary_color') : $r('app.color.text_disabled'))
            .fontColor(Color.White)
            .onClick(() => this.eventType = MatchEventType.RED_CARD)
          
          Button('罚丢点球')
            .width('16%')
            .height(35)
            .fontSize(11)
            .backgroundColor(this.eventType === MatchEventType.PENALTY_MISSED ? $r('app.color.primary_color') : $r('app.color.text_disabled'))
            .fontColor(Color.White)
            .onClick(() => this.eventType = MatchEventType.PENALTY_MISSED)
          
          Button('乌龙球')
            .width('16%')
            .height(35)
            .fontSize(11)
            .backgroundColor(this.eventType === MatchEventType.OWN_GOAL ? $r('app.color.primary_color') : $r('app.color.text_disabled'))
            .fontColor(Color.White)
            .onClick(() => this.eventType = MatchEventType.OWN_GOAL)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ bottom: 20 })

        // 比赛时间输入
        this.FormInput('比赛时间', "如: 45' / 90'(加时) / P(点球大战)", (value) => this.eventMatchTime = value)

        // 根据事件类型显示不同表单
        if (this.eventType === MatchEventType.GOAL) {
          this.GoalForm()
        } else if (this.eventType === MatchEventType.SUBSTITUTION) {
          this.SubstitutionForm()
        } else if (this.eventType === MatchEventType.YELLOW_CARD || this.eventType === MatchEventType.RED_CARD) {
          this.CardForm()
        } else if (this.eventType === MatchEventType.PENALTY_MISSED || this.eventType === MatchEventType.OWN_GOAL) {
          this.PenaltyMissedOrOwnGoalForm()
        }

        // 确认和取消按钮
        Row() {
          Button('取消')
            .width('45%')
            .height(45)
            .backgroundColor($r('app.color.text_disabled'))
            .fontColor(Color.White)
            .onClick(() => {
              this.showEventDialog = false;
              this.clearEventData();
            })

          Button('确认')
            .width('45%')
            .height(45)
            .backgroundColor($r('app.color.success_color'))
            .fontColor(Color.White)
            .margin({ left: 10 })
            .onClick(() => {
              this.saveEvent();
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .margin({ top: 20 })
      }
      .width('90%')
      .padding(20)
      .backgroundColor($r('app.color.card_background'))
      .borderRadius(12)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('rgba(0,0,0,0.5)')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  // 进球表单
  @Builder
  GoalForm() {
    Column() {
      // 球队选择
      Text('进球球队')
        .fontSize(14)
        .margin({ bottom: 8 })
        .alignSelf(ItemAlign.Start)

      Row() {
        Button(this.currentMatch?.homeTeam.name || '主队')
          .width('45%')
          .height(35)
          .backgroundColor(this.goalTeamId === this.currentMatch?.homeTeam.id ? $r('app.color.primary_color') : $r('app.color.text_disabled'))
          .fontColor(Color.White)
          .onClick(() => {
            if (this.currentMatch) {
              this.goalTeamId = this.currentMatch.homeTeam.id;
              console.log('选择主队进球 - 主队ID:', this.currentMatch.homeTeam.id, '主队名称:', this.currentMatch.homeTeam.name);
            }
          })

        Button(this.currentMatch?.awayTeam.name || '客队')
          .width('45%')
          .height(35)
          .backgroundColor(this.goalTeamId === this.currentMatch?.awayTeam.id ? $r('app.color.primary_color') : $r('app.color.text_disabled'))
          .fontColor(Color.White)
          .onClick(() => {
            if (this.currentMatch) {
              this.goalTeamId = this.currentMatch.awayTeam.id;
              console.log('选择客队进球 - 客队ID:', this.currentMatch.awayTeam.id, '客队名称:', this.currentMatch.awayTeam.name);
            }
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 16 })

      this.FormInput('进球球员姓名', '如: 张三', (value) => this.goalScorerName = value)
      this.FormInput('进球球员号码', '如: 10', (value) => this.goalScorerNumber = value)
      
      // 点球大战时不显示助攻选项
      if (!this.eventMatchTime.toUpperCase().startsWith('P')) {
        this.FormInput('助攻球员姓名(可选)', '如: 李四', (value) => this.goalAssisterName = value)
        this.FormInput('助攻球员号码(可选)', '如: 8', (value) => this.goalAssisterNumber = value)
        
        // 点球选项(常规时间)
        Row() {
          Checkbox()
            .select(this.isPenaltyGoal)
            .onChange((checked) => this.isPenaltyGoal = checked)
          Text('点球进球')
            .fontSize(14)
        }
        .width('100%')
        .margin({ top: 8 })
      } else {
        // 点球大战提示
        Text('点球大战阶段')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 8, bottom: 8 })
      }
    }
    .width('100%')
  }

  // 换人表单
  @Builder
  SubstitutionForm() {
    Column() {
      // 球队选择
      Text('换人球队')
        .fontSize(14)
        .margin({ bottom: 8 })
        .alignSelf(ItemAlign.Start)

      Row() {
        Button(this.currentMatch?.homeTeam.name || '主队')
          .width('45%')
          .height(35)
          .backgroundColor(this.subTeamId === this.currentMatch?.homeTeam.id ? $r('app.color.primary_color') : $r('app.color.text_disabled'))
          .fontColor(Color.White)
          .onClick(() => this.subTeamId = this.currentMatch?.homeTeam.id || '')

        Button(this.currentMatch?.awayTeam.name || '客队')
          .width('45%')
          .height(35)
          .backgroundColor(this.subTeamId === this.currentMatch?.awayTeam.id ? $r('app.color.primary_color') : $r('app.color.text_disabled'))
          .fontColor(Color.White)
          .onClick(() => this.subTeamId = this.currentMatch?.awayTeam.id || '')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 16 })

      this.FormInput('被换下球员姓名', '如: 张三', (value) => this.subPlayerOutName = value)
      this.FormInput('被换下球员号码', '如: 10', (value) => this.subPlayerOutNumber = value)
      this.FormInput('换上球员姓名', '如: 李四', (value) => this.subPlayerInName = value)
      this.FormInput('换上球员号码', '如: 15', (value) => this.subPlayerInNumber = value)
    }
    .width('100%')
  }

  // 红黄牌表单
  @Builder
  CardForm() {
    Column() {
      // 球队选择
      Text(this.eventType === MatchEventType.YELLOW_CARD ? '黄牌球队' : '红牌球队')
        .fontSize(14)
        .margin({ bottom: 8 })
        .alignSelf(ItemAlign.Start)

      Row() {
        Button(this.currentMatch?.homeTeam.name || '主队')
          .width('45%')
          .height(35)
          .backgroundColor(this.cardTeamId === this.currentMatch?.homeTeam.id ? $r('app.color.primary_color') : $r('app.color.text_disabled'))
          .fontColor(Color.White)
          .onClick(() => this.cardTeamId = this.currentMatch?.homeTeam.id || '')

        Button(this.currentMatch?.awayTeam.name || '客队')
          .width('45%')
          .height(35)
          .backgroundColor(this.cardTeamId === this.currentMatch?.awayTeam.id ? $r('app.color.primary_color') : $r('app.color.text_disabled'))
          .fontColor(Color.White)
          .onClick(() => this.cardTeamId = this.currentMatch?.awayTeam.id || '')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 16 })

      this.FormInput('球员姓名', '如: 张三', (value) => this.cardPlayerName = value)
      this.FormInput('球员号码', '如: 10', (value) => this.cardPlayerNumber = value)

      if (this.eventType === MatchEventType.RED_CARD) {
        Row() {
          Checkbox()
            .select(this.isSecondYellow)
            .onChange((checked) => this.isSecondYellow = checked)
          Text('两黄变一红')
            .fontSize(14)
        }
        .width('100%')
        .margin({ top: 8 })
      }
    }
    .width('100%')
  }

  // 罚丢点球/乌龙球表单
  @Builder
  PenaltyMissedOrOwnGoalForm() {
    Column() {
      // 球队选择
      Text(this.eventType === MatchEventType.PENALTY_MISSED ? '罚球队员所属球队' : '乌龙球球员所属球队')
        .fontSize(14)
        .margin({ bottom: 8 })
        .alignSelf(ItemAlign.Start)

      Row() {
        Button(this.currentMatch?.homeTeam.name || '主队')
          .width('45%')
          .height(35)
          .backgroundColor(this.goalTeamId === this.currentMatch?.homeTeam.id ? $r('app.color.primary_color') : $r('app.color.text_disabled'))
          .fontColor(Color.White)
          .onClick(() => {
            if (this.currentMatch) {
              this.goalTeamId = this.currentMatch.homeTeam.id;
            }
          })

        Button(this.currentMatch?.awayTeam.name || '客队')
          .width('45%')
          .height(35)
          .backgroundColor(this.goalTeamId === this.currentMatch?.awayTeam.id ? $r('app.color.primary_color') : $r('app.color.text_disabled'))
          .fontColor(Color.White)
          .onClick(() => {
            if (this.currentMatch) {
              this.goalTeamId = this.currentMatch.awayTeam.id;
            }
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 16 })

      this.FormInput('球员姓名', '如: 张三', (value) => this.goalScorerName = value)
      this.FormInput('球员号码', '如: 10', (value) => this.goalScorerNumber = value)
    }
    .width('100%')
  }

  // 保存事件
  saveEvent() {
    if (!this.currentMatch) return;

    if (this.eventType === MatchEventType.GOAL) {
      this.saveGoalEvent();
    } else if (this.eventType === MatchEventType.SUBSTITUTION) {
      this.saveSubstitutionEvent();
    } else if (this.eventType === MatchEventType.YELLOW_CARD || this.eventType === MatchEventType.RED_CARD) {
      this.saveCardEvent();
    } else if (this.eventType === MatchEventType.PENALTY_MISSED) {
      this.savePenaltyMissedEvent();
    } else if (this.eventType === MatchEventType.OWN_GOAL) {
      this.saveOwnGoalEvent();
    }
  }

  // 保存进球事件
  saveGoalEvent() {
    console.log('saveGoalEvent开始 - goalTeamId:', this.goalTeamId);
    console.log('saveGoalEvent开始 - goalScorerName:', this.goalScorerName);
    console.log('saveGoalEvent开始 - goalScorerNumber:', this.goalScorerNumber);
    
    if (!this.goalScorerName || !this.goalScorerNumber) {
      AlertDialog.show({ message: '请填写进球球员信息' });
      return;
    }

    if (!this.goalTeamId) {
      AlertDialog.show({ message: '请选择进球球队' });
      return;
    }

    let description = `${this.goalScorerNumber}号 ${this.goalScorerName}`;
    if (this.isPenaltyGoal) {
      description += '(P)'; // 点球标记
    }
    description += ' 进球';
    
    if (this.goalAssisterName && this.goalAssisterNumber) {
      description += ` (助攻: ${this.goalAssisterNumber}号 ${this.goalAssisterName})`;
    }

    // 处理点球大战时间
    let matchTime = this.eventMatchTime;
    if (matchTime.toUpperCase() === 'P') {
      // 自动分配点球大战序号
      const penaltyCount = this.currentMatch?.events.filter(e => 
        e.matchTime.toUpperCase().startsWith('P') &&
        (e.type === MatchEventType.GOAL || e.type === MatchEventType.PENALTY_MISSED)
      ).length || 0;
      matchTime = `P${penaltyCount + 1}`;
    }

    const event: GoalEvent = {
      id: generateId(),
      matchId: this.currentMatch!.id,
      type: MatchEventType.GOAL,
      timestamp: Date.now(),
      matchTime: matchTime,
      description: description,
      teamId: this.goalTeamId,
      scorerId: generateId(),
      scorerName: this.goalScorerName,
      scorerNumber: parseInt(this.goalScorerNumber),
      assistId: this.goalAssisterName ? generateId() : undefined,
      assistName: this.goalAssisterName || undefined,
      assistNumber: this.goalAssisterNumber ? parseInt(this.goalAssisterNumber) : undefined,
      isOwnGoal: false,
      isPenalty: this.isPenaltyGoal
    };

    console.log('创建的进球事件:', JSON.stringify({
      id: event.id,
      teamId: event.teamId,
      scorerName: event.scorerName,
      isOwnGoal: event.isOwnGoal,
      isPenalty: event.isPenalty
    }));

    this.dataManager.addMatchEvent(this.currentMatch!.id, event);
    this.showEventDialog = false;
    this.clearEventData();
    this.refreshCurrentMatch();
  }

  // 保存换人事件
  saveSubstitutionEvent() {
    if (!this.subPlayerOutName || !this.subPlayerOutNumber || !this.subPlayerInName || !this.subPlayerInNumber) {
      AlertDialog.show({ message: '请填写完整的换人信息' });
      return;
    }

    // 使用换行符分隔上场和下场球员,带颜色标记
    const description = `${this.subPlayerInNumber}号 ${this.subPlayerInName}[GREEN]↑[COLOR]\n${this.subPlayerOutNumber}号 ${this.subPlayerOutName}[RED]↓[COLOR]`;

    const event: SubstitutionEvent = {
      id: generateId(),
      matchId: this.currentMatch!.id,
      type: MatchEventType.SUBSTITUTION,
      timestamp: Date.now(),
      matchTime: this.eventMatchTime,
      description: description,
      teamId: this.subTeamId,
      playerOutId: generateId(),
      playerInId: generateId(),
      playerOutName: this.subPlayerOutName,
      playerInName: this.subPlayerInName,
      playerOutNumber: parseInt(this.subPlayerOutNumber),
      playerInNumber: parseInt(this.subPlayerInNumber)
    };

    this.dataManager.addMatchEvent(this.currentMatch!.id, event);
    this.showEventDialog = false;
    this.clearEventData();
    this.refreshCurrentMatch();
  }

  // 保存红黄牌事件
  saveCardEvent() {
    if (!this.cardPlayerName || !this.cardPlayerNumber) {
      AlertDialog.show({ message: '请填写球员信息' });
      return;
    }

    const description = `${this.cardPlayerNumber}号 ${this.cardPlayerName} ${this.eventType === MatchEventType.YELLOW_CARD ? '黄牌' : '红牌'}`;

    const event: CardEvent = {
      id: generateId(),
      matchId: this.currentMatch!.id,
      type: this.eventType as MatchEventType.YELLOW_CARD | MatchEventType.RED_CARD,
      timestamp: Date.now(),
      matchTime: this.eventMatchTime,
      description: description,
      teamId: this.cardTeamId,
      playerId: generateId(),
      playerName: this.cardPlayerName,
      playerNumber: parseInt(this.cardPlayerNumber),
      isSecondYellow: this.isSecondYellow
    };

    this.dataManager.addMatchEvent(this.currentMatch!.id, event);
    this.showEventDialog = false;
    this.clearEventData();
    this.refreshCurrentMatch();
  }

  // 保存罚丢点球事件
  savePenaltyMissedEvent() {
    if (!this.goalScorerName || !this.goalScorerNumber) {
      AlertDialog.show({ message: '请填写球员信息' });
      return;
    }

    if (!this.goalTeamId) {
      AlertDialog.show({ message: '请选择球队' });
      return;
    }

    // 根据时间判断是点球大战还是常规时间
    let description = '';
    if (this.eventMatchTime.toUpperCase().startsWith('P')) {
      // 点球大战
      description = `${this.goalScorerNumber}号 ${this.goalScorerName} 罚失`;
    } else {
      // 常规时间
      description = `${this.goalScorerNumber}号 ${this.goalScorerName} 罚失点球`;
    }

    // 处理点球大战时间
    let matchTime = this.eventMatchTime;
    if (matchTime.toUpperCase() === 'P') {
      // 自动分配点球大战序号
      const penaltyCount = this.currentMatch?.events.filter(e => 
        e.matchTime.toUpperCase().startsWith('P') &&
        (e.type === MatchEventType.GOAL || e.type === MatchEventType.PENALTY_MISSED)
      ).length || 0;
      matchTime = `P${penaltyCount + 1}`;
    }

    // 使用GoalEvent类型,包含teamId
    const event: GoalEvent = {
      id: generateId(),
      matchId: this.currentMatch!.id,
      type: MatchEventType.PENALTY_MISSED,
      timestamp: Date.now(),
      matchTime: matchTime,
      description: description,
      teamId: this.goalTeamId,
      scorerId: generateId(),
      scorerName: this.goalScorerName,
      scorerNumber: parseInt(this.goalScorerNumber),
      isOwnGoal: false,
      isPenalty: true
    };

    this.dataManager.addMatchEvent(this.currentMatch!.id, event);
    this.showEventDialog = false;
    this.clearEventData();
    this.refreshCurrentMatch();
  }

  // 保存乌龙球事件
  saveOwnGoalEvent() {
    if (!this.goalScorerName || !this.goalScorerNumber) {
      AlertDialog.show({ message: '请填写球员信息' });
      return;
    }

    if (!this.goalTeamId) {
      AlertDialog.show({ message: '请选择球队' });
      return;
    }

    const description = `${this.goalScorerNumber}号 ${this.goalScorerName} 乌龙球`;

    const event: GoalEvent = {
      id: generateId(),
      matchId: this.currentMatch!.id,
      type: MatchEventType.OWN_GOAL,
      timestamp: Date.now(),
      matchTime: this.eventMatchTime,
      description: description,
      teamId: this.goalTeamId,
      scorerId: generateId(),
      scorerName: this.goalScorerName,
      scorerNumber: parseInt(this.goalScorerNumber),
      isOwnGoal: true,
      isPenalty: false
    };

    this.dataManager.addMatchEvent(this.currentMatch!.id, event);
    this.showEventDialog = false;
    this.clearEventData();
    this.refreshCurrentMatch();
  }

  // 清空事件数据
  clearEventData() {
    this.eventMatchTime = "45'";
    this.goalTeamId = '';
    this.goalScorerName = '';
    this.goalScorerNumber = '';
    this.goalAssisterName = '';
    this.goalAssisterNumber = '';
    this.isPenaltyGoal = false;
    this.subTeamId = '';
    this.subPlayerOutName = '';
    this.subPlayerOutNumber = '';
    this.subPlayerInName = '';
    this.subPlayerInNumber = '';
    this.cardTeamId = '';
    this.cardPlayerName = '';
    this.cardPlayerNumber = '';
    this.isSecondYellow = false;
  }

  // 删除事件
  deleteEvent(eventId: string) {
    if (!this.currentMatch) {
      return;
    }

    AlertDialog.show({
      title: '确认删除',
      message: '确定要删除这个事件吗?',
      primaryButton: {
        value: '取消',
        action: () => {}
      },
      secondaryButton: {
        value: '确定',
        action: () => {
          // 从事件列表中删除
          const eventIndex = this.currentMatch!.events.findIndex(e => e.id === eventId);
          if (eventIndex !== -1) {
            const deletedEvent = this.currentMatch!.events[eventIndex];
            this.currentMatch!.events.splice(eventIndex, 1);

            // 如果删除的是进球事件,重新计算比分
            if (deletedEvent.type === MatchEventType.GOAL) {
              this.dataManager.updateMatch(this.currentMatch!.id, this.currentMatch!);
              // 重新计算比分
              let homeScore = 0;
              let awayScore = 0;
              this.currentMatch!.events.forEach(event => {
                if (event.type === MatchEventType.GOAL) {
                  const goalEvent = event as GoalEvent;
                  if (goalEvent.teamId === this.currentMatch!.homeTeam.id) {
                    homeScore++;
                  } else {
                    awayScore++;
                  }
                }
              });
              this.currentMatch!.homeScore = homeScore;
              this.currentMatch!.awayScore = awayScore;
            }

            // 保存数据
            this.dataManager.saveData();
            // 刷新UI
            this.refreshCurrentMatch();
          }
        }
      }
    });
  }

  // 导出比赛报告
  async exportMatchReport() {
    if (!this.currentMatch) {
      AlertDialog.show({ message: '没有当前比赛数据' });
      return;
    }

    try {
      // 生成文本格式的报告内容
      const reportContent = this.generateReportContent(this.currentMatch);
      
      // 获取context
      const context = getContext(this) as common.UIAbilityContext;
      const fileName = `${this.currentMatch.competition}_${this.currentMatch.date}_${this.currentMatch.homeTeam.name}_vs_${this.currentMatch.awayTeam.name}.txt`;
      const filesDir = context.filesDir;
      const filePath = `${filesDir}/${fileName}`;

      // 写入文件
      const file = fs.openSync(filePath, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY);
      const encoder = new util.TextEncoder();
      const contentBytes = encoder.encodeInto(reportContent);
      fs.writeSync(file.fd, contentBytes.buffer);
      fs.closeSync(file);

      AlertDialog.show({
        title: '导出成功',
        message: `比赛报告已保存到:\n${filePath}\n\n文件名: ${fileName}`
      });
    } catch (error) {
      console.error('导出报告失败:', error);
      AlertDialog.show({ message: '导出报告失败,请重试' });
    }
  }

  // 生成报告内容
  generateReportContent(match: FootballMatch): string {
    let content = '';
    
    content += '════════════════════════════════════════\n';
    content += `        足球比赛报告\n`;
    content += '════════════════════════════════════════\n\n';
    
    content += `赛事: ${match.competition}\n`;
    content += `日期: ${match.date}\n`;
    content += `时间: ${match.time}\n`;
    content += `场地: ${match.venue}\n`;
    content += `裁判: ${match.referee}\n\n`;
    
    content += '────────────────────────────────────────\n';
    content += `        比赛结果\n`;
    content += '────────────────────────────────────────\n';
    content += `${match.homeTeam.name}  ${match.homeScore}  -  ${match.awayScore}  ${match.awayTeam.name}\n\n`;
    
    if (match.events.length > 0) {
      content += '────────────────────────────────────────\n';
      content += `        比赛事件\n`;
      content += '────────────────────────────────────────\n';
      
      // 按时间排序事件
      const sortedEvents = match.events.slice().sort((a, b) => {
        return parseMatchTime(a.matchTime) - parseMatchTime(b.matchTime);
      });
      
      sortedEvents.forEach(event => {
        const icon = getEventIcon(event.type);
        const typeName = this.getEventTypeName(event.type);
        content += `\n[${event.matchTime}] ${icon} ${typeName}\n`;
        content += `  ${event.description}\n`;
      });
    }
    
    content += '\n════════════════════════════════════════\n';
    content += `报告生成时间: ${new Date().toLocaleString()}\n`;
    content += '════════════════════════════════════════\n';
    
    return content;
  }

  // 保存比赛到文件(存档格式)
  async saveMatchToFile() {
    if (!this.currentMatch) {
      AlertDialog.show({ message: '没有当前比赛数据' });
      return;
    }

    try {
      // 将比赛数据序列化为JSON
      const matchData = JSON.stringify(this.currentMatch, null, 2);
      
      // 获取context
      const context = getContext(this) as common.UIAbilityContext;
      const fileName = `${this.currentMatch.competition}_${this.currentMatch.date}_${this.currentMatch.homeTeam.name}_vs_${this.currentMatch.awayTeam.name}.fmatch`;
      const filesDir = context.filesDir;
      const filePath = `${filesDir}/${fileName}`;

      // 写入文件
      const file = fs.openSync(filePath, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY);
      fs.writeSync(file.fd, matchData);
      fs.closeSync(file);

      AlertDialog.show({
        title: '保存成功',
        message: `比赛存档已保存到:\n${filePath}\n\n文件格式: .fmatch\n可以使用文本编辑器查看或导入`
      });
    } catch (error) {
      console.error('保存比赛失败:', error);
      AlertDialog.show({ message: '保存比赛失败' });
    }
  }
}
