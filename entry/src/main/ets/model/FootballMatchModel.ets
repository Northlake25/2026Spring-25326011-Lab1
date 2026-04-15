/**
 * 足球比赛数据模型
 * 包含球员、比赛、事件等核心数据结构
 */

// 球员位置枚举
export enum PlayerPosition {
  GOALKEEPER = '守门员',
  DEFENDER = '后卫',
  MIDFIELDER = '中场',
  FORWARD = '前锋'
}

// 球队信息
export interface Team {
  id: string;
  name: string;
  color: string; // 球队颜色，用于UI显示
  logo?: string; // 球队logo路径
}

// 球员信息
export interface Player {
  id: string;
  teamId: string;
  name: string;
  number: number; // 球衣号码
  position: PlayerPosition;
  isCaptain: boolean; // 是否是队长
}

// 比赛事件类型
export enum MatchEventType {
  STARTING_LINEUP = 'starting_lineup', // 首发阵容
  SUBSTITUTION = 'substitution',       // 换人
  GOAL = 'goal',                      // 进球
  ASSIST = 'assist',                  // 助攻
  YELLOW_CARD = 'yellow_card',        // 黄牌
  RED_CARD = 'red_card',              // 红牌
  HALF_TIME = 'half_time',            // 中场休息
  FULL_TIME = 'full_time',            // 比赛结束
  INJURY = 'injury',                  // 受伤
  PENALTY_SHOOTOUT = 'penalty_shootout', // 点球大战进球
  PENALTY_MISSED = 'penalty_missed',  // 罚丢点球
  OWN_GOAL = 'own_goal',              // 乌龙球
  EXTRA_TIME_START = 'extra_time_start', // 加时赛开始
  PENALTY_SHOOTOUT_START = 'penalty_shootout_start', // 点球大战开始
  OTHER = 'other'                     // 其他事件
}

// 比赛事件基类
export interface MatchEvent {
  id: string;
  matchId: string;
  type: MatchEventType;
  timestamp: number; // 事件发生时间（毫秒时间戳）
  matchTime: string; // 比赛时间，格式如 "45+2'" 或 "90'"
  description: string; // 事件描述
}

// 首发阵容事件
export interface StartingLineupEvent extends MatchEvent {
  type: MatchEventType.STARTING_LINEUP;
  teamId: string;
  players: Player[]; // 首发球员列表
}

// 换人事件
export interface SubstitutionEvent extends MatchEvent {
  type: MatchEventType.SUBSTITUTION;
  teamId: string;
  playerOutId: string; // 被换下球员ID
  playerInId: string;  // 换上球员ID
  playerOutName: string;
  playerInName: string;
  playerOutNumber: number;
  playerInNumber: number;
}

// 进球事件
export interface GoalEvent extends MatchEvent {
  type: MatchEventType.GOAL | MatchEventType.OWN_GOAL | MatchEventType.PENALTY_MISSED;
  teamId: string;
  scorerId: string;    // 进球球员ID
  scorerName: string;
  scorerNumber: number;
  assistId?: string;   // 助攻球员ID（可选）
  assistName?: string;
  assistNumber?: number;
  isOwnGoal: boolean;  // 是否乌龙球
  isPenalty: boolean;  // 是否点球
}

// 助攻事件
export interface AssistEvent extends MatchEvent {
  type: MatchEventType.ASSIST;
  teamId: string;
  playerId: string;
  playerName: string;
  playerNumber: number;
  goalEventId: string; // 关联的进球事件ID
}

// 红黄牌事件
export interface CardEvent extends MatchEvent {
  type: MatchEventType.YELLOW_CARD | MatchEventType.RED_CARD;
  teamId: string;
  playerId: string;
  playerName: string;
  playerNumber: number;
  isSecondYellow: boolean; // 是否第二张黄牌
}

// 比赛配置
export interface MatchConfig {
  firstHalfDuration: number;  // 上半场时长(分钟),默认45
  secondHalfDuration: number; // 下半场时长(分钟),默认45
  hasExtraTime: boolean;      // 是否有加时赛
  extraTimeDuration: number;  // 加时赛时长(分钟),默认30
  hasPenaltyShootout: boolean; // 是否有点球大战
}

// 比赛信息
export interface FootballMatch {
  id: string;
  homeTeam: Team;
  awayTeam: Team;
  venue: string; // 比赛场地
  date: string;  // 比赛日期
  time: string;  // 比赛时间
  competition: string; // 赛事名称
  referee: string; // 裁判
  homeScore: number;
  awayScore: number;
  homePenaltyScore?: number; // 点球大战主队得分
  awayPenaltyScore?: number; // 点球大战客队得分
  status: 'scheduled' | 'finished' | 'cancelled'; // 简化状态,默认为finished
  events: MatchEvent[]; // 比赛事件列表
  config: MatchConfig; // 比赛配置
}

// 球队统计数据
export interface TeamStatistics {
  goals: number;
  yellowCards: number;
  redCards: number;
  substitutions: number;
  shots: number;
  shotsOnTarget: number;
  possession: number; // 控球率百分比
  corners: number;
  fouls: number;
  offsides: number;
}

// 比赛统计数据
export interface MatchStatistics {
  homeTeam: TeamStatistics;
  awayTeam: TeamStatistics;
}

// 球员比赛统计数据
export interface PlayerMatchStats {
  playerId: string;
  minutesPlayed: number;
  goals: number;
  assists: number;
  yellowCards: number;
  redCards: number;
  shots: number;
  shotsOnTarget: number;
  passes: number;
  passAccuracy: number; // 传球准确率百分比
  tackles: number;
  interceptions: number;
}

// 数据存储接口
export interface AppData {
  matches: FootballMatch[];
  teams: Team[];
  players: Player[];
}

// 生成唯一ID的辅助函数
export function generateId(): string {
  return 'id_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
}

// 时间格式化辅助函数
export function formatMatchTime(minutes: number, seconds?: number): string {
  if (seconds !== undefined) {
    return `${minutes}'${seconds.toString().padStart(2, '0')}"`;
  }
  return `${minutes}'`;
}

// 解析比赛时间字符串为分钟数(用于排序)
export function parseMatchTime(matchTime: string): number {
  // 支持格式: "45'", "60'", "45+2'", "90+3'"
  const match = matchTime.match(/^(\d+)(\+(\d+))?'/);
  if (!match) return 0;
  const minutes = parseInt(match[1]);
  const extra = match[3] ? parseInt(match[3]) : 0;
  return minutes + extra;
}

// 根据事件类型获取事件图标
export function getEventIcon(eventType: MatchEventType): string {
  switch (eventType) {
    case MatchEventType.GOAL:
      return '⚽';
    case MatchEventType.ASSIST:
      return '⚽';
    case MatchEventType.SUBSTITUTION:
      return '🔄';
    case MatchEventType.YELLOW_CARD:
      return '🟨';
    case MatchEventType.RED_CARD:
      return '🟥';
    case MatchEventType.STARTING_LINEUP:
      return '📋';
    case MatchEventType.HALF_TIME:
      return '⏸️';
    case MatchEventType.FULL_TIME:
      return '🏁';
    case MatchEventType.INJURY:
      return '🏥';
    case MatchEventType.PENALTY_SHOOTOUT:
      return '⚽';
    case MatchEventType.PENALTY_MISSED:
      return '❌';
    case MatchEventType.OWN_GOAL:
      return '⚽';
    case MatchEventType.EXTRA_TIME_START:
      return '⏱️';
    case MatchEventType.PENALTY_SHOOTOUT_START:
      return '⚽';
    default:
      return '📝';
  }
}

// 根据事件类型获取事件颜色
export function getEventColor(eventType: MatchEventType): string {
  switch (eventType) {
    case MatchEventType.GOAL:
      return '#4CAF50'; // 绿色
    case MatchEventType.ASSIST:
      return '#2196F3'; // 蓝色
    case MatchEventType.SUBSTITUTION:
      return '#FF9800'; // 橙色
    case MatchEventType.YELLOW_CARD:
      return '#FFEB3B'; // 黄色
    case MatchEventType.RED_CARD:
      return '#F44336'; // 红色
    case MatchEventType.STARTING_LINEUP:
      return '#9C27B0'; // 紫色
    default:
      return '#757575'; // 灰色
  }
}