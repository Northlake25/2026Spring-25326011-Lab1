import dataPreferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';
import { AppData } from './FootballMatchModel';

export class DataStorage {
  private static instance: DataStorage;
  private preferences: dataPreferences.Preferences | null = null;
  private context: common.UIAbilityContext | null = null;

  private constructor() {}

  public static getInstance(): DataStorage {
    if (!DataStorage.instance) {
      DataStorage.instance = new DataStorage();
    }
    return DataStorage.instance;
  }

  // 初始化Preferences
  public async init(context: common.UIAbilityContext): Promise<void> {
    this.context = context;
    try {
      this.preferences = await dataPreferences.getPreferences(context, 'football_match_data');
    } catch (error) {
      console.error('初始化Preferences失败:', error);
    }
  }

  // 保存数据
  public async saveData(data: AppData): Promise<boolean> {
    if (!this.preferences) {
      console.error('Preferences未初始化');
      return false;
    }

    try {
      const dataString = JSON.stringify(data);
      await this.preferences.put('match_data', dataString);
      await this.preferences.flush();
      return true;
    } catch (error) {
      console.error('保存数据失败:', error);
      return false;
    }
  }

  // 加载数据
  public async loadData(): Promise<AppData | null> {
    if (!this.preferences) {
      console.error('Preferences未初始化');
      return null;
    }

    try {
      const dataString = await this.preferences.get('match_data', '');
      if (dataString && typeof dataString === 'string') {
        return JSON.parse(dataString) as AppData;
      }
      return null;
    } catch (error) {
      console.error('加载数据失败:', error);
      return null;
    }
  }

  // 清除数据
  public async clearData(): Promise<boolean> {
    if (!this.preferences) {
      return false;
    }

    try {
      await this.preferences.clear();
      await this.preferences.flush();
      return true;
    } catch (error) {
      console.error('清除数据失败:', error);
      return false;
    }
  }
}
