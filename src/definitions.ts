import { PluginListenerHandle } from '@capacitor/core';

export interface BrotherPrintPlugin {
  printImage(options: BrotherPrintOptions): Promise<{ value: boolean }>;
  searchWiFiPrinter(printerType: string): Promise<void>;
  searchBLEPrinter(): Promise<void>;

  addListener(
    eventName: 'onPrint',
    listenerFunc: () => void,
  ): PluginListenerHandle;

  addListener(
    eventName: 'onBLEAvailable',
    listenerFunc: () => void,
  ): PluginListenerHandle;

  addListener(
    eventName: 'onBLEAvailable',
    listenerFunc: () => void,
  ): PluginListenerHandle;

  addListener(
    eventName: 'onIpAddressAvailable',
    listenerFunc: (info: { ipAddressList: string[] }) => void,
  ): PluginListenerHandle;

  addListener(
    eventName: 'onPrintFailedCommunication',
    listenerFunc: (info: { value: string }) => void,
  ): PluginListenerHandle;

  addListener(
    eventName: 'onPrintError',
    listenerFunc: (info: { value: string }) => void,
  ): PluginListenerHandle;
}

export interface BrotherPrintOptions {
  encodedImage: string;
  printerType: string; //"QL-710W","QL-720NW","QL-810W","QL-820NWB","QL-1110NWB","QL-1115NWB";
  numberOfCopies: number;
  labelNameIndex: 16 | 38;
  ipAddress?: string;
  localName?: string;
}
