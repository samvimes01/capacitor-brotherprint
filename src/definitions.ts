import { PluginListenerHandle } from '@capacitor/core';

export interface BrotherPrintPlugin {
  printImage(options: BrotherPrintOptions): Promise<{ value: boolean }>;
  searchWiFiPrinter(options: BrotherSearchOptions): Promise<void>;
  searchBLEPrinter(options: BrotherSearchOptions): Promise<void>;
  retrieveBluetoothPrinter(): Promise<void>;

  addListener(
    eventName: 'onPrint',
    listenerFunc: (info: { value: string }) => void,
  ): PluginListenerHandle;

  addListener(
    eventName: 'onRetrieveBluetoothPrinter',
    listenerFunc: (info: { serialNumberList: any[] }) => void,
  ): PluginListenerHandle;

  addListener(
    eventName: 'onBLEAvailable',
    listenerFunc: (info: { localNameList: any[] }) => void,
  ): PluginListenerHandle;

  addListener(
    eventName: 'onIpAddressAvailable',
    listenerFunc: (info: { ipAddressList: any[] }) => void,
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
  serialNumber: string;
  numberOfCopies: number;
  labelNameIndex: number;
  ipAddress?: string;
  localName?: string;
}

export interface BrotherSearchOptions {
  printerType: string; //"QL-710W","QL-720NW","QL-810W","QL-820NWB","QL-1110NWB","QL-1115NWB";
}
