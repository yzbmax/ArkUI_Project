/**
 * 浮光万能卡片 FormExtensionAbility
 */
import { formBindingData, FormExtensionAbility } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';
import { WeatherData } from '../model/CardData';
import { DataToVisualMapper } from '../utils/DataToVisualMapper';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'EntryFormAbility';
const DOMAIN = 0x0001;

function getMockWeather(): WeatherData {
  const now = new Date();
  const hour = now.getHours();
  const dayOfYear = Math.floor((now.getTime() - new Date(now.getFullYear(), 0, 0).getTime()) / 86400000);
  const seed = dayOfYear + hour;
  const weatherCode = seed % 5;
  let baseTemp = 20;
  switch (weatherCode) {
    case 0: baseTemp = 22 + (seed % 15); break;
    case 1: baseTemp = 18 + (seed % 12); break;
    case 2: baseTemp = 15 + (seed % 10); break;
    case 3: baseTemp = 10 + (seed % 12); break;
    case 4: baseTemp = -5 + (seed % 10); break;
  }
  if (hour < 6 || hour >= 22) baseTemp -= 5;
  const descriptions: string[] = ['晴', '多云', '阴', '雨', '雪'];
  const weather: WeatherData = { weatherCode: weatherCode, temperature: baseTemp, description: descriptions[weatherCode] };
  return weather;
}

function getMockSteps(): number {
  const now = new Date();
  const hour = now.getHours();
  const baseSteps = 3000;
  const hourBonus = hour >= 18 ? 6000 : hour >= 12 ? 4000 : hour >= 6 ? 2000 : 0;
  return baseSteps + hourBonus + Math.floor(Math.random() * 2000);
}

export default class EntryFormAbility extends FormExtensionAbility {
  onAddForm(want: Want): formBindingData.FormBindingData {
    hilog.info(DOMAIN, TAG, 'onAddForm');
    const formData = this.generateFormData();
    return formBindingData.createFormBindingData(formData);
  }

  onUpdateForm(formId: string): void {
    hilog.info(DOMAIN, TAG, `onUpdateForm: ${formId}`);
    const formData = this.generateFormData();
    const bindingData = formBindingData.createFormBindingData(formData);
    // 卡片会在调度更新时获取新数据
    hilog.info(DOMAIN, TAG, 'Form data generated for update');
  }

  onFormVisibleNotify(formId: string, isVisible: boolean): void {
    hilog.info(DOMAIN, TAG, `onFormVisibleNotify: ${formId}, visible: ${isVisible}`);
    if (isVisible) {
      this.onUpdateForm(formId);
    }
  }

  onRemoveForm(formId: string): void {
    hilog.info(DOMAIN, TAG, `onRemoveForm: ${formId}`);
  }

  onFormEvent(formId: string, message: string): void {
    hilog.info(DOMAIN, TAG, `onFormEvent: ${formId}, message: ${message}`);
  }

  private generateFormData(): Record<string, string | number> {
    const weather = getMockWeather();
    const steps = getMockSteps();
    const cardData = DataToVisualMapper.map(weather, steps, Date.now());
    const data: Record<string, string | number> = {
      'cardTitle': '浮光',
      'quote': cardData.quote,
      'temperature': cardData.temperatureStr,
      'steps': `${cardData.steps}步`,
      'weatherDesc': cardData.weather.description,
      'primaryColor': cardData.primaryColor,
      'secondaryColor': cardData.secondaryColor
    };
    return data;
  }
}
