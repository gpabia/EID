//
//  ViewController.swift
//  EID Tool
//
//  Created by Guillaume Pabia on 30/11/2016.
//  Copyright © 2016 Boquet. All rights reserved.
//

import Cocoa


class ViewController: NSViewController {

    @IBOutlet weak var textfield: NSTextField!


    @IBOutlet weak var bigTxt: NSTextField!


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func testFile(sender: AnyObject) {
        let dialog = NSOpenPanel();

        dialog.title                   = "Choose a .txt file";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = true;
        dialog.canCreateDirectories    = true;
        dialog.allowsMultipleSelection = false;
        dialog.allowedFileTypes        = ["csv","html","htm"]

        if (dialog.runModal() == NSModalResponseOK) {
            let result = dialog.URL // Pathname of the file

            if (result != nil) {
                let path = result!.path!
                textfield.stringValue = path
            }
        } else {
            return
        }
    }


    @IBAction func parseCSV(sender: AnyObject) {
        if let str = readFile(textfield.stringValue) {
            pasteStr(str)
        } else {
            NSLog("error")
        }

    }

    @IBAction func copy(sender: AnyObject) {
        if let str = readHtml(textfield.stringValue) {
            pasteStr(str)
        } else {
            NSLog("error")
        }
    }

    func pasteStr(str:String){
        print(str)
        let pasteboard = NSPasteboard.generalPasteboard()
        pasteboard.declareTypes([NSPasteboardTypeString], owner: nil)
        pasteboard.setString(str, forType: NSPasteboardTypeString)
        bigTxt.stringValue = str
        dialogOKCancel("Succès", text: "copy ok")
    }


    func dialogOKCancel(question: String, text: String) -> Bool {
        let myPopup: NSAlert = NSAlert()
        myPopup.messageText = question
        myPopup.informativeText = text
        myPopup.alertStyle = NSAlertStyle.WarningAlertStyle
        myPopup.addButtonWithTitle("OK")
        myPopup.addButtonWithTitle("Cancel")
        let res = myPopup.runModal()
        if res == NSAlertFirstButtonReturn {
            return true
        }
        return false
    }


    func readFile(path: String) -> String?{
        do {
            let text = try String(contentsOfFile: path)
            var strTotal = ""
            let arrayLine = text.componentsSeparatedByString("\n")
            for line in arrayLine {
                let arrayString = line.componentsSeparatedByString(",")
                let last = arrayString[arrayString.count-1]
                let newArray = last.componentsSeparatedByString("\n")
                let first = newArray[0]
                strTotal += first + " OR "
            }
            strTotal = strTotal.chopPrefix(7)
            strTotal = strTotal.chopSuffix(8)
            return strTotal
        } catch  {
            return nil
        }
    }

    func readHtml(path: String) -> String?{
        do {
            var strTotal = ""
            let text = try String(contentsOfFile: path)
            var arrayP : [String] = []
            let arrayLine = text.componentsSeparatedByString("Patent number")

            for last in arrayLine {
            let patent = last.componentsSeparatedByString("<td class=\"line-content\">")
            let fullPatent = patent[1]
            let newP = fullPatent.componentsSeparatedByString("</td></tr><tr>")
                let realPatent = newP[0]
                if !realPatent.containsString("<") {
                    arrayP.append(newP[0])
                }
            }
            print(arrayP.count)
            for i in 0...arrayP.count-1{
                    strTotal = strTotal + " " + arrayP[i]
            }
            return strTotal
        } catch  {
            return nil
        }
    }

    func lineGenerator(file:UnsafeMutablePointer<FILE>) -> AnyGenerator<String>
    {
        return AnyGenerator { () -> String? in
            var line:UnsafeMutablePointer<CChar> = nil
            var linecap:Int = 0
            defer { free(line) }
            return getline(&line, &linecap, file) > 0 ? String.fromCString(line) : nil
        }
    }




}

extension String {
    func chopPrefix(count: Int = 1) -> String {
        return self.substringFromIndex(self.startIndex.advancedBy(count))
    }

    func chopSuffix(count: Int = 1) -> String {
        return self.substringToIndex(self.endIndex.advancedBy(-count))
    }
}




