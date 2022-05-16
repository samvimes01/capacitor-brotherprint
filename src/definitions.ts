import { PluginListenerHandle } from '@capacitor/core';

export interface BrotherPrintPlugin {
  printImage(options: BrotherPrintOptions): Promise<{ value: boolean }>;
  searchWiFiPrinter(): Promise<void>;
  searchBLEPrinter(): Promise<void>;
  retrieveBluetoothPrinter(): Promise<void>;

  addListener(
    eventName: 'onPrint',
    listenerFunc: (info: { value: string }) => void,
  ): PluginListenerHandle;

  addListener(
    eventName: 'onRetrieveBluetoothPrinter',
    listenerFunc: (info: { serialNumberList: [] }) => void,
  ): PluginListenerHandle;

  addListener(
    eventName: 'onBLEAvailable',
    listenerFunc: (info: { localNameList: [] }) => void,
  ): PluginListenerHandle;

  addListener(
    eventName: 'onIpAddressAvailable',
    listenerFunc: (info: { ipAddressList: [] }) => void,
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
  printerType: 'QL-820NWB' | 'QL-800' | 'PT-P910BT';
  numberOfCopies: number;
  labelNameIndex: 16 | 38;
  ipAddress?: string;
  localName?: string;
}
