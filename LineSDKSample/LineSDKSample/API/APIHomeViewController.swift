//
//  APIHomeViewController.swift
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

class APIHomeViewController: UITableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return APICategory.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let category = APICategory(rawValue: section)!
        return APIStore.shared.numberOfAPIs(in: category)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let category = APICategory(rawValue: indexPath.section)!
        let api = APIStore.shared.api(in: category, at: indexPath.row)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "APIHomeCell", for: indexPath)
        cell.textLabel?.text = api.title
        cell.detailTextLabel?.textColor = .gray
        cell.detailTextLabel?.text = api.path
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let indexPath = tableView.indexPathForSelectedRow else {
            return
        }
        
        let viewController = segue.destination as! APIResultViewController
        
        let category = APICategory(rawValue: indexPath.section)!
        let api = APIStore.shared.api(in: category, at: indexPath.row)
        viewController.apiItem = api
        viewController.title = api.title
    }
}
