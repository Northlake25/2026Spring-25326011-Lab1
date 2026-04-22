import fs from '@ohos.file.fs';
import common from '@ohos.app.ability.common';
import util from '@ohos.util';
import picker from '@ohos.file.picker';
import { AppData, FootballMatch } from './FootballMatchModel';

export class FileStorage {
  private static instance: FileStorage;
  private context: common.UIAbilityContext | null = null;
  private customDataPath: string = ''; // 自定义数据保存路径
  private customExportPath: string = ''; // 自定义导出路径
  private onDataImported: ((data: AppData) => void) | null = null; // 数据导入回调

  private constructor() {}

  public static getInstance(): FileStorage {
    if (!FileStorage.instance) {
      FileStorage.instance = new FileStorage();
    }
    return FileStorage.instance;
  }

  // 初始化
  public init(context: common.UIAbilityContext): void {
    this.context = context;
    // 默认使用应用私有目录
    if (!this.customDataPath) {
      this.customDataPath = context.filesDir + '/match_data.json';
    }
    if (!this.customExportPath) {
      this.customExportPath = context.filesDir + '/exports/';
    }
  }

  // 设置自定义数据保存路径
  public setCustomDataPath(path: string): void {
    this.customDataPath = path;
  }

  // 设置自定义导出路径
  public setCustomExportPath(path: string): void {
    this.customExportPath = path;
  }

  // 获取当前数据保存路径
  public getDataPath(): string {
    return this.customDataPath;
  }

  // 获取当前导出路径
  public getExportPath(): string {
    return this.customExportPath;
  }

  // 保存数据到文件
  public async saveData(data: AppData): Promise<boolean> {
    try {
      const dataString = JSON.stringify(data, null, 2);
      const file = fs.openSync(this.customDataPath, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY);
      fs.writeSync(file.fd, dataString);
      fs.closeSync(file);
      console.log('数据保存成功:', this.customDataPath);
      return true;
    } catch (error) {
      console.error('保存数据失败:', error);
      return false;
    }
  }

  // 从文件加载数据
  public async loadData(): Promise<AppData | null> {
    try {
      // 检查文件是否存在
      const exists = fs.accessSync(this.customDataPath);
      if (!exists) {
        console.log('数据文件不存在');
        return null;
      }

      const file = fs.openSync(this.customDataPath, fs.OpenMode.READ_ONLY);
      const stat = fs.statSync(this.customDataPath);
      const buffer = new ArrayBuffer(stat.size);
      fs.readSync(file.fd, buffer);
      fs.closeSync(file);

      const decoder = new util.TextDecoder('utf-8');
      const dataString = decoder.decodeToString(new Uint8Array(buffer));
      return JSON.parse(dataString) as AppData;
    } catch (error) {
      console.error('加载数据失败:', error);
      return null;
    }
  }

  // 导出数据到指定路径
  public async exportData(data: AppData, filename: string): Promise<string> {
    try {
      // 确保导出目录存在
      this.ensureDirectoryExists(this.customExportPath);

      const exportFilePath = this.customExportPath + filename;
      const dataString = JSON.stringify(data, null, 2);
      const file = fs.openSync(exportFilePath, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY);
      fs.writeSync(file.fd, dataString);
      fs.closeSync(file);

      console.log('数据导出成功:', exportFilePath);
      return exportFilePath;
    } catch (error) {
      console.error('导出数据失败:', error);
      throw new Error('导出数据失败');
    }
  }

  // 导出单个比赛数据
  public async exportMatch(match: FootballMatch, filename: string): Promise<string> {
    try {
      // 确保导出目录存在
      this.ensureDirectoryExists(this.customExportPath);

      const exportFilePath = this.customExportPath + filename;
      const dataString = JSON.stringify(match, null, 2);
      const file = fs.openSync(exportFilePath, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY);
      fs.writeSync(file.fd, dataString);
      fs.closeSync(file);

      console.log('比赛数据导出成功:', exportFilePath);
      return exportFilePath;
    } catch (error) {
      console.error('导出比赛数据失败:', error);
      throw new Error('导出比赛数据失败');
    }
  }

  // 确保目录存在
  private ensureDirectoryExists(dirPath: string): void {
    try {
      const exists = fs.accessSync(dirPath);
      if (!exists) {
        fs.mkdirSync(dirPath);
      }
    } catch (error) {
      // 如果目录不存在,创建它
      try {
        fs.mkdirSync(dirPath, true);
      } catch (mkdirError) {
        console.error('创建目录失败:', mkdirError);
      }
    }
  }

  // 获取默认保存路径
  public getDefaultDataPath(): string {
    return this.context ? this.context.filesDir + '/match_data.json' : '';
  }

  // 获取默认导出路径
  public getDefaultExportPath(): string {
    return this.context ? this.context.filesDir + '/exports/' : '';
  }

  // 使用文件选择器选择保存路径
  public async selectSavePath(defaultFileName: string): Promise<string> {
    if (!this.context) {
      console.error('Context未初始化');
      throw new Error('Context未初始化');
    }

    try {
      console.log('开始打开文件选择器,默认文件名:', defaultFileName);
      
      const documentSaveOptions = new picker.DocumentSaveOptions();
      documentSaveOptions.newFileNames = [defaultFileName];
      
      console.log('创建DocumentViewPicker');
      const documentViewPicker = new picker.DocumentViewPicker();
      
      console.log('调用save方法');
      const uri = await documentViewPicker.save(documentSaveOptions);
      
      console.log('文件选择器返回:', JSON.stringify(uri));
      
      if (uri && uri.length > 0) {
        // 将URI转换为文件路径
        const filePath = this.uriToPath(uri[0]);
        console.log('选择的保存路径:', filePath);
        return filePath;
      }
      
      console.log('用户取消选择');
      return '';
    } catch (error) {
      console.error('选择保存路径失败:', JSON.stringify(error));
      throw new Error('选择保存路径失败');
    }
  }

  // URI转路径
  private uriToPath(uri: string): string {
    // 去掉file://前缀
    if (uri.startsWith('file://')) {
      return uri.substring(7);
    }
    return uri;
  }

  // 保存数据到指定文件(带文件选择器)
  public async saveDataWithPicker(data: AppData, defaultFileName: string): Promise<string> {
    try {
      // 选择保存路径
      const filePath = await this.selectSavePath(defaultFileName);
      
      if (!filePath) {
        throw new Error('未选择保存路径');
      }

      // 保存数据
      const dataString = JSON.stringify(data, null, 2);
      const file = fs.openSync(filePath, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY);
      fs.writeSync(file.fd, dataString);
      fs.closeSync(file);

      console.log('数据保存成功:', filePath);
      return filePath;
    } catch (error) {
      console.error('保存数据失败:', error);
      throw new Error('保存数据失败');
    }
  }

  // 导出比赛数据(带文件选择器)
  public async exportMatchWithPicker(match: FootballMatch, defaultFileName: string): Promise<string> {
    try {
      // 选择保存路径
      const filePath = await this.selectSavePath(defaultFileName);
      
      if (!filePath) {
        throw new Error('未选择保存路径');
      }

      // 保存数据
      const dataString = JSON.stringify(match, null, 2);
      const file = fs.openSync(filePath, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY);
      fs.writeSync(file.fd, dataString);
      fs.closeSync(file);

      console.log('比赛数据导出成功:', filePath);
      return filePath;
    } catch (error) {
      console.error('导出比赛数据失败:', error);
      throw new Error('导出比赛数据失败');
    }
  }

  // 简单测试:直接保存到应用目录(不使用文件选择器)
  public async testSaveToAppDir(data: AppData, filename: string): Promise<string> {
    if (!this.context) {
      throw new Error('Context未初始化');
    }

    try {
      const filePath = this.context.filesDir + '/' + filename;
      console.log('测试保存路径:', filePath);
      
      const dataString = JSON.stringify(data, null, 2);
      console.log('数据大小:', dataString.length, '字节');
      
      const file = fs.openSync(filePath, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY);
      fs.writeSync(file.fd, dataString);
      fs.closeSync(file);

      console.log('测试保存成功:', filePath);
      return filePath;
    } catch (error) {
      console.error('测试保存失败:', JSON.stringify(error));
      throw new Error('测试保存失败');
    }
  }

  // 导出为文本报告(类似PDF)
  public async exportAsTextReport(match: FootballMatch, defaultFileName: string): Promise<string> {
    try {
      // 选择保存路径
      const filePath = await this.selectSavePath(defaultFileName);
      
      if (!filePath) {
        throw new Error('未选择保存路径');
      }

      // 生成文本报告
      const reportContent = this.generateMatchReport(match);
      
      // 保存文件
      const encoder = new util.TextEncoder();
      const contentBytes = encoder.encodeInto(reportContent);
      
      const file = fs.openSync(filePath, fs.OpenMode.CREATE | fs.OpenMode.WRITE_ONLY);
      fs.writeSync(file.fd, contentBytes.buffer);
      fs.closeSync(file);

      console.log('文本报告导出成功:', filePath);
      return filePath;
    } catch (error) {
      console.error('导出文本报告失败:', error);
      throw new Error('导出文本报告失败');
    }
  }

  // 生成比赛报告内容
  private generateMatchReport(match: FootballMatch): string {
    let report = '';
    
    report += '════════════════════════════════════════\n';
    report += '        足球比赛报告\n';
    report += '════════════════════════════════════════\n\n';
    
    report += `赛事: ${match.competition}\n`;
    report += `日期: ${match.date}\n`;
    report += `时间: ${match.time}\n`;
    report += `场地: ${match.venue}\n`;
    report += `裁判: ${match.referee}\n\n`;
    
    report += '────────────────────────────────────────\n';
    report += '              比赛结果\n';
    report += '────────────────────────────────────────\n\n';
    
    report += `${match.homeTeam.name} ${match.homeScore} - ${match.awayScore} ${match.awayTeam.name}\n`;
    
    if (match.homePenaltyScore !== undefined && match.awayPenaltyScore !== undefined) {
      report += `点球大战: ${match.homePenaltyScore} - ${match.awayPenaltyScore}\n`;
    }
    
    report += '\n';
    report += '────────────────────────────────────────\n';
    report += '              比赛事件\n';
    report += '────────────────────────────────────────\n\n';
    
    // 按时间排序事件
    const sortedEvents = match.events.slice().sort((a, b) => {
      return a.matchTime.localeCompare(b.matchTime);
    });
    
    sortedEvents.forEach(event => {
      report += `${event.matchTime}' - ${event.description}\n`;
    });
    
    report += '\n';
    report += '════════════════════════════════════════\n';
    report += '        报告生成时间\n';
    report += '════════════════════════════════════════\n\n';
    report += `${new Date().toLocaleString()}\n`;
    
    return report;
  }

  // 导入数据(使用文件选择器)
  public async importDataWithPicker(): Promise<AppData | null> {
    if (!this.context) {
      throw new Error('Context未初始化');
    }

    try {
      console.log('开始打开文件选择器(导入)');
      
      const documentSelectOptions = new picker.DocumentSelectOptions();
      
      const documentViewPicker = new picker.DocumentViewPicker();
      const uri = await documentViewPicker.select(documentSelectOptions);
      
      console.log('文件选择器返回:', JSON.stringify(uri));
      
      if (uri && uri.length > 0) {
        const filePath = this.uriToPath(uri[0]);
        console.log('选择的文件路径:', filePath);
        
        // 读取文件内容
        const file = fs.openSync(filePath, fs.OpenMode.READ_ONLY);
        const stat = fs.statSync(filePath);
        const buffer = new ArrayBuffer(stat.size);
        fs.readSync(file.fd, buffer);
        fs.closeSync(file);
        
        const decoder = new util.TextDecoder('utf-8');
        const dataString = decoder.decodeToString(new Uint8Array(buffer));
        
        console.log('文件内容长度:', dataString.length);
        
        // 解析JSON
        const data = JSON.parse(dataString) as AppData;
        console.log('导入数据成功,比赛数量:', data.matches.length);
        
        return data;
      }
      
      return null;
    } catch (error) {
      console.error('导入数据失败:', JSON.stringify(error));
      throw new Error('导入数据失败');
    }
  }
}
