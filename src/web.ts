import { WebPlugin } from '@capacitor/core';
import { BrotherPrintPlugin, BrotherPrintOptions } from './definitions';

export class BrotherPrintWeb extends WebPlugin implements BrotherPrintPlugin {
  constructor() {
    super({
      name: 'BrotherPrint',
      platforms: ['web'],
    });
  }

  /**
   * Print with Base64
   */
  async printImage(_options: BrotherPrintOptions): Promise<{ value: boolean }> {
    return {
      value: true,
    };
  }

  /**
   * Search Wifi Printer
   */
  async searchWiFiPrinter(): Promise<void> {}

  /**
   * search LE Bluetooth Printer
   */
  async searchBLEPrinter(): Promise<void> {}

  /**
   * get Paired Bluetooth Printer
   */
  async retrieveBluetoothPrinter(): Promise<void> {}
}
