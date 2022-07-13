import Foundation
import Capacitor
import BRLMPrinterKit
import BRPtouchPrinterKit

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(BrotherPrint)
public class BrotherPrint: CAPPlugin, BRPtouchNetworkDelegate {
    private var networkManager: BRPtouchNetworkManager?
    
    @objc func printImage(_ call: CAPPluginCall) {
        let encodedImage: String = call.getString("encodedImage") ?? "";
        if (encodedImage == "") {
            call.reject("Error - Image data is not found.");
            return;
        }
        
        let newImageData = Data(base64Encoded: encodedImage, options:.ignoreUnknownCharacters);
        
        let printerType: String = call.getString("printerType") ?? "";
        if (printerType == "") {
            call.reject("Error - printerType is not found.");
            return;
        }

        let printerTypeArr = printerType.components(separatedBy: "-");
        let printerModel: String = printerTypeArr[0];
        let defaultSettings = self.getPrinterSettingsForType(printerType);
        if (defaultSettings == BRLMPrinterModel.unknown) {
            call.reject("Error - unknown printerType.");
            return;
        }

        let localName: String = call.getString("localName") ?? "";
        let ipAddress: String = call.getString("ipAddress") ?? "";
        let serialNumber: String = call.getString("serialNumber") ?? "";
        if (localName=="" && ipAddress=="" && serialNumber=="") {
            call.reject("Error - connection is not found.");
            return;
        }
        
        // メインスレッドにて処理
        DispatchQueue.main.async {
            var channel: BRLMChannel;
            if (localName != "") {
                channel = BRLMChannel(bleLocalName: localName);
            } else if (ipAddress != "") {
                channel = BRLMChannel(wifiIPAddress: ipAddress);
            } else if (serialNumber != "") {
                channel = BRLMChannel(bluetoothSerialNumber: serialNumber);
            } else {
                // iOSは有線接続ができない
                self.notifyListeners("onPrintFailedCommunication", data: [
                    "value": true
                ]);
                return;
            }
            
            let generateResult = BRLMPrinterDriverGenerator.open(channel);
            
            var printerOption = BRLMPrinterModel.unknown;
            
            if( printerType == "QL-810W" ){
                printerOption = BRLMPrinterModel.QL_810W;
            }
            else if( printerType == "QL-720NW" ){
                printerOption = BRLMPrinterModel.QL_720NW;
            }
            else if( printerType == "QL-820NWB" ){
                printerOption = BRLMPrinterModel.QL_820NWB;
            }
            else if( printerType == "QL-1110NWB" ){
                printerOption = BRLMPrinterModel.QL_1110NWB;
            }
            else if( printerType == "QL-1115NWB" ){
                printerOption = BRLMPrinterModel.QL_1115NWB;
            }
            
            guard generateResult.error.code == BRLMOpenChannelErrorCode.noError,
                let printerDriver = generateResult.driver
                else {
                    self.notifyListeners("onPrintError", data: [
                        "value": generateResult.error.code
                    ]);
                    NSLog("Error - Open Channel: \(generateResult.error.code)")
                    return
                }
            
            guard
                let decodedByte = UIImage(data: newImageData! as Data),
                else {
                    printerDriver.closeChannel();
                    self.notifyListeners("onPrintError", data: [
                        "value": "Error - Image file is not found."
                    ]);
                    return
                }
            
            
            
            guard
                let printSettings =
                        (printerModel=="PT") ? BRLMPTPrintSettings(defaultPrintSettingsWith:defaultSettings) :
                        (printerModel=="QL") ? BRLMQLPrintSettings(defaultPrintSettingsWith:defaultSettings) :
                        (printerModel=="TD") ? BRLMTDPrintSettings(defaultPrintSettingsWith:defaultSettings) :
                        (printerModel=="RJ") ? BRLMRJPrintSettings(defaultPrintSettingsWith:defaultSettings) :
                        (printerModel=="MW") ? BRLMMWPrintSettings(defaultPrintSettingsWith:defaultSettings) :
                        BRLMPJPrintSettings(defaultPrintSettingsWith:defaultSettings)
                else {
                    printerDriver.closeChannel();
                    self.notifyListeners("onPrintError", data: [
                        "value": "Error - Printer settings error."
                    ]);
                    return
            }
            
            if (printerModel == "QL") {
                let labelNameIndex = call.getInt("labelNameIndex") ?? 16;
                (printSettings  as! BRLMQLPrintSettings).labelSize = labelNameIndex == 16 ?
                    BRLMQLPrintSettingsLabelSize.rollW62 : BRLMQLPrintSettingsLabelSize.rollW62RB;
                (printSettings  as! BRLMQLPrintSettings).autoCut = true;
                (printSettings  as! BRLMQLPrintSettings).numCopies = UInt(call.getInt("numberOfCopies") ?? 1);
            }
            
            if (printerModel == "PT") {
                let labelNameIndex = call.getInt("labelNameIndex") ?? 36;
                (printSettings  as! BRLMPTPrintSettings).labelSize = labelNameIndex == 36 ?
                BRLMPTPrintSettingsLabelSize.width36mm : BRLMPTPrintSettingsLabelSize.width24mm;
                (printSettings  as! BRLMPTPrintSettings).autoCut = true;
                (printSettings  as! BRLMPTPrintSettings).numCopies = UInt(call.getInt("numberOfCopies") ?? 1);
                (printSettings  as! BRLMPTPrintSettings).printOrientation = BRLMPrintSettingsOrientation.landscape;
            }
            
            if (printerModel == "TD") {
                (printSettings  as! BRLMTDPrintSettings).numCopies = UInt(call.getInt("numberOfCopies") ?? 1);
            }
            
            if (printerModel == "RJ") {
                (printSettings  as! BRLMRJPrintSettings).numCopies = UInt(call.getInt("numberOfCopies") ?? 1);
            }
            
            if (printerModel == "MW") {
                (printSettings  as! BRLMMWPrintSettings).numCopies = UInt(call.getInt("numberOfCopies") ?? 1);
            }
            
            let printError = printerDriver.printImage(with: decodedByte.cgImage!, settings: printSettings  as! BRLMPrintSettingsProtocol);
            
            if printError.code != .noError {
                printerDriver.closeChannel();
                NSLog(printError.description());
                self.notifyListeners("onPrintError", data: [
                    "value": printError.description()
                ]);
                return;
            }
            else {
                NSLog("Success - Print Image")
                printerDriver.closeChannel();
                call.resolve([
                    "value": true
                ]);
            }
        }
    }

    @objc func retrieveBluetoothPrinter(_ call: CAPPluginCall) {
        NSLog("Start retrieveBluetoothPrinter");
        DispatchQueue.main.async {
            let devices = BRPtouchBluetoothManager.shared().pairedDevices() as? [BRPtouchDeviceInfo] ?? []
            var resultList: [[String:String]] = [];
            for deviceInfo in devices {
                resultList.append(self.formatDeviceDate(deviceInfo));
            }
            self.notifyListeners("onRetrieveBluetoothPrinter", data: [
                "serialNumberList": resultList,
            ]);
        }
    }

    @objc func searchWiFiPrinter(_ call: CAPPluginCall) {
        NSLog("Start searchWiFiPrinter");
        let printerType: String = call.getString("printerType") ?? "";
        DispatchQueue.main.async {
            let manager = BRPtouchNetworkManager()
            manager.setPrinterName(printerType)
            manager.delegate = self
            manager.startSearch(5)
            self.networkManager = manager
        }
    }
    
    // BRPtouchNetworkDelegate
    public func didFinishSearch(_ sender: Any!) {
        NSLog("Start didFinishSearch");
        DispatchQueue.main.async {
            guard let manager = sender as? BRPtouchNetworkManager else {
                return
            }
            guard let devices = manager.getPrinterNetInfo() else {
                return
            }
            var resultList: [[String:String]] = [];
            for deviceInfo in devices {
                if let deviceInfo = deviceInfo as? BRPtouchDeviceInfo {
                    resultList.append(self.formatDeviceDate(deviceInfo));
                }
            }
            self.notifyListeners("onIpAddressAvailable", data: [
                "ipAddressList": resultList,
            ]);
        }
    }
    
    @objc func searchBLEPrinter(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            NSLog("Start searchBLEPrinter");
            BRPtouchBLEManager.shared().startSearch {
                (deviceInfo: BRPtouchDeviceInfo?) in
                if let deviceInfo = deviceInfo {
                    var resultList: [[String:String]] = [];
                    resultList.append(self.formatDeviceDate(deviceInfo));
                    self.notifyListeners("onBLEAvailable", data: [
                        "localNameList": resultList,
                    ]);
                }
            }
            self.notifyListeners("onBLEAvailable", data: [
                "localNameList": [],
            ]);
        }
    }
    
    @objc func stopSearchBLEPrinter(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            BRPtouchBLEManager.shared().stopSearch()
        }
    }
    
    private func formatDeviceDate(_ deviceInfo:BRPtouchDeviceInfo) -> [String:String] {
        return [
            "strModelName": deviceInfo.strModelName ?? "",
            "strPrinterName": deviceInfo.strPrinterName ?? "",
            "strSerialNumber": deviceInfo.strSerialNumber ?? "",
            "strLocation": deviceInfo.strLocation ?? "",
            "strIPAddress": deviceInfo.strIPAddress ?? "",
            "strNodeName": deviceInfo.strNodeName ?? "",
            "strMACAddress": deviceInfo.strMACAddress ?? "",
            "strBLEAdvertiseLocalName": deviceInfo.strBLEAdvertiseLocalName ?? "",
        ];
    }
    
    private func getPrinterSettingsForType(_ printerType:String) -> BRLMPrinterModel {
        var value: BRLMPrinterModel;
        switch printerType {
        case "PJ-673":   value = BRLMPrinterModel.PJ_673;
        case "PJ-773":   value = BRLMPrinterModel.PJ_773;
        case "MW-170":   value = BRLMPrinterModel.MW_170;
        case "MW-270":   value = BRLMPrinterModel.MW_270;
        case "RJ-4040":   value = BRLMPrinterModel.RJ_4040;
        case "RJ-3050":   value = BRLMPrinterModel.RJ_3050;
        case "RJ-3150":   value = BRLMPrinterModel.RJ_3150;
        case "RJ-2050":   value = BRLMPrinterModel.RJ_2050;
        case "RJ-2140":   value = BRLMPrinterModel.RJ_2140;
        case "RJ-2150":   value = BRLMPrinterModel.RJ_2150;
        case "RJ-4230B":   value = BRLMPrinterModel.RJ_4230B;
        case "RJ-4250WB":   value = BRLMPrinterModel.RJ_4250WB;
        case "TD-2120N":   value = BRLMPrinterModel.TD_2120N;
        case "TD-2130N":   value = BRLMPrinterModel.TD_2130N;
        case "TD-4100N":   value = BRLMPrinterModel.TD_4100N;
        case "TD-4420DN":   value = BRLMPrinterModel.TD_4420DN;
        case "TD-4520DN":   value = BRLMPrinterModel.TD_4520DN;
        case "TD-4550DNW":   value = BRLMPrinterModel.TD_4550DNWB;
        case "QL-710W":   value = BRLMPrinterModel.QL_710W;
        case "QL-720NW":   value = BRLMPrinterModel.QL_720NW;
        case "QL-810W":   value = BRLMPrinterModel.QL_810W;
        case "QL-820NWB":   value = BRLMPrinterModel.QL_820NWB;
        case "QL-1110NWB":   value = BRLMPrinterModel.QL_1110NWB;
        case "QL-1115NWB":   value = BRLMPrinterModel.QL_1115NWB;
        case "PT-E550W":   value = BRLMPrinterModel.PT_E550W;
        case "PT-P750W":   value = BRLMPrinterModel.PT_P750W;
        case "PT-D800W":   value = BRLMPrinterModel.PT_D800W;
        case "PT-E800W":   value = BRLMPrinterModel.PT_E800W;
        case "PT-E850TKW":   value = BRLMPrinterModel.PT_E850TKW;
        case "PT-P900W":    value = BRLMPrinterModel.PT_P900W;
        case "PT-P950NW":   value = BRLMPrinterModel.PT_P950NW;
        case "PT-P300BT":   value = BRLMPrinterModel.PT_P300BT;
        case "PT-P710BT":   value = BRLMPrinterModel.PT_P710BT;
        case "PT-P910BT":   value = BRLMPrinterModel.PT_P910BT;
            
        default:
            value = BRLMPrinterModel.unknown;
        }
        return value;
    }
}
