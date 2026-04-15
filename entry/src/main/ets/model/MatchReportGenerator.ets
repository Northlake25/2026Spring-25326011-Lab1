import { FootballMatch, MatchEvent, MatchEventType, GoalEvent, SubstitutionEvent, CardEvent, parseMatchTime } from './FootballMatchModel';
import fs from '@ohos.file.fs';
import common from '@ohos.app.ability.common';

interface Stats {
  goals: number;
  yellowCards: number;
  redCards: number;
}

interface StatsResult {
  home: Stats;
  away: Stats;
}

export class MatchReportGenerator {
  // 生成比赛报告文本
  public static generateMatchReport(match: FootballMatch): string {
    let report = '';

    // 标题
    report += '════════════════════════════════════════\n';
    report += `        ${match.competition}\n`;
    report += '════════════════════════════════════════\n\n';

    // 比赛信息
    report += '【比赛信息】\n';
    report += `对阵: ${match.homeTeam.name} vs ${match.awayTeam.name}\n`;
    report += `比分: ${match.homeScore} - ${match.awayScore}\n`;
    report += `日期: ${match.date} ${match.time}\n`;
    report += `场地: ${match.venue}\n`;
    report += `裁判: ${match.referee}\n\n`;

    // 比赛配置
    report += '【比赛配置】\n';
    report += `上半场: ${match.config.firstHalfDuration}分钟\n`;
    report += `下半场: ${match.config.secondHalfDuration}分钟\n`;
    if (match.config.hasExtraTime) {
      report += `加时赛: ${match.config.extraTimeDuration}分钟\n`;
    }
    if (match.config.hasPenaltyShootout) {
      report += '点球大战: 有\n';
    }
    report += '\n';

    // 事件时间线
    report += '【比赛事件时间线】\n';
    report += '────────────────────────────────────────\n';

    const sortedEvents = match.events.sort((a, b) => {
      return parseMatchTime(a.matchTime) - parseMatchTime(b.matchTime);
    });

    sortedEvents.forEach(event => {
      report += MatchReportGenerator.formatEvent(event, match);
    });

    report += '────────────────────────────────────────\n\n';

    // 统计数据
    report += '【比赛统计】\n';
    const stats = MatchReportGenerator.calculateStats(match);
    report += `${match.homeTeam.name}: 进球${stats.home.goals} 黄牌${stats.home.yellowCards} 红牌${stats.home.redCards}\n`;
    report += `${match.awayTeam.name}: 进球${stats.away.goals} 黄牌${stats.away.yellowCards} 红牌${stats.away.redCards}\n\n`;

    report += '════════════════════════════════════════\n';
    report += `生成时间: ${new Date().toLocaleString()}\n`;
    report += '════════════════════════════════════════\n';

    return report;
  }

  // 格式化单个事件
  private static formatEvent(event: MatchEvent, match: FootballMatch): string {
    let line = `${event.matchTime} `;

    // 判断事件所属球队
    let teamName = '';
    if (event.type === MatchEventType.GOAL) {
      const goalEvent = event as GoalEvent;
      teamName = goalEvent.teamId === match.homeTeam.id ? match.homeTeam.name : match.awayTeam.name;
    } else if (event.type === MatchEventType.SUBSTITUTION) {
      const subEvent = event as SubstitutionEvent;
      teamName = subEvent.teamId === match.homeTeam.id ? match.homeTeam.name : match.awayTeam.name;
    } else if (event.type === MatchEventType.YELLOW_CARD || event.type === MatchEventType.RED_CARD) {
      const cardEvent = event as CardEvent;
      teamName = cardEvent.teamId === match.homeTeam.id ? match.homeTeam.name : match.awayTeam.name;
    }

    if (teamName) {
      line += `[${teamName}] `;
    }

    line += `${event.description}\n`;

    return line;
  }

  // 计算统计数据
  private static calculateStats(match: FootballMatch): StatsResult {
    const homeStats: Stats = { goals: 0, yellowCards: 0, redCards: 0 };
    const awayStats: Stats = { goals: 0, yellowCards: 0, redCards: 0 };

    match.events.forEach(event => {
      if (event.type === MatchEventType.GOAL) {
        const goalEvent = event as GoalEvent;
        if (goalEvent.teamId === match.homeTeam.id) {
          homeStats.goals++;
        } else {
          awayStats.goals++;
        }
      } else if (event.type === MatchEventType.YELLOW_CARD) {
        const cardEvent = event as CardEvent;
        if (cardEvent.teamId === match.homeTeam.id) {
          homeStats.yellowCards++;
        } else {
          awayStats.yellowCards++;
        }
      } else if (event.type === MatchEventType.RED_CARD) {
        const cardEvent = event as CardEvent;
        if (cardEvent.teamId === match.homeTeam.id) {
          homeStats.redCards++;
        } else {
          awayStats.redCards++;
        }
      }
    });

    const result: StatsResult = {
      home: homeStats,
      away: awayStats
    };

    return result;
  }

  // 保存报告到文件
  public static async saveReportToFile(
    context: common.UIAbilityContext,
    match: FootballMatch
  ): Promise<string> {
    const report = MatchReportGenerator.generateMatchReport(match);
    const fileName = `${match.competition}_${match.date}_${match.homeTeam.name}_vs_${match.awayTeam.name}.txt`;

    try {
      // 获取应用文件目录
      const filesDir = context.filesDir;
      const filePath = `${filesDir}/${fileName}`;

      // 写入文件
      const file = fs.openSync(filePath, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY);
      fs.writeSync(file.fd, report);
      fs.closeSync(file);

      return filePath;
    } catch (error) {
      console.error('保存报告失败:', error);
      const err = new Error('保存报告失败');
      throw err;
    }
  }
}
