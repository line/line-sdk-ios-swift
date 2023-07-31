//
//  FormEntry.swift
//
//  Copyright (c) 2016-present, LY Corporation. All rights reserved.
//
//  You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
//  copy and distribute this software in source code or binary form for use
//  in connection with the web services and APIs provided by LY Corporation.
//
//  As with any software that integrates with the LY Corporation platform, your use of this software
//  is subject to the LINE Developers Agreement [http://terms2.line.me/LINE_Developers_Agreement].
//  This copyright notice shall be included in all copies or substantial portions of the software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
//  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
//  DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import UIKit

// Render a certain model to compatible static table view cell.
protocol FormEntry {
    var cell: UITableViewCell { get }
}

class RoomNameText: FormEntry {
        
    let maximumCount = 50
    let onTextUpdated = Delegate<String, Void>()

    lazy var cell = render()
    
    private func render() -> UITableViewCell {
        let cell = OpenChatRoomNameTableViewCell(style: .default, reuseIdentifier: nil)
        cell.textView.maximumCount = maximumCount
        cell.textView.placeholderText = Localization.string("openchat.create.room.name.placeholder")
        cell.textView.onTextUpdated.delegate(on: self) { (self, result) in
            self.onTextUpdated.call(result)
        }
        return cell
    }
}

class RoomDescriptionText: FormEntry {
    
    let maximumCount = 200
    
    let onTextUpdated = Delegate<String, Void>()
    let onTextHeightUpdated = Delegate<CGFloat, Void>()
    
    lazy var cell = render()
    
    private func render() -> UITableViewCell {
        let cell = OpenChatRoomDescriptionTableViewCell(style: .default, reuseIdentifier: nil)
        cell.textView.maximumCount = maximumCount
        cell.textView.placeholderText = Localization.string("openchat.create.room.description.placeholder")
        
        cell.textView.onTextUpdated.delegate(on: self) { (self, result) in
            self.onTextUpdated.call(result)
        }
        cell.textView.onTextViewChangeContentSize.delegate(on: self) { [unowned cell] (self, size) in
            cell.updateContentHeightConstraint(size.height)
            self.onTextHeightUpdated.call(size.height)
        }
        cell.textView.onShouldReplaceText.delegate(on: self) { (self, value) in
            let (_, text) = value
            return !text.containsNewline
        }
        return cell
    }
}

class Option<T: CustomStringConvertible & Equatable>: FormEntry {
    var selectedOption: T {
        didSet {
            cell.detailTextLabel?.text = selectedOption.description
            onValueChange.call(selectedOption)
        }
    }
    let options: [T]
    let title: String?

    let onValueChange = Delegate<T, Void>()
    let onPresenting = Delegate<(), UIViewController>()
    
    lazy var cell = render()
    
    init(title: String?, options: [T], selectedOption: T? = nil) {
        self.title = title
        self.options = options
        guard !options.isEmpty else {
            Log.fatalError("No selectable options provided. Check your data source.")
        }
        self.selectedOption = selectedOption ?? options[0]
    }
    
    private func render() -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.textLabel?.font = .systemFont(ofSize: 15.0)
        cell.textLabel?.textColor = .label
        cell.textLabel?.text = title
        cell.detailTextLabel?.font = .systemFont(ofSize: 15.0)
        cell.detailTextLabel?.textColor = .secondaryLabel
        cell.detailTextLabel?.text = selectedOption.description
        cell.accessoryType = .disclosureIndicator
        
        cell.selectionStyle = .none
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapCell))
        cell.addGestureRecognizer(tap)
        
        return cell
    }
    
    @objc func tapCell() {
        guard let presentingViewController = onPresenting.call() else {
            return
        }
        let (navigation, optionsViewController) =
            OptionSelectingViewController.createViewController(data: options, selected: selectedOption)
        optionsViewController.onSelected.delegate(on: self) { (self, selected) in
            self.selectedOption = selected
        }
        presentingViewController.present(navigation, animated: true)
    }
}

class Toggle: FormEntry {
    
    let title: String?
    let initialValue: Bool
    
    let onValueChange = Delegate<Bool, Void>()
    
    lazy var cell = render()
    
    init(title: String?, initialValue: Bool = false) {
        self.title = title
        self.initialValue = initialValue
    }
    
    private func render() -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.selectionStyle = .none
        cell.textLabel?.font = .systemFont(ofSize: 15.0)
        cell.textLabel?.textColor = .label
        cell.textLabel?.text = title
        cell.accessoryView = searchOptionSwitch
        return cell
    }
    
    private lazy var searchOptionSwitch: UISwitch = {
        let searchSwitch = UISwitch()
        searchSwitch.isOn = initialValue
        searchSwitch.addTarget(self, action: #selector(switchValueDidChange(_:)), for: .valueChanged)
        return searchSwitch
    }()
    
    @objc
    func switchValueDidChange(_ sender: UISwitch) {
        onValueChange.call(sender.isOn)
    }
}
