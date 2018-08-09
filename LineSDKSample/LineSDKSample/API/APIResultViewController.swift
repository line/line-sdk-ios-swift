//
//  APIResultViewController.swift
//
//  Copyright (c) 2016-present, LINE Corporation. All rights reserved.
//
//  You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
//  copy and distribute this software in source code or binary form for use
//  in connection with the web services and APIs provided by LINE Corporation.
//
//  As with any software that integrates with the LINE Corporation platform, your use of this software
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
import LineSDK

struct APIResultEntry: Comparable {
    let label: String
    let value: String
    
    static func < (lhs: APIResultEntry, rhs: APIResultEntry) -> Bool {
        return lhs.label < rhs.label
    }
}

class APIResultViewController: UITableViewController, IndicatorDisplay, CellCopyable {
    var apiItem: APIItem!
    
    var resultEntries: [APIResultEntry] = []
    
    var result: Result<Any>? {
        didSet {
            defer {
                if isViewLoaded { tableView.reloadData() }
            }
            
            guard let result = result else {
                resultEntries.removeAll()
                return
            }
            
            switch result {
            case .success(let value):
                resultEntries = Mirror.toEntries(value)
            case .failure(let error):
                resultEntries.removeAll()
                UIAlertController.present(in: self, error: error) {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        apiItem.execute { result in
            self.result = result
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultEntries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "APIResultCell", for: indexPath)
        let entry = resultEntries[indexPath.row]
        cell.textLabel?.text = entry.label
        cell.detailTextLabel?.text = entry.value
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        copyCellDetailContent(at: indexPath)
    }
}

extension Mirror {
    static func toEntries(_ value: Any) -> [APIResultEntry] {
        var result = [APIResultEntry]()
        let mirror = Mirror(reflecting: value)
        for child in mirror.children {
            
            let key = child.label ?? "unknown"
            
            let value: String
            
            if let v = child.value as? String {
                value = v
            } else if let v = child.value as? URL {
                value = v.absoluteString
            } else {
                value = "\(child.value)"
            }

            result.append(.init(label: key, value: value))
        }
        result.sort()
        return result
    }
}
