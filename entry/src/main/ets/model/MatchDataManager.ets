/**
 * 比赛数据管理器
 * 负责数据的存储、检索和管理
 */

import { FootballMatch, Team, Player, MatchEvent, MatchEventType, StartingLineupEvent, SubstitutionEvent, GoalEvent, CardEvent, AppData, generateId, PlayerPosition, MatchStatistics, PlayerMatchStats, TeamStatistics, MatchConfig } from './FootballMatchModel';
import { DataStorage } from './DataStorage';
import { FileStorage } from './FileStorage';
import common from '@ohos.app.ability.common';

export class MatchDataManager {
  private static instance: MatchDataManager;
  private appData: AppData = {
    matches: [],
    teams: [],
    players: []
  };
  private dataStorage: DataStorage = DataStorage.getInstance();
  private fileStorage: FileStorage = FileStorage.getInstance();
  private isInitialized: boolean = false;
  private useFileStorage: boolean = false; // 是否使用文件存储

  private constructor() {
    // 不在这里初始化数据,等待loadData调用
  }

  public static getInstance(): MatchDataManager {
    if (!MatchDataManager.instance) {
      MatchDataManager.instance = new MatchDataManager();
    }
    return MatchDataManager.instance;
  }

  // 初始化并加载数据
  public async init(context: common.UIAbilityContext): Promise<void> {
    if (this.isInitialized) {
      return;
    }

    await this.dataStorage.init(context);
    this.fileStorage.init(context);

    // 尝试加载已保存的数据
    const savedData = await this.dataStorage.loadData();
    if (savedData) {
      this.appData = savedData;
    } else {
      // 如果没有保存的数据,初始化示例数据
      this.initializeSampleData();
    }

    this.isInitialized = true;
  }

  // 切换存储方式
  public setUseFileStorage(useFile: boolean): void {
    this.useFileStorage = useFile;
  }

  // 设置自定义数据保存路径
  public setCustomDataPath(path: string): void {
    this.fileStorage.setCustomDataPath(path);
  }

  // 设置自定义导出路径
  public setCustomExportPath(path: string): void {
    this.fileStorage.setCustomExportPath(path);
  }

  // 获取当前数据保存路径
  public getDataPath(): string {
    return this.fileStorage.getDataPath();
  }

  // 获取当前导出路径
  public getExportPath(): string {
    return this.fileStorage.getExportPath();
  }

  // 保存数据到持久化存储
  public async saveData(): Promise<boolean> {
    if (this.useFileStorage) {
      return await this.fileStorage.saveData(this.appData);
    } else {
      return await this.dataStorage.saveData(this.appData);
    }
  }

  // 导出所有数据
  public async exportAllData(filename: string): Promise<string> {
    return await this.fileStorage.exportData(this.appData, filename);
  }

  // 导出单个比赛
  public async exportMatch(matchId: string, filename: string): Promise<string> {
    const match = this.getMatchById(matchId);
    if (!match) {
      throw new Error('比赛不存在');
    }
    return await this.fileStorage.exportMatch(match, filename);
  }

  // 使用文件选择器导出所有数据
  public async exportAllDataWithPicker(defaultFileName: string): Promise<string> {
    return await this.fileStorage.saveDataWithPicker(this.appData, defaultFileName);
  }

  // 使用文件选择器导出单个比赛
  public async exportMatchWithPicker(matchId: string, defaultFileName: string): Promise<string> {
    const match = this.getMatchById(matchId);
    if (!match) {
      throw new Error('比赛不存在');
    }
    return await this.fileStorage.exportMatchWithPicker(match, defaultFileName);
  }

  // 测试:直接保存到应用目录
  public async testSaveToAppDir(filename: string): Promise<string> {
    return await this.fileStorage.testSaveToAppDir(this.appData, filename);
  }

  // 导出为文本报告
  public async exportAsTextReport(matchId: string, defaultFileName: string): Promise<string> {
    const match = this.getMatchById(matchId);
    if (!match) {
      throw new Error('比赛不存在');
    }
    return await this.fileStorage.exportAsTextReport(match, defaultFileName);
  }

  // 导入数据
  public async importData(): Promise<boolean> {
    try {
      const data = await this.fileStorage.importDataWithPicker();
      if (data) {
        this.appData = data;
        await this.saveData();
        return true;
      }
      return false;
    } catch (error) {
      console.error('导入数据失败:', error);
      throw new Error('导入数据失败');
    }
  }

  // 初始化示例数据
  private initializeSampleData(): void {
    // 创建示例球队
    const homeTeam: Team = {
      id: generateId(),
      name: '主队',
      color: '#FF0000',
      logo: ''
    };

    const awayTeam: Team = {
      id: generateId(),
      name: '客队',
      color: '#0000FF',
      logo: ''
    };

    this.appData.teams.push(homeTeam, awayTeam);

    // 创建示例球员
    const homePlayers: Player[] = [
      { id: generateId(), teamId: homeTeam.id, name: '张三', number: 1, position: PlayerPosition.GOALKEEPER, isCaptain: false },
      { id: generateId(), teamId: homeTeam.id, name: '李四', number: 2, position: PlayerPosition.DEFENDER, isCaptain: true },
      { id: generateId(), teamId: homeTeam.id, name: '王五', number: 3, position: PlayerPosition.DEFENDER, isCaptain: false },
      { id: generateId(), teamId: homeTeam.id, name: '赵六', number: 4, position: PlayerPosition.MIDFIELDER, isCaptain: false },
      { id: generateId(), teamId: homeTeam.id, name: '钱七', number: 5, position: PlayerPosition.MIDFIELDER, isCaptain: false },
      { id: generateId(), teamId: homeTeam.id, name: '孙八', number: 6, position: PlayerPosition.FORWARD, isCaptain: false },
    ];

    const awayPlayers: Player[] = [
      { id: generateId(), teamId: awayTeam.id, name: '周九', number: 1, position: PlayerPosition.GOALKEEPER, isCaptain: false },
      { id: generateId(), teamId: awayTeam.id, name: '吴十', number: 2, position: PlayerPosition.DEFENDER, isCaptain: true },
      { id: generateId(), teamId: awayTeam.id, name: '郑十一', number: 3, position: PlayerPosition.DEFENDER, isCaptain: false },
      { id: generateId(), teamId: awayTeam.id, name: '王十二', number: 4, position: PlayerPosition.MIDFIELDER, isCaptain: false },
      { id: generateId(), teamId: awayTeam.id, name: '冯十三', number: 5, position: PlayerPosition.MIDFIELDER, isCaptain: false },
      { id: generateId(), teamId: awayTeam.id, name: '陈十四', number: 6, position: PlayerPosition.FORWARD, isCaptain: false },
    ];

    this.appData.players.push(...homePlayers, ...awayPlayers);

    // 创建示例比赛
    const defaultConfig: MatchConfig = {
      firstHalfDuration: 45,
      secondHalfDuration: 45,
      hasExtraTime: false,
      extraTimeDuration: 30,
      hasPenaltyShootout: false
    };

    const sampleMatch: FootballMatch = {
      id: generateId(),
      homeTeam,
      awayTeam,
      venue: '城市体育场',
      date: '2024-04-14',
      time: '15:00',
      competition: '友谊赛',
      referee: '裁判员',
      homeScore: 2,
      awayScore: 1,
      status: 'finished',
      events: [],
      config: defaultConfig
    };

    // 添加示例事件
    const startTime = Date.now();

    // 首发阵容事件
    const startingEvent: StartingLineupEvent = {
      id: generateId(),
      matchId: sampleMatch.id,
      type: MatchEventType.STARTING_LINEUP,
      timestamp: startTime,
      matchTime: "0'",
      description: '比赛开始',
      teamId: homeTeam.id,
      players: homePlayers.slice(0, 6) // 前6个球员作为首发
    };
    sampleMatch.events.push(startingEvent);

    // 进球事件
    const goalEvent: GoalEvent = {
      id: generateId(),
      matchId: sampleMatch.id,
      type: MatchEventType.GOAL,
      timestamp: startTime + 1800000, // 30分钟后
      matchTime: "30'",
      description: '进球！',
      teamId: homeTeam.id,
      scorerId: homePlayers[5].id,
      scorerName: homePlayers[5].name,
      scorerNumber: homePlayers[5].number,
      assistId: homePlayers[3].id,
      assistName: homePlayers[3].name,
      assistNumber: homePlayers[3].number,
      isOwnGoal: false,
      isPenalty: false
    };
    sampleMatch.events.push(goalEvent);

    // 黄牌事件
    const yellowCardEvent: CardEvent = {
      id: generateId(),
      matchId: sampleMatch.id,
      type: MatchEventType.YELLOW_CARD,
      timestamp: startTime + 2400000, // 40分钟后
      matchTime: "40'",
      description: '黄牌警告',
      teamId: awayTeam.id,
      playerId: awayPlayers[2].id,
      playerName: awayPlayers[2].name,
      playerNumber: awayPlayers[2].number,
      isSecondYellow: false
    };
    sampleMatch.events.push(yellowCardEvent);

    // 换人事件
    const substitutionEvent: SubstitutionEvent = {
      id: generateId(),
      matchId: sampleMatch.id,
      type: MatchEventType.SUBSTITUTION,
      timestamp: startTime + 3000000, // 50分钟后
      matchTime: "50'",
      description: '换人调整',
      teamId: homeTeam.id,
      playerOutId: homePlayers[4].id,
      playerInId: generateId(),
      playerOutName: homePlayers[4].name,
      playerInName: '替补球员',
      playerOutNumber: homePlayers[4].number,
      playerInNumber: 7
    };
    sampleMatch.events.push(substitutionEvent);

    this.appData.matches.push(sampleMatch);
  }

  // 获取所有比赛
  public getMatches(): FootballMatch[] {
    return this.appData.matches;
  }

  // 根据ID获取比赛
  public getMatchById(matchId: string): FootballMatch | undefined {
    return this.appData.matches.find(match => match.id === matchId);
  }

  // 创建新比赛
  public createMatch(matchData: FootballMatch): FootballMatch {
    const defaultConfig: MatchConfig = {
      firstHalfDuration: 45,
      secondHalfDuration: 45,
      hasExtraTime: false,
      extraTimeDuration: 30,
      hasPenaltyShootout: false
    };

    const newMatch: FootballMatch = {
      id: generateId(),
      homeTeam: matchData.homeTeam,
      awayTeam: matchData.awayTeam,
      venue: matchData.venue,
      date: matchData.date,
      time: matchData.time,
      competition: matchData.competition,
      referee: matchData.referee,
      homeScore: matchData.homeScore,
      awayScore: matchData.awayScore,
      status: matchData.status,
      events: [],
      config: matchData.config || defaultConfig
    };

    this.appData.matches.push(newMatch);
    // 自动保存
    this.saveData();
    return newMatch;
  }

  // 更新比赛
  public updateMatch(matchId: string, updates: FootballMatch): boolean {
    const matchIndex = this.appData.matches.findIndex(match => match.id === matchId);
    if (matchIndex === -1) return false;

    this.appData.matches[matchIndex] = updates;

    return true;
  }

  // 删除比赛
  public deleteMatch(matchId: string): boolean {
    const matchIndex = this.appData.matches.findIndex(match => match.id === matchId);
    if (matchIndex === -1) return false;

    this.appData.matches.splice(matchIndex, 1);
    // 自动保存
    this.saveData();
    return true;
  }

  // 添加比赛事件
  public addMatchEvent(matchId: string, event: MatchEvent): MatchEvent | null {
    const match = this.getMatchById(matchId);
    if (!match) return null;

    // 直接使用传入的事件对象,不要创建新对象
    match.events.push(event);

    console.log('添加事件到比赛 - 事件类型:', event.type);
    if (event.type === MatchEventType.GOAL) {
      const goalEvent = event as GoalEvent;
      console.log('进球事件详情 - teamId:', goalEvent.teamId, 'scorerName:', goalEvent.scorerName);
    }

    // 如果是进球事件,更新比分
    if (event.type === MatchEventType.GOAL) {
      this.updateScore(match);
    }

    // 自动保存
    this.saveData();
    return event;
  }

  // 更新比分
  private updateScore(match: FootballMatch): void {
    let homeScore = 0;
    let awayScore = 0;
    let homePenaltyScore = 0;
    let awayPenaltyScore = 0;

    console.log('更新比分 - 主队ID:', match.homeTeam.id, '客队ID:', match.awayTeam.id);

    match.events.forEach(event => {
      const isPenaltyTime = event.matchTime.toUpperCase().startsWith('P');
      
      if (event.type === MatchEventType.GOAL) {
        const goalEvent = event as GoalEvent;
        console.log('进球事件 - teamId:', goalEvent.teamId, 'isOwnGoal:', goalEvent.isOwnGoal, 'isPenaltyTime:', isPenaltyTime);
        
        if (isPenaltyTime) {
          // 点球大战进球
          if (goalEvent.teamId === match.homeTeam.id) {
            console.log('点球大战主队进球');
            homePenaltyScore++;
          } else {
            console.log('点球大战客队进球');
            awayPenaltyScore++;
          }
        } else {
          // 常规时间进球
          if (goalEvent.isOwnGoal) {
            // 乌龙球,计入对方球队
            if (goalEvent.teamId === match.homeTeam.id) {
              console.log('主队乌龙球,客队得分');
              awayScore++;
            } else {
              console.log('客队乌龙球,主队得分');
              homeScore++;
            }
          } else {
            // 正常进球
            if (goalEvent.teamId === match.homeTeam.id) {
              console.log('主队进球');
              homeScore++;
            } else {
              console.log('客队进球');
              awayScore++;
            }
          }
        }
      }
    });

    console.log('最终比分 - 主队:', homeScore, '客队:', awayScore);
    console.log('点球大战比分 - 主队:', homePenaltyScore, '客队:', awayPenaltyScore);
    match.homeScore = homeScore;
    match.awayScore = awayScore;
    match.homePenaltyScore = homePenaltyScore;
    match.awayPenaltyScore = awayPenaltyScore;
  }

  // 获取比赛事件（按时间排序）
  public getMatchEvents(matchId: string): MatchEvent[] {
    const match = this.getMatchById(matchId);
    if (!match) return [];
    
    return match.events.sort((a, b) => a.timestamp - b.timestamp);
  }

  // 获取球队
  public getTeams(): Team[] {
    return this.appData.teams;
  }

  // 获取球员
  public getPlayers(): Player[] {
    return this.appData.players;
  }

  // 根据球队获取球员
  public getPlayersByTeam(teamId: string): Player[] {
    return this.appData.players.filter(player => player.teamId === teamId);
  }

  // 添加球员
  public addPlayer(player: Player): Player {
    const newPlayer: Player = {
      id: generateId(),
      teamId: player.teamId,
      name: player.name,
      number: player.number,
      position: player.position,
      isCaptain: player.isCaptain
    };

    this.appData.players.push(newPlayer);
    return newPlayer;
  }

  // 获取比赛统计数据
  public getMatchStatistics(matchId: string): MatchStatistics | null {
    const match = this.getMatchById(matchId);
    if (!match) return null;

    const events = match.events;

    // 计算统计数据
    const homeTeamStats: TeamStatistics = {
      goals: 0,
      yellowCards: 0,
      redCards: 0,
      substitutions: 0,
      shots: 0,
      shotsOnTarget: 0,
      possession: 0,
      corners: 0,
      fouls: 0,
      offsides: 0
    };

    const awayTeamStats: TeamStatistics = {
      goals: 0,
      yellowCards: 0,
      redCards: 0,
      substitutions: 0,
      shots: 0,
      shotsOnTarget: 0,
      possession: 0,
      corners: 0,
      fouls: 0,
      offsides: 0
    };

    const stats: MatchStatistics = {
      homeTeam: homeTeamStats,
      awayTeam: awayTeamStats
    };

    events.forEach(event => {
      if (event.type === MatchEventType.GOAL) {
        const goalEvent = event as GoalEvent;
        if (goalEvent.teamId === match.homeTeam.id) {
          stats.homeTeam.goals++;
        } else {
          stats.awayTeam.goals++;
        }
      } else if (event.type === MatchEventType.YELLOW_CARD) {
        const cardEvent = event as CardEvent;
        if (cardEvent.teamId === match.homeTeam.id) {
          stats.homeTeam.yellowCards++;
        } else {
          stats.awayTeam.yellowCards++;
        }
      } else if (event.type === MatchEventType.RED_CARD) {
        const cardEvent = event as CardEvent;
        if (cardEvent.teamId === match.homeTeam.id) {
          stats.homeTeam.redCards++;
        } else {
          stats.awayTeam.redCards++;
        }
      } else if (event.type === MatchEventType.SUBSTITUTION) {
        const subEvent = event as SubstitutionEvent;
        if (subEvent.teamId === match.homeTeam.id) {
          stats.homeTeam.substitutions++;
        } else {
          stats.awayTeam.substitutions++;
        }
      }
    });

    return stats;
  }

  // 获取球员统计数据
  public getPlayerStats(matchId: string, playerId: string): PlayerMatchStats | null {
    const match = this.getMatchById(matchId);
    if (!match) return null;

    const events = match.events;
    const stats: PlayerMatchStats = {
      playerId: playerId,
      minutesPlayed: 0,
      goals: 0,
      assists: 0,
      yellowCards: 0,
      redCards: 0,
      shots: 0,
      shotsOnTarget: 0,
      passes: 0,
      passAccuracy: 0,
      tackles: 0,
      interceptions: 0
    };

    events.forEach(event => {
      if (event.type === MatchEventType.GOAL) {
        const goalEvent = event as GoalEvent;
        if (goalEvent.scorerId === playerId) {
          stats.goals++;
        }
        if (goalEvent.assistId === playerId) {
          stats.assists++;
        }
      } else if (event.type === MatchEventType.YELLOW_CARD) {
        const cardEvent = event as CardEvent;
        if (cardEvent.playerId === playerId) {
          stats.yellowCards++;
        }
      } else if (event.type === MatchEventType.RED_CARD) {
        const cardEvent = event as CardEvent;
        if (cardEvent.playerId === playerId) {
          stats.redCards++;
        }
      }
    });

    return stats;
  }

  // 导出数据（用于持久化存储）
  public exportData(): string {
    return JSON.stringify(this.appData, null, 2);
  }
}