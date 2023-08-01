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

class APIResultViewController: UITableViewController, IndicatorDisplay, CellCopyable {
    
    static func create(with entries: [APIResultEntry]) -> APIResultViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let viewController = storyboard.instantiateViewController(withIdentifier: "APIResultViewController")
                                    as! APIResultViewController
        viewController.resultEntries = entries
        return viewController
    }
    
    var resultEntries: [APIResultEntry] = []
    
    var apiItem: APIItem?
    var result: Result<Any, ApplicationError>? {
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
        apiItem?.execute(with: self) { result in
            self.result = result
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultEntries.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "APIResultCell", for: indexPath)
        let entry = resultEntries[indexPath.row]
        
        switch entry {
        case .pair(let key, let value):
            cell.textLabel?.text = key
            cell.detailTextLabel?.text = value
            cell.accessoryType = .none
        case .array(let key, let entries):
            cell.textLabel?.text = key
            cell.detailTextLabel?.text = "\(entries.count) values"
            cell.accessoryType = .disclosureIndicator
        case .nested(let key, _):
            cell.textLabel?.text = key
            cell.detailTextLabel?.text = nil
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let entry = resultEntries[indexPath.row]
        switch entry {
        case .pair:
            copyCellDetailContent(at: indexPath)
        case .array(let key, let entries):
            let next = APIResultViewController.create(with: entries)
            next.title = key
            navigationController?.pushViewController(next, animated: true)
        case .nested(let key, let entries):
            let next = APIResultViewController.create(with: entries)
            next.title = key
            navigationController?.pushViewController(next, animated: true)
        }
    }
}
