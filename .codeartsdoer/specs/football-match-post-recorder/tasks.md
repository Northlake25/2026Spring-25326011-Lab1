# 任务清单文档 - 足球比赛赛后记录工具(精简版)

## 文档信息

- **项目名称**:足球比赛赛后记录工具 (Football Match Post-Game Recorder)
- **特性名称**:football-match-post-recorder
- **版本号**:v1.0
- **创建日期**:2024-04-14
- **最后更新**:2024-04-14
- **关联需求文档**:spec.md v1.0
- **关联设计文档**:design.md v1.0

## 任务概览

| 统计项 | 数量 |
|--------|------|
| 主任务数 | 3 |
| 子任务数 | 0 |
| 总任务数 | 3 |
| 预计工时 | 6小时 |

## 任务依赖关系

```
任务1(完善数据模型) ──> 任务2(实现核心功能) ──> 任务3(测试验证)
```

## 任务清单

### 任务 1: 完善数据模型

**优先级**:P0
**预估工时**:1小时
**关联需求**:REQ-MAT-001, REQ-EVT-001
**任务描述**:
优化现有的FootballMatchModel.ets和MatchDataManager.ets,移除实时比赛相关代码,简化数据结构。

**输入**:
- 现有FootballMatchModel.ets
- 现有MatchDataManager.ets

**输出**:
- 简化后的数据模型
- 优化后的数据管理器

**验收标准**:
- 移除startTime、endTime等实时字段
- 比赛状态默认为FINISHED
- 保留所有事件类型定义
- MatchDataManager可以正常创建和管理比赛

**技术要点**:
- 直接修改现有文件,不创建新文件
- 保持数据结构简单
- 确保类型安全

**实现步骤**:
1. 打开FootballMatchModel.ets,移除startTime、endTime字段
2. 简化MatchStatus枚举,只保留FINISHED
3. 打开MatchDataManager.ets,移除getCurrentMatch等方法
4. 确保createMatch方法正常工作

### 任务 2: 实现核心功能

**优先级**:P0
**预估工时**:4小时
**关联需求**:REQ-MAT-001, REQ-LIN-001, REQ-EVT-001, REQ-EVT-002, REQ-EVT-004, REQ-EVT-005
**任务描述**:
在现有Index.ets基础上,实现完整的比赛记录功能,包括创建比赛、设置首发、记录事件、查看时间线。

**输入**:
- 现有Index.ets
- 优化后的数据模型

**输出**:
- 完整功能的比赛记录应用

**验收标准**:
- 可以创建比赛(输入主客队、日期、场地等)
- 可以设置首发阵容(选择11人)
- 可以记录换人事件(选择球员、输入时间)
- 可以记录进球事件(选择球员、助攻、输入时间)
- 可以记录红黄牌事件(选择球员、输入时间)
- 事件按时间顺序显示在时间线上
- 比分根据进球自动更新

**技术要点**:
- 在现有Index.ets基础上扩展,不重写
- 使用AlertDialog实现事件记录对话框
- 使用简单的表单输入,不追求完美UI
- 优先实现功能,UI可以简单

**实现步骤**:

#### 步骤1: 完善新建比赛功能(30分钟)
```typescript
// 在NewMatchPage中,为每个输入框添加状态变量
@State homeTeamName: string = '';
@State awayTeamName: string = '';
@State venue: string = '';
@State date: string = '';
@State time: string = '';
@State competition: string = '';
@State referee: string = '';

// 修改FormInput,添加onChange回调
@Builder
FormInput(label: string, placeholder: string, onChange: (value: string) => void) {
  Column() {
    Text(label)
    TextInput({ placeholder: placeholder })
      .onChange((value) => onChange(value))
  }
}

// 实现创建比赛逻辑
createMatch() {
  const match = MatchDataManager.getInstance().createMatch({
    homeTeam: { id: generateId(), name: this.homeTeamName, color: '#FF0000' },
    awayTeam: { id: generateId(), name: this.awayTeamName, color: '#0000FF' },
    venue: this.venue,
    date: this.date,
    time: this.time,
    competition: this.competition,
    referee: this.referee,
    homeScore: 0,
    awayScore: 0,
    status: 'finished'
  });
  this.currentMatchId = match.id;
  this.currentPage = 'matchDetail';
}
```

#### 步骤2: 实现首发阵容设置(1小时)
```typescript
// 添加首发阵容设置对话框
@State showLineupDialog: boolean = false;
@State lineupTeamId: string = '';
@State selectedPlayers: Player[] = [];

@Builder
LineupDialog() {
  if (this.showLineupDialog) {
    Column() {
      Text('设置首发阵容')
      Text(`已选择 ${this.selectedPlayers.length}/11 人`)

      List() {
        ForEach(this.getTeamPlayers(this.lineupTeamId), (player: Player) => {
          ListItem() {
            Row() {
              Text(`${player.number} ${player.name}`)
              Checkbox()
                .select(this.selectedPlayers.includes(player))
                .onChange((checked) => {
                  if (checked && this.selectedPlayers.length < 11) {
                    this.selectedPlayers.push(player);
                  } else {
                    this.selectedPlayers = this.selectedPlayers.filter(p => p.id !== player.id);
                  }
                })
            }
          }
        })
      }

      Row() {
        Button('取消').onClick(() => this.showLineupDialog = false)
        Button('确认').onClick(() => this.saveLineup())
      }
    }
  }
}

saveLineup() {
  if (this.selectedPlayers.length !== 11) {
    AlertDialog.show({ message: '首发阵容必须为11人' });
    return;
  }

  // 创建首发阵容事件
  const event = {
    type: MatchEventType.STARTING_LINEUP,
    timestamp: Date.now(),
    matchTime: "0'",
    description: '首发阵容',
    teamId: this.lineupTeamId,
    players: this.selectedPlayers
  };

  MatchDataManager.getInstance().addMatchEvent(this.currentMatchId, event);
  this.showLineupDialog = false;
  this.refreshMatch();
}
```

#### 步骤3: 实现事件记录功能(2小时)
```typescript
// 添加事件记录对话框
@State showEventDialog: boolean = false;
@State eventType: MatchEventType = MatchEventType.GOAL;
@State eventMatchTime: string = "45'";

@Builder
EventDialog() {
  if (this.showEventDialog) {
    Column() {
      Text('记录事件')

      // 事件类型选择
      Row() {
        Button('进球').onClick(() => this.eventType = MatchEventType.GOAL)
        Button('换人').onClick(() => this.eventType = MatchEventType.SUBSTITUTION)
        Button('黄牌').onClick(() => this.eventType = MatchEventType.YELLOW_CARD)
        Button('红牌').onClick(() => this.eventType = MatchEventType.RED_CARD)
      }

      // 比赛时间输入
      TextInput({ placeholder: "比赛时间(如45')" })
        .onChange((value) => this.eventMatchTime = value)

      // 根据事件类型显示不同表单
      if (this.eventType === MatchEventType.GOAL) {
        this.GoalForm()
      } else if (this.eventType === MatchEventType.SUBSTITUTION) {
        this.SubstitutionForm()
      } else {
        this.CardForm()
      }

      Row() {
        Button('取消').onClick(() => this.showEventDialog = false)
        Button('确认').onClick(() => this.saveEvent())
      }
    }
  }
}

// 进球表单
@State goalTeamId: string = '';
@State goalScorerId: string = '';
@State goalAssisterId: string = '';

@Builder
GoalForm() {
  Column() {
    // 球队选择
    Row() {
      Button('主队').onClick(() => this.goalTeamId = this.currentMatch.homeTeam.id)
      Button('客队').onClick(() => this.goalTeamId = this.currentMatch.awayTeam.id)
    }

    // 进球球员选择
    Text('进球球员')
    List() {
      ForEach(this.getTeamPlayers(this.goalTeamId), (player: Player) => {
        ListItem() {
          Button(`${player.number} ${player.name}`)
            .onClick(() => this.goalScorerId = player.id)
        }
      })
    }.height(100)

    // 助攻球员选择(可选)
    Text('助攻球员(可选)')
    List() {
      ForEach(this.getTeamPlayers(this.goalTeamId), (player: Player) => {
        ListItem() {
          Button(`${player.number} ${player.name}`)
            .onClick(() => this.goalAssisterId = player.id)
        }
      })
    }.height(100)
  }
}

// 保存进球事件
saveGoalEvent() {
  const scorer = this.getPlayerById(this.goalScorerId);
  const assister = this.goalAssisterId ? this.getPlayerById(this.goalAssisterId) : null;

  let description = `${scorer.number}号 ${scorer.name} 进球`;
  if (assister) {
    description += ` (助攻: ${assister.number}号 ${assister.name})`;
  }

  const event = {
    type: MatchEventType.GOAL,
    timestamp: Date.now(),
    matchTime: this.eventMatchTime,
    description: description,
    teamId: this.goalTeamId,
    scorerId: this.goalScorerId,
    scorerName: scorer.name,
    scorerNumber: scorer.number,
    assistId: this.goalAssisterId,
    assistName: assister?.name,
    assistNumber: assister?.number,
    isOwnGoal: false,
    isPenalty: false
  };

  MatchDataManager.getInstance().addMatchEvent(this.currentMatchId, event);
  this.showEventDialog = false;
  this.refreshMatch();
}
```

#### 步骤4: 完善比赛详情页(30分钟)
```typescript
// 在MatchDetailPage中,从MatchDataManager加载比赛数据
@State currentMatch: FootballMatch | null = null;

aboutToAppear() {
  if (this.currentMatchId) {
    this.currentMatch = MatchDataManager.getInstance().getMatchById(this.currentMatchId);
  }
}

refreshMatch() {
  this.currentMatch = MatchDataManager.getInstance().getMatchById(this.currentMatchId);
}

// 事件时间线按时间排序
getSortedEvents(): MatchEvent[] {
  if (!this.currentMatch) return [];
  return this.currentMatch.events.sort((a, b) => {
    // 简单的时间比较,假设格式为"45'"或"45+2'"
    const timeA = parseInt(a.matchTime.replace("'", "").replace(/\+\d+/, ""));
    const timeB = parseInt(b.matchTime.replace("'", "").replace(/\+\d+/, ""));
    return timeA - timeB;
  });
}
```

### 任务 3: 测试验证

**优先级**:P0
**预估工时**:1小时
**关联需求**:所有需求
**任务描述**:
测试核心功能,确保可以正常记录比赛进程。

**输入**:
- 完整的应用代码

**输出**:
- 测试报告

**验收标准**:
- 可以创建比赛
- 可以设置首发阵容
- 可以记录进球、换人、红黄牌
- 事件时间线正确显示
- 比分自动更新

**实现步骤**:
1. 创建一场测试比赛
2. 设置主客队首发阵容
3. 记录几个进球事件,验证比分更新
4. 记录换人事件
5. 记录红黄牌事件
6. 查看事件时间线,验证排序正确

## 任务执行顺序

### 第1小时:数据模型优化
- 任务1:完善数据模型

### 第2-5小时:核心功能实现
- 任务2:实现核心功能
  - 步骤1:完善新建比赛功能(30分钟)
  - 步骤2:实现首发阵容设置(1小时)
  - 步骤3:实现事件记录功能(2小时)
  - 步骤4:完善比赛详情页(30分钟)

### 第6小时:测试验证
- 任务3:测试验证

## 风险与注意事项

| 风险项 | 影响任务 | 应对措施 |
|--------|----------|----------|
| 现有代码结构复杂 | 任务2 | 直接在现有基础上扩展,不重写 |
| UI不够美观 | 任务2 | 优先实现功能,UI可以简单 |
| 数据验证不完善 | 任务2 | 添加基本的必填验证即可 |

## 测试检查点

### 功能测试
- [ ] 创建比赛功能正常
- [ ] 设置首发阵容功能正常
- [ ] 记录进球事件功能正常
- [ ] 记录换人事件功能正常
- [ ] 记录红黄牌功能正常
- [ ] 事件时间线显示正常
- [ ] 比分自动更新正确

## 附录

### 变更历史
| 版本 | 日期 | 变更内容 | 作者 |
|------|------|----------|------|
| v1.0 | 2024-04-14 | 精简版本 | SDD Agent |
