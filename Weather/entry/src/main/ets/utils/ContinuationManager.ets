/**
 * 分布式流转管理器
 * 设备发现、数据流转、多端同步
 * 
 * 使用说明：
 * - 流转按钮触发 startContinuation 开始流转流程
 * - onContinue/onRestore 分别在源端和目标端处理数据
 * - 本文件提供设备发现和数据同步的辅助工具
 */
import { distributedDeviceManager } from '@kit.DistributedServiceKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { CardData } from '../model/CardData';

const TAG = 'ContinuationManager';
const DOMAIN = 0x0003;

export interface DiscoveredDevice {
  deviceId: string;
  deviceName: string;
  deviceType: string;
  networkId: string;
}

export class ContinuationManager {
  private deviceManager: distributedDeviceManager.DeviceManager | null = null;
  private discoveredDevices: DiscoveredDevice[] = [];

  /**
   * 初始化设备管理器
   */
  async initDeviceManager(): Promise<void> {
    try {
      this.deviceManager = distributedDeviceManager.createDeviceManager(
        'com.example.floatinglight'
      );
      hilog.info(DOMAIN, TAG, 'DeviceManager created');
    } catch (err) {
      const error = err as BusinessError;
      hilog.error(DOMAIN, TAG, `Create DeviceManager failed: ${error.message}`);
    }
  }

  /**
   * 发现附近设备
   */
  async discoverDevices(): Promise<DiscoveredDevice[]> {
    if (!this.deviceManager) {
      await this.initDeviceManager();
    }
    if (!this.deviceManager) {
      return [];
    }

    return new Promise<DiscoveredDevice[]>((resolve) => {
      try {
        const devices = this.deviceManager!.getAvailableDeviceListSync();
        const result: DiscoveredDevice[] = [];
        for (let i = 0; i < devices.length; i++) {
          const device = devices[i];
          result.push({
            deviceId: device.deviceId,
            deviceName: device.deviceName,
            deviceType: device.deviceType,
            networkId: device.networkId
          });
        }
        this.discoveredDevices = result;
        hilog.info(DOMAIN, TAG, `Found ${result.length} devices`);
        resolve(result);
      } catch (err) {
        const error = err as BusinessError;
        hilog.error(DOMAIN, TAG, `Discover devices failed: ${error.message}`);
        resolve([]);
      }
    });
  }

  /**
   * 注册设备状态变化监听
   */
  registerDeviceStateCallback(
    onOnline: (device: DiscoveredDevice) => void,
    onOffline: (device: DiscoveredDevice) => void
  ): void {
    if (!this.deviceManager) return;

    this.deviceManager.on('deviceStateChange', (data) => {
      hilog.info(DOMAIN, TAG, `Device state changed: ${JSON.stringify(data)}`);
      // 处理设备上下线
      if (data.action === distributedDeviceManager.DeviceStateChangeAction.ONLINE) {
        const device = this.deviceManager!.getAvailableDeviceListSync()
          .find(d => d.deviceId === data.device?.deviceId);
        if (device) {
          onOnline({
            deviceId: device.deviceId,
            deviceName: device.deviceName,
            deviceType: device.deviceType,
            networkId: device.networkId
          });
        }
      } else if (data.action === distributedDeviceManager.DeviceStateChangeAction.OFFLINE) {
        if (data.device) {
          onOffline({
            deviceId: data.device.deviceId,
            deviceName: data.device.deviceName,
            deviceType: data.device.deviceType,
            networkId: data.device.networkId
          });
        }
      }
    });
  }

  /**
   * 释放资源
   */
  release(): void {
    if (this.deviceManager) {
      try {
        this.deviceManager.off('deviceStateChange');
      } catch (e) {
        // 忽略
      }
      this.deviceManager = null;
    }
  }
}
